---
name: coding-standards-checker
description: This skill should be used when writing or reviewing code for the甘草云HIS system (Spring Cloud microservices). Use this skill to ensure code adheres to module boundary rules and properly handles complex business logic that spans multiple modules. Trigger this skill when: (1) implementing new features that touch multiple services, (2) adding cross-module calls, (3) creating complex business workflows, or (4) reviewing code for architectural compliance.
---

# Coding Standards Checker

## Overview

Ensures code adheres to the architectural principles of the甘草云HIS Spring Cloud microservices system. Validates module boundaries, enforces proper inter-service communication patterns, and guides complex business logic implementation across multiple modules.

## When to Use This Skill

Use this skill when:
- Implementing features that require calls to other services
- Writing or reviewing code that spans multiple modules
- Creating complex business workflows involving multiple services
- Adding new inter-service communication
- Refactoring existing code that touches module boundaries

## Core Principles

### 1. Module Boundary Enforcement

**Principle**: Each service module must be autonomous. Direct access to another module's internal implementation is strictly forbidden.

**Allowed Communication**:
- All inter-service calls MUST go through Feign clients defined in `his-rest` module
- Each service exposes only what's defined in its Feign interface

**Forbidden Patterns**:
```java
// FORBIDDEN: Direct access to another service's database
@Autowired
private OtherServiceMapper otherServiceMapper;  // NEVER DO THIS

// FORBIDDEN: Direct instantiation of another service's internal components
OtherServiceImpl service = new OtherServiceImpl();  // NEVER DO THIS

// FORBIDDEN: Direct calls to another service's service layer
@Autowired
@Lazy
private OtherService otherService;  // NEVER DO THIS
```

**Correct Pattern**:
```java
// CORRECT: Use Feign client from his-rest
@Autowired
private OtherServiceFeignClient otherServiceFeignClient;  // DO THIS
```

### 2. Module Dependencies and Communication

**Service Modules**:
- `his-service-base` - 基础服务 (员工、认证、配置)
- `his-service-order` - 订单、收银服务
- `his-service-pay` - 支付服务
- `his-service-crm` - 客户/患者关系管理
- `his-service-treatment` - 诊疗过程服务
- `his-service-pharmacy` - 药房管理
- `his-service-supplychain` - 供应链服务

**Communication Rules**:
1. All inter-service calls use Feign clients from `his-rest`
2. Feign clients follow naming pattern: `*ServiceFeignClient` or `*FeignClient`
3. Each service module only depends on: `his-common-lib`, `his-shard-module`, `his-rest`

### 3. Complex Business Logic - Facade Pattern

**When to Use Facade**:
- Business logic requires coordination of 3 or more services
- Workflow involves multiple steps with transaction management
- Operation requires complex error handling across services

**Facade Layer Structure**:
```
service-module/
├── facade/
│   └── XxxFacade.java       # Complex business orchestration
├── service/
│   ├── impl/
│   │   └── XxxServiceImpl.java  # Single-module business logic
```

**Guidelines**:
- Service layer handles single-module business logic
- Facade layer handles multi-module orchestration
- Facade methods use `@GlobalTransactional` for distributed transactions

**Example**:
```java
// Facade layer - orchestrates multiple services
@Component
public class PrescriptionFacade {
    @Autowired
    private TreatmentServiceFeignClient treatmentClient;
    @Autowired
    private PharmacyServiceFeignClient pharmacyClient;
    @Autowired
    private OrderServiceFeignClient orderClient;

    @GlobalTransactional(name = "prescription-create", rollbackFor = Exception.class)
    public void createPrescription(PrescriptionDTO dto) {
        // 1. Call treatment service
        treatmentClient.saveTreatment(dto.getTreatmentInfo());

        // 2. Call pharmacy service
        pharmacyClient.savePrescription(dto.getPrescriptionInfo());

        // 3. Call order service
        orderClient.createOrder(dto.getOrderInfo());
    }
}
```

### 4. Distributed Transaction Management

**Use `@GlobalTransactional` when**:
- Operation modifies data in 2 or more services
- Business workflow requires atomicity across services
- Compensation actions are needed on failure

**Configuration**:
- Each service's Seata group is configured in `bootstrap.properties`
- Format: `seata.tx-service-group=my-service-seata-group`

**Best Practices**:
- Keep transaction scope as small as possible
- Avoid long-running transactions
- Design idempotent operations for retry scenarios

## Code Review Checklist

Before completing any code change, verify:

### Module Boundaries
- [ ] No direct `@Autowired` of another service's internal components
- [ ] No direct access to another service's database/Mapper
- [ ] All inter-service calls use Feign clients from `his-rest`
- [ ] No circular dependencies between services

### Complex Business Logic
- [ ] If coordinating 3+ services, use Facade layer
- [ ] If modifying data in 2+ services, use `@GlobalTransactional`
- [ ] Transaction scope is minimized
- [ ] Error handling considers distributed failure scenarios

### Code Organization
- [ ] Single-module logic in `service/` layer
- [ ] Multi-module orchestration in `facade/` layer
- [ ] Clear separation between local and distributed transactions

## Module-Specific Guidelines

### his-service-base (基础服务)
- Provides authentication, employee management, configuration
- Called by most other services for user/tenant context
- Should NOT depend on business services (order, pharmacy, etc.)

### his-service-order (订单服务)
- Manages orders, cashiers, settlements
- May call: crm (patient info), treatment (diagnosis), pharmacy (drug info)
- Should NOT call: base (except through Feign for read-only config)

### his-service-pay (支付服务)
- Handles payment processing (WeChat Pay, Alipay, Hangzhou Bank)
- Called by: order, crm
- Should be independent - minimal outgoing calls

### his-service-crm (客户/患者关系管理)
- Manages patients, customer relationships
- May call: base (employee info)
- Called by: order, treatment, pharmacy

### his-service-treatment (诊疗过程服务)
- Manages diagnosis, treatment records
- May call: crm (patient info), pharmacy (drug inventory)
- Called by: order

### his-service-pharmacy (药房管理)
- Manages prescriptions, inventory, dispensing
- May call: supplychain (procurement), treatment (prescription source)
- Called by: order, treatment

### his-service-supplychain (供应链服务)
- Manages procurement, suppliers, warehouse
- Called by: pharmacy
- Should be relatively independent

## References

See `references/` for detailed information:
- `module-dependencies.md` - Detailed dependency graph between modules
- `feign-clients.md` - Complete list of available Feign clients
- `transaction-patterns.md` - Common transaction patterns and examples

---

**Remember**: The goal is loose coupling and high cohesion. Each service should be independently deployable and testable.
