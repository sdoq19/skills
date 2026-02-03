# Feign Clients - 甘草云HIS

This document lists the Feign client interfaces available in `his-rest` for inter-service communication.

## Feign Client Location

All Feign clients are defined in the `his-rest` module:
```
his-rest/
└── com/
    └── igancao/
        └── his/
            └── rest/
                └── feign/
                    └── [Service]ServiceFeignClient.java
```

## Available Feign Clients

### Base Service Feign Clients

#### EmployeeServiceFeignClient
```java
@FeignClient(name = "his-service-base", path = "/employee")
public interface EmployeeServiceFeignClient {
    @GetMapping("/info/{id}")
    CommonResult<EmployeeDTO> getEmployeeInfo(@PathVariable("id") Long id);

    @GetMapping("/department/{deptId}")
    CommonResult<List<EmployeeDTO>> getEmployeesByDept(@PathVariable("deptId") Long deptId);
}
```

#### UserServiceFeignClient
```java
@FeignClient(name = "his-service-base", path = "/user")
public interface UserServiceFeignClient {
    @GetMapping("/current")
    CommonResult<UserDTO> getCurrentUser();

    @GetMapping("/tenant/{tenantId}")
    CommonResult<TenantDTO> getTenantInfo(@PathVariable("tenantId") Long tenantId);
}
```

#### ConfigServiceFeignClient
```java
@FeignClient(name = "his-service-base", path = "/config")
public interface ConfigServiceFeignClient {
    @GetMapping("/value/{key}")
    CommonResult<String> getConfigValue(@PathVariable("key") String key);

    @GetMapping("/batch")
    CommonResult<Map<String, String>> getConfigBatch(@RequestParam("keys") List<String> keys);
}
```

### CRM Service Feign Clients

#### PatientServiceFeignClient
```java
@FeignClient(name = "his-service-crm", path = "/patient")
public interface PatientServiceFeignClient {
    @GetMapping("/{id}")
    CommonResult<PatientDTO> getPatient(@PathVariable("id") Long id);

    @PostMapping("/search")
    CommonResult<List<PatientDTO>> searchPatients(@RequestBody PatientSearchDTO search);

    @GetMapping("/history/{patientId}")
    CommonResult<PatientHistoryDTO> getPatientHistory(@PathVariable("patientId") Long patientId);
}
```

#### CustomerServiceFeignClient
```java
@FeignClient(name = "his-service-crm", path = "/customer")
public interface CustomerServiceFeignClient {
    @GetMapping("/{id}")
    CommonResult<CustomerDTO> getCustomer(@PathVariable("id") Long id);

    @PostMapping("/tags")
    CommonResult<Void> updateCustomerTags(@RequestBody CustomerTagsDTO tags);
}
```

### Treatment Service Feign Clients

#### DiagnosisServiceFeignClient
```java
@FeignClient(name = "his-service-treatment", path = "/diagnosis")
public interface DiagnosisServiceFeignClient {
    @GetMapping("/{id}")
    CommonResult<DiagnosisDTO> getDiagnosis(@PathVariable("id") Long id);

    @GetMapping("/patient/{patientId}")
    CommonResult<List<DiagnosisDTO>> getPatientDiagnosis(@PathVariable("patientId") Long patientId);
}
```

#### TreatmentRecordServiceFeignClient
```java
@FeignClient(name = "his-service-treatment", path = "/treatment-record")
public interface TreatmentRecordServiceFeignClient {
    @GetMapping("/{id}")
    CommonResult<TreatmentRecordDTO> getTreatmentRecord(@PathVariable("id") Long id);

    @PostMapping("/create")
    CommonResult<Long> createTreatmentRecord(@RequestBody TreatmentRecordDTO record);
}
```

### Pharmacy Service Feign Clients

#### PrescriptionServiceFeignClient
```java
@FeignClient(name = "his-service-pharmacy", path = "/prescription")
public interface PrescriptionServiceFeignClient {
    @GetMapping("/{id}")
    CommonResult<PrescriptionDTO> getPrescription(@PathVariable("id") Long id);

    @PostMapping("/create")
    CommonResult<Long> createPrescription(@RequestBody PrescriptionDTO prescription);

    @GetMapping("/drugs/{prescriptionId}")
    CommonResult<List<PrescriptionDrugDTO>> getPrescriptionDrugs(@PathVariable("prescriptionId") Long id);
}
```

#### DrugInventoryServiceFeignClient
```java
@FeignClient(name = "his-service-pharmacy", path = "/inventory")
public interface DrugInventoryServiceFeignClient {
    @GetMapping("/check/{drugId}")
    CommonResult<InventoryStatusDTO> checkInventory(@PathVariable("drugId") Long drugId);

    @GetMapping("/price/{drugId}")
    CommonResult<DrugPriceDTO> getDrugPrice(@PathVariable("drugId") Long drugId);

    @PostMapping("/deduct")
    CommonResult<Void> deductInventory(@RequestBody InventoryDeductDTO deduct);
}
```

### Order Service Feign Clients

#### OrderServiceFeignClient
```java
@FeignClient(name = "his-service-order", path = "/order")
public interface OrderServiceFeignClient {
    @GetMapping("/{id}")
    CommonResult<OrderDTO> getOrder(@PathVariable("id") Long id);

    @PostMapping("/create")
    CommonResult<Long> createOrder(@RequestBody OrderDTO order);

    @PostMapping("/settle/{orderId}")
    CommonResult<Void> settleOrder(@PathVariable("orderId") Long orderId);
}
```

### Pay Service Feign Clients

#### PaymentServiceFeignClient
```java
@FeignClient(name = "his-service-pay", path = "/payment")
public interface PaymentServiceFeignClient {
    @PostMapping("/wechat")
    CommonResult<PaymentResultDTO> wechatPay(@RequestBody PaymentRequestDTO request);

    @PostMapping("/alipay")
    CommonResult<PaymentResultDTO> alipay(@RequestBody PaymentRequestDTO request);

    @PostMapping("/refund")
    CommonResult<RefundResultDTO> refund(@RequestBody RefundRequestDTO request);

    @GetMapping("/status/{orderId}")
    CommonResult<PaymentStatusDTO> getPaymentStatus(@PathVariable("orderId") Long orderId);
}
```

### Supplychain Service Feign Clients

#### ProcurementServiceFeignClient
```java
@FeignClient(name = "his-service-supplychain", path = "/procurement")
public interface ProcurementServiceFeignClient {
    @PostMapping("/create")
    CommonResult<Long> createProcurement(@RequestBody ProcurementDTO procurement);

    @GetMapping("/{id}")
    CommonResult<ProcurementDTO> getProcurement(@PathVariable("id") Long id);
}
```

## Feign Client Usage Pattern

### Basic Usage
```java
@Service
public class MyServiceImpl implements MyService {

    @Autowired
    private PatientServiceFeignClient patientClient;

    public void processPatient(Long patientId) {
        // Call remote service
        CommonResult<PatientDTO> result = patientClient.getPatient(patientId);

        if (result.isSuccess()) {
            PatientDTO patient = result.getData();
            // Process patient data
        }
    }
}
```

### Error Handling
```java
@Service
public class MyServiceImpl implements MyService {

    @Autowired
    private PatientServiceFeignClient patientClient;

    public PatientDTO getPatientWithFallback(Long patientId) {
        try {
            CommonResult<PatientDTO> result = patientClient.getPatient(patientId);

            if (result.isSuccess()) {
                return result.getData();
            } else {
                // Handle business error
                throw new BusinessException(result.getMessage());
            }
        } catch (FeignException e) {
            // Handle network/timeout errors
            log.error("Failed to call patient service", e);
            throw new RuntimeException("Service unavailable", e);
        }
    }
}
```

### Batch Calls (Using CompletableFuture)
```java
@Service
public class MyServiceImpl implements MyService {

    @Autowired
    private PatientServiceFeignClient patientClient;
    @Autowired
    private DiagnosisServiceFeignClient diagnosisClient;

    public PatientDetailDTO getPatientDetail(Long patientId) {
        // Parallel calls to multiple services
        CompletableFuture<CommonResult<PatientDTO>> patientFuture =
            CompletableFuture.supplyAsync(() -> patientClient.getPatient(patientId));

        CompletableFuture<CommonResult<List<DiagnosisDTO>>> diagnosisFuture =
            CompletableFuture.supplyAsync(() -> diagnosisClient.getPatientDiagnosis(patientId));

        // Wait for all to complete
        CompletableFuture.allOf(patientFuture, diagnosisFuture).join();

        // Combine results
        PatientDTO patient = patientFuture.join().getData();
        List<DiagnosisDTO> diagnoses = diagnosisFuture.join().getData();

        return PatientDetailDTO.builder()
            .patient(patient)
            .diagnoses(diagnoses)
            .build();
    }
}
```

## Best Practices

1. **Always handle CommonResult wrapper** - Check `result.isSuccess()` before accessing data
2. **Implement proper error handling** - Use try-catch for FeignException
3. **Use timeout configuration** - Set appropriate timeouts in Feign configuration
4. **Consider circuit breaker** - Use Hystrix/Resilience4j for fault tolerance
5. **Log remote calls** - Include request/response logging for debugging
