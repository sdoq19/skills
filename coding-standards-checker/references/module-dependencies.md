# Module Dependencies - 甘草云HIS

This document details the dependency relationships between service modules.

## Dependency Graph

```
                    his-service-base (基础服务)
                           ↑
                    Called by most services
                           |
        +----------+-------+-------+----------+
        |          |       |       |          |
        v          v       v       v          v
  his-service-crm  his-service-treatment  his-service-order
        |          |       |       |          |
        |          +------->+<------+          |
        |                  |                  |
        v                  v                  v
  his-service-pharmacy <------------------+
        |
        v
  his-service-supplychain

  his-service-pay (支付服务) - Independent, called by order/crm
```

## Allowed Call Patterns

### his-service-base (基础服务)
**Purpose**: Authentication, employee management, system configuration

**Outgoing Calls**: None (foundation service)

**Called By**:
- All other services (for user/tenant context, employee info)

**Common Feign Clients Used by Other Services**:
- `EmployeeServiceFeignClient` - Get employee information
- `UserServiceFeignClient` - Get user context
- `ConfigServiceFeignClient` - Get system configuration

### his-service-crm (客户/患者关系管理)
**Purpose**: Patient management, customer relationships

**Outgoing Calls**:
- `his-service-base` (via Feign) - Employee information, department info

**Called By**:
- `his-service-order` - Patient info for orders
- `his-service-treatment` - Patient medical history
- `his-service-pharmacy` - Patient prescription history

**Cannot Call**: order, pharmacy, treatment, supplychain

### his-service-treatment (诊疗过程服务)
**Purpose**: Diagnosis, treatment records, medical records

**Outgoing Calls**:
- `his-service-crm` (via Feign) - Patient information
- `his-service-pharmacy` (via Feign) - Drug inventory check

**Called By**:
- `his-service-order` - Diagnosis info for billing

**Cannot Call**: order, supplychain, base (use Feign for read-only)

### his-service-pharmacy (药房管理)
**Purpose**: Prescription management, inventory, dispensing

**Outgoing Calls**:
- `his-service-supplychain` (via Feign) - Procurement requests
- `his-service-treatment` (via Feign) - Verify prescription source

**Called By**:
- `his-service-order` - Drug billing info
- `his-service-treatment` - Inventory status
- `his-service-crm` - Patient prescription history

**Cannot Call**: order, base (use Feign for read-only)

### his-service-supplychain (供应链服务)
**Purpose**: Procurement, supplier management, warehouse

**Outgoing Calls**: None (independent service)

**Called By**:
- `his-service-pharmacy` - Procurement operations

### his-service-order (订单服务)
**Purpose**: Order management, cashiers, settlements

**Outgoing Calls**:
- `his-service-crm` (via Feign) - Patient info
- `his-service-treatment` (via Feign) - Diagnosis info
- `his-service-pharmacy` (via Feign) - Drug pricing
- `his-service-pay` (via Feign) - Payment processing

**Called By**: Frontend applications, admin consoles

**Cannot Call**: supplychain, base (use Feign for read-only)

### his-service-pay (支付服务)
**Purpose**: Payment processing (WeChat Pay, Alipay, Hangzhou Bank)

**Outgoing Calls**: None (payment gateway integration only)

**Called By**:
- `his-service-order` - Payment operations
- `his-service-crm` - Prepaid card operations

## Anti-Patterns to Avoid

### 1. Circular Dependencies
```
FORBIDDEN:
service-a -> service-b -> service-a
```

### 2. Deep Call Chains
```
AVOID:
service-a -> service-b -> service-c -> service-d
(Consider facade pattern or event-driven architecture)
```

### 3. Database Cross-Access
```
FORBIDDEN:
service-a directly accessing service-b's database tables
```

## Module Communication Flow Examples

### Example 1: Creating a Prescription Order
```
Order Service (his-service-order)
  ├─> CRM Service (via Feign) - Get patient info
  ├─> Treatment Service (via Feign) - Get diagnosis info
  ├─> Pharmacy Service (via Feign) - Get drug pricing
  └─> Pay Service (via Feign) - Process payment
```

### Example 2: Pharmacy Dispensing
```
Pharmacy Service (his-service-pharmacy)
  ├─> Treatment Service (via Feign) - Verify prescription validity
  ├─> Supplychain Service (via Feign) - Update inventory
  └─> CRM Service (via Feign) - Record patient medication history
```

### Example 3: Supply Procurement
```
Pharmacy Service (his-service-pharmacy)
  └─> Supplychain Service (via Feign) - Create procurement request

Supplychain Service (his-service-supplychain)
  └─> (Independent processing, warehouse management)
```
