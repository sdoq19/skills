# Transaction Patterns - 甘草云HIS

This document describes transaction patterns for local and distributed transactions in the system.

## Transaction Management Overview

The system uses two types of transactions:
1. **Local Transaction** (`@Transactional`) - Single database operations
2. **Distributed Transaction** (`@GlobalTransactional`) - Cross-service operations using Seata

## Local Transactions (@Transactional)

### When to Use
- Operations within a single service module
- Single database modifications
- Standard CRUD operations

### Configuration
Each service's transaction manager is configured in `application.yml`:
```yaml
spring:
  datasource:
    # Druid connection pool configuration
```

### Example
```java
@Service
public class PatientServiceImpl implements PatientService {

    @Transactional(rollbackFor = Exception.class)
    public void createPatient(PatientDTO dto) {
        // All operations within this method are transactional
        Patient patient = new Patient();
        BeanCopierUtil.copy(dto, patient);
        patientMapper.insert(patient);

        // Related records in same database
        PatientProfile profile = new PatientProfile();
        profile.setPatientId(patient.getId());
        patientProfileMapper.insert(profile);
    }
}
```

### Best Practices
- Always specify `rollbackFor = Exception.class`
- Keep transaction scope small
- Avoid long-running transactions
- Don't call external services within local transactions

## Distributed Transactions (@GlobalTransactional)

### When to Use
- Operations modifying data in 2 or more services
- Business workflows requiring atomicity across services
- Operations needing compensation on failure

### Configuration

**Service-side (bootstrap.properties)**:
```properties
# Seata configuration
seata.enabled=true
se.tx-service-group=his-service-order-seata-group
seata.service.vgroup-mapping.his-service-order-seata-group=default
seata.registry.nacos.server-addr=127.0.0.1:8848
```

**Seata Server**: Separate Seata server coordinates transactions

### Example - Prescription Order Creation

```java
@Component
public class PrescriptionFacade {

    @Autowired
    private TreatmentServiceFeignClient treatmentClient;
    @Autowired
    private PharmacyServiceFeignClient pharmacyClient;
    @Autowired
    private OrderServiceFeignClient orderClient;
    @Autowired
    private PaymentServiceFeignClient paymentClient;

    /**
     * Create prescription order with distributed transaction
     * This method ensures atomicity across multiple services
     */
    @GlobalTransactional(
        name = "prescription-order-create",
        rollbackFor = Exception.class,
        timeout = 60000
    )
    public Long createPrescriptionOrder(PrescriptionOrderDTO dto) {
        try {
            // Step 1: Save treatment record (Treatment Service)
            TreatmentRecordDTO treatmentRecord = new TreatmentRecordDTO();
            treatmentRecord.setPatientId(dto.getPatientId());
            treatmentRecord.setDiagnosis(dto.getDiagnosis());
            CommonResult<Long> treatmentResult = treatmentClient.createTreatmentRecord(treatmentRecord);
            Long treatmentId = treatmentResult.getData();

            // Step 2: Create prescription (Pharmacy Service)
            PrescriptionDTO prescription = new PrescriptionDTO();
            prescription.setTreatmentId(treatmentId);
            prescription.setDrugs(dto.getDrugs());
            CommonResult<Long> prescriptionResult = pharmacyClient.createPrescription(prescription);
            Long prescriptionId = prescriptionResult.getData();

            // Step 3: Create order (Order Service)
            OrderDTO order = new OrderDTO();
            order.setPrescriptionId(prescriptionId);
            order.setPatientId(dto.getPatientId());
            order.setTotalAmount(calculateTotal(dto.getDrugs()));
            CommonResult<Long> orderResult = orderClient.createOrder(order);
            Long orderId = orderResult.getData();

            // Step 4: Process payment (Pay Service)
            PaymentRequestDTO payment = new PaymentRequestDTO();
            payment.setOrderId(orderId);
            payment.setAmount(order.getTotalAmount());
            payment.setPaymentMethod(dto.getPaymentMethod());
            CommonResult<PaymentResultDTO> paymentResult = paymentClient.wechatPay(payment);

            if (!paymentResult.getData().isSuccess()) {
                throw new PaymentException("Payment failed");
            }

            return orderId;

        } catch (Exception e) {
            // Seata will automatically rollback all above operations
            log.error("Failed to create prescription order", e);
            throw e;
        }
    }
}
```

### Transaction Propagation Behavior

When calling Feign clients within a `@GlobalTransactional`:

1. **Caller Service**: Initiates Seata global transaction
2. **Feign Client**: Propagates XID (Transaction ID) via HTTP headers
3. **Callee Service**: Joins the global transaction using propagated XID
4. **Seata Server**: Coordinates commit/rollback across all participants

### Timeout Configuration
```java
@GlobalTransactional(
    name = "long-running-business",
    rollbackFor = Exception.class,
    timeout = 120000  // 2 minutes
)
```

## Common Transaction Patterns

### Pattern 1: Saga Pattern (Manual Compensation)

Use when: External systems don't support distributed transactions

```java
@Component
public class OrderPaymentFacade {

    @Autowired
    private OrderServiceFeignClient orderClient;
    @Autowired
    private PaymentServiceFeignClient paymentClient;
    @Autowired
    private PharmacyServiceFeignClient pharmacyClient;

    public void processOrderWithCompensation(OrderDTO order) {
        Long orderId = null;
        Long paymentId = null;

        try {
            // Step 1: Create order
            orderId = orderClient.createOrder(order).getData();

            // Step 2: Process payment
            PaymentRequestDTO payment = buildPayment(orderId, order.getAmount());
            paymentId = paymentClient.wechatPay(payment).getData().getPaymentId();

            // Step 3: Deduct inventory
            pharmacyClient.deductInventory(order.getInventoryDeduct());

        } catch (Exception e) {
            // Manual compensation (Saga)
            log.error("Order processing failed, compensating", e);

            if (paymentId != null) {
                try {
                    paymentClient.refund(buildRefund(paymentId));
                } catch (Exception ex) {
                    log.error("Refund failed", ex);
                }
            }

            if (orderId != null) {
                try {
                    orderClient.cancelOrder(orderId);
                } catch (Exception ex) {
                    log.error("Order cancel failed", ex);
                }
            }

            throw new OrderProcessingException("Failed to process order", e);
        }
    }
}
```

### Pattern 2: Eventual Consistency (Message Queue)

Use when: Real-time consistency not required, high throughput needed

```java
@Service
public class OrderServiceImpl implements OrderService {

    @Autowired
    private RocketMQTemplate rocketMQTemplate;

    @Transactional(rollbackFor = Exception.class)
    public void createOrder(OrderDTO order) {
        // Save order locally
        orderMapper.insert(order);

        // Send message for async processing (other services will consume)
        OrderCreatedEvent event = new OrderCreatedEvent();
        event.setOrderId(order.getId());
        event.setPatientId(order.getPatientId());
        event.setTotalAmount(order.getTotalAmount());

        rocketMQTemplate.syncSend("order-created-topic", event);
    }
}

// Consumer in Pharmacy Service
@RocketMQMessageListener(topic = "order-created-topic", consumerGroup = "pharmacy-consumer")
public class OrderCreatedConsumer implements RocketMQListener<OrderCreatedEvent> {

    @Autowired
    private DrugInventoryService inventoryService;

    @Override
    public void onMessage(OrderCreatedEvent event) {
        // Process asynchronously
        inventoryService.reserveInventory(event.getOrderId());
    }
}
```

### Pattern 3: TCC (Try-Confirm-Cancel)

Use when: Strong consistency required, need to reserve resources

```java
@Component
public class InventoryTCCFacade {

    @Autowired
    private PharmacyServiceFeignClient pharmacyClient;

    @TwoPhaseBusinessAction(
        name = "reserveInventoryTCC",
        commitMethod = "commitReserve",
        rollbackMethod = "cancelReserve"
    )
    public boolean reserveInventory(
        BusinessActionContext actionContext,
        @BusinessActionContextParameter(paramName = "inventoryId") Long inventoryId,
        @BusinessActionContextParameter(paramName = "quantity") Integer quantity
    ) {
        // Try phase: Reserve inventory
        return pharmacyClient.reserveInventory(inventoryId, quantity);
    }

    public boolean commitReserve(BusinessActionContext actionContext) {
        // Confirm phase: Actually deduct inventory
        Long inventoryId = actionContext.getActionContext("inventoryId", Long.class);
        Integer quantity = actionContext.getActionContext("quantity", Integer.class);
        return pharmacyClient.confirmDeduct(inventoryId, quantity);
    }

    public boolean cancelReserve(BusinessActionContext actionContext) {
        // Cancel phase: Release reserved inventory
        Long inventoryId = actionContext.getActionContext("inventoryId", Long.class);
        Integer quantity = actionContext.getActionContext("quantity", Integer.class);
        return pharmacyClient.releaseReserve(inventoryId, quantity);
    }
}
```

## Error Handling Strategies

### 1. Retry with Idempotency
```java
@GlobalTransactional(rollbackFor = Exception.class)
public void processWithRetry(OrderDTO order) {
    for (int i = 0; i < 3; i++) {
        try {
            orderClient.createOrder(order);
            break;
        } catch (DuplicateKeyException e) {
            // Idempotent - already processed
            log.info("Order already exists, skipping");
            break;
        } catch (Exception e) {
            if (i == 2) throw e;
            Thread.sleep(1000);
        }
    }
}
```

### 2. Fallback Operation
```java
@GlobalTransactional(rollbackFor = Exception.class)
public void processWithFallback(OrderDTO order) {
    try {
        paymentClient.wechatPay(order.getPayment());
    } catch (PaymentException e) {
        // Fallback to alternative payment method
        log.warn("WeChat pay failed, trying Alipay");
        paymentClient.alipay(order.getPayment());
    }
}
```

## Anti-Patterns to Avoid

### 1. Mixing Local and Distributed Transactions
```java
// BAD: Don't nest @Transactional inside @GlobalTransactional
@GlobalTransactional
public void badExample() {
    localTransactionalMethod();  // Can cause issues
}
```

### 2. Long-Running Distributed Transactions
```java
// BAD: Don't include external API calls in transaction
@GlobalTransactional
public void badExample() {
    orderClient.createOrder(order);
    thirdPartyPaymentApi.pay();  // External API - removes timeout control
}
```

### 3. Missing Rollback Configuration
```java
// BAD: Always specify rollbackFor
@GlobalTransactional  // Missing rollbackFor = Exception.class
public void badExample() {
    // Only RuntimeException triggers rollback by default
}
```

## Monitoring and Debugging

### Seata Transaction Logging
```yaml
logging:
  level:
    io.seata: DEBUG
```

### Transaction Tracing
- Each global transaction has a unique XID
- XID is propagated across all service calls
- Check Seata server UI for transaction status
- Use SkyWalking for distributed tracing
