;; Register a product
(contract-call? .supply-chain register-product)

;; Register a shipping route
(contract-call? .logistics register-route "New York" "Los Angeles" u72)

;; Create a shipment
(contract-call? .logistics create-shipment u1 u1)

;; Update shipment progress
(contract-call? .logistics update-shipment-checkpoint u1 "Chicago")

;; Complete delivery
(contract-call? .logistics complete-delivery u1)