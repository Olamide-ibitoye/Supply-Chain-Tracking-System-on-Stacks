# Supply Chain Tracking System

## Overview
The Supply Chain Tracking System is a smart contract-based application that allows manufacturers to register products and track their movement through the supply chain. It consists of three contracts:

1. **Supply Chain Contract (`supply-chain.clar`)**
2. **Logistics Contract (`logistics.clar`)**
3. **Product Registration Contract (`product-registration.clar`)**

This README provides a detailed description of each contract, their functionalities, and usage examples.

---

## Contracts

### 1. Supply Chain Contract (`supply-chain.clar`)

#### Description
Manages the registration of products by manufacturers and tracks their status and ownership history.

#### Key Features
- Register new products with unique IDs.
- Transfer ownership of products.
- Maintain product history, including past holders and status updates.
- Verify the current holder of a product.

#### Public Functions
- **`register-product`**: Registers a new product under the sender's ownership.
- **`transfer-product`**: Transfers a product to a new holder and updates its status.
- **`check-holder`**: Verifies if a specific address is the current holder of a product.

#### Read-Only Functions
- **`get-product`**: Retrieves details of a product.
- **`get-next-id`**: Fetches the next available product ID.

#### Error Codes
- `ERR-NOT-AUTHORIZED (u100)`: Unauthorized action attempted.
- `ERR-PRODUCT-EXISTS (u101)`: Product already registered.
- `ERR-PRODUCT-NOT-FOUND (u102)`: Product not found.
- `ERR-INVALID-STATUS (u103)`: Invalid status provided.

---

### 2. Logistics Contract (`logistics.clar`)

#### Description
Handles logistics operations, including shipment tracking and route management.

#### Key Features
- Register shipping routes.
- Create shipments on specific routes.
- Update shipment progress and checkpoints.
- Mark shipments as delivered.

#### Public Functions
- **`register-route`**: Registers a new shipping route with origin, destination, and estimated time.
- **`create-shipment`**: Creates a shipment for a product on a registered route.
- **`update-shipment-checkpoint`**: Updates a shipment's checkpoint and status.
- **`complete-delivery`**: Marks a shipment as delivered and updates the supply chain.

#### Read-Only Functions
- **`get-route`**: Retrieves details of a shipping route.
- **`get-shipment`**: Fetches details of a shipment.

#### Error Codes
- `ERR-INVALID-ROUTE (u200)`: Specified route does not exist.
- `ERR-INVALID-SHIPMENT (u201)`: Shipment not found.
- `ERR-UNAUTHORIZED (u202)`: Unauthorized action attempted.
- `ERR-ALREADY-DELIVERED (u203)`: Shipment already marked as delivered.

---

### 3. Product Registration Contract (`product-registration.clar`)

#### Description
Provides a registry for managing product details and associating them with manufacturers.

#### Key Features
- Register products independently of their supply chain state.
- Associate metadata with products for extended functionality.

---

## Usage Examples

### Register a Product
```clarity
(contract-call? .supply-chain register-product)
```

### Register a Shipping Route
```clarity
(contract-call? .logistics register-route "New York" "Los Angeles" u72)
```

### Create a Shipment
```clarity
(contract-call? .logistics create-shipment u1 u1)
```

### Update Shipment Progress
```clarity
(contract-call? .logistics update-shipment-checkpoint u1 "Chicago")
```

### Complete a Delivery
```clarity
(contract-call? .logistics complete-delivery u1)
```

---

## Configuration

### Project Metadata
```toml
[project]
name = "SupplyChainTrackingSystem"
description = ""
authors = []
telemetry = true
cache_dir = "./.cache"

[contracts.supply-chain]
path = "contracts/supply-chain.clar"

[contracts.logistics]
path = "contracts/logistics.clar"

[contracts.product-registration]
path = "contracts/product-registration.clar"

[repl.analysis]
passes = ["check_checker"]
check_checker = { trusted_sender = false, trusted_caller = false, callee_filter = false }
```

---

## License
Specify your license here (e.g., MIT, Apache 2.0).

