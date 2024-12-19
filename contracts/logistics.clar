;; logistics.clar
;; Handles logistics operations and shipment tracking for the supply chain

;; Error codes
(define-constant ERR-INVALID-ROUTE (err u200))
(define-constant ERR-INVALID-SHIPMENT (err u201))
(define-constant ERR-UNAUTHORIZED (err u202))
(define-constant ERR-ALREADY-DELIVERED (err u203))

;; Data maps
(define-map shipping-routes
    { route-id: uint }
    {
        origin: (string-ascii 30),
        destination: (string-ascii 30),
        estimated-time: uint,
        carrier: principal
    }
)

(define-map active-shipments
    { shipment-id: uint }
    {
        product-id: uint,
        route-id: uint,
        start-time: uint,
        status: (string-ascii 20),
        last-checkpoint: (string-ascii 30),
        carrier: principal
    }
)

;; Counter for IDs
(define-data-var next-route-id uint u1)
(define-data-var next-shipment-id uint u1)

;; Read-only functions
(define-read-only (get-route (route-id uint))
    (map-get? shipping-routes { route-id: route-id }))

(define-read-only (get-shipment (shipment-id uint))
    (map-get? active-shipments { shipment-id: shipment-id }))

;; Public functions
(define-public (register-route (origin (string-ascii 30)) 
                             (destination (string-ascii 30)) 
                             (estimated-time uint))
    (let ((route-id (var-get next-route-id)))
        (var-set next-route-id (+ route-id u1))
        (ok (map-set shipping-routes
            { route-id: route-id }
            {
                origin: origin,
                destination: destination,
                estimated-time: estimated-time,
                carrier: tx-sender
            }))))

(define-public (create-shipment (product-id uint) 
                               (route-id uint))
    (let (
        (route (unwrap! (get-route route-id) ERR-INVALID-ROUTE))
        (shipment-id (var-get next-shipment-id))
    )
    (asserts! (is-eq (get carrier route) tx-sender) ERR-UNAUTHORIZED)
    (var-set next-shipment-id (+ shipment-id u1))
    ;; Update supply chain status via other contract
    (try! (contract-call? .supply-chain transfer-product 
        product-id 
        tx-sender 
        "in-transit"))
    (ok (map-set active-shipments
        { shipment-id: shipment-id }
        {
            product-id: product-id,
            route-id: route-id,
            start-time: block-height,
            status: "initiated",
            last-checkpoint: (get origin route),
            carrier: tx-sender
        }))))

(define-public (update-shipment-checkpoint 
    (shipment-id uint) 
    (checkpoint (string-ascii 30)))
    (let (
        (shipment (unwrap! (get-shipment shipment-id) ERR-INVALID-SHIPMENT))
    )
    (asserts! (is-eq (get carrier shipment) tx-sender) ERR-UNAUTHORIZED)
    (asserts! (not (is-eq (get status shipment) "delivered")) ERR-ALREADY-DELIVERED)
    (ok (map-set active-shipments
        { shipment-id: shipment-id }
        (merge shipment {
            last-checkpoint: checkpoint,
            status: "in-progress"
        })))))

(define-public (complete-delivery 
    (shipment-id uint))
    (let (
        (shipment (unwrap! (get-shipment shipment-id) ERR-INVALID-SHIPMENT))
        (route (unwrap! (get-route (get route-id shipment)) ERR-INVALID-ROUTE))
    )
    (asserts! (is-eq (get carrier shipment) tx-sender) ERR-UNAUTHORIZED)
    (asserts! (not (is-eq (get status shipment) "delivered")) ERR-ALREADY-DELIVERED)
    ;; Update final status in supply chain
    (try! (contract-call? .supply-chain transfer-product 
        (get product-id shipment)
        tx-sender
        "delivered"))
    (ok (map-set active-shipments
        { shipment-id: shipment-id }
        (merge shipment {
            last-checkpoint: (get destination route),
            status: "delivered"
        })))))