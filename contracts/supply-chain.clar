;; supply-chain.clar
;; A simple supply chain tracking system that allows manufacturers to register products
;; and track their movement through the supply chain.

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-PRODUCT-EXISTS (err u101))
(define-constant ERR-PRODUCT-NOT-FOUND (err u102))
(define-constant ERR-INVALID-STATUS (err u103))

;; Data variables
(define-map products
    { product-id: uint }
    {
        manufacturer: principal,
        timestamp: uint,
        status: (string-ascii 20),
        current-holder: principal,
        history: (list 10 {
            holder: principal,
            status: (string-ascii 20),
            timestamp: uint
        })
    })

;; Product ID counter
(define-data-var next-product-id uint u1)

;; Read-only functions
(define-read-only (get-product (product-id uint))
    (map-get? products { product-id: product-id }))

(define-read-only (get-next-id)
    (var-get next-product-id))

;; Public functions
(define-public (register-product)
    (let (
        (product-id (var-get next-product-id))
        (existing-product (get-product product-id)))
        (asserts! (is-none existing-product) ERR-PRODUCT-EXISTS)
        (var-set next-product-id (+ product-id u1))
        (ok (map-set products
            { product-id: product-id }
            {
                manufacturer: tx-sender,
                timestamp: block-height,
                status: "manufactured",
                current-holder: tx-sender,
                history: (list
                    {
                        holder: tx-sender,
                        status: "manufactured",
                        timestamp: block-height
                    })
            }))))

(define-public (transfer-product (product-id uint) (new-holder principal) (new-status (string-ascii 20)))
    (let (
        (product (unwrap! (get-product product-id) ERR-PRODUCT-NOT-FOUND))
        (current-holder (get current-holder product)))
        (asserts! (is-eq tx-sender current-holder) ERR-NOT-AUTHORIZED)
        (ok (map-set products
            { product-id: product-id }
            (merge product {
                current-holder: new-holder,
                status: new-status,
                history: (unwrap-panic (as-max-len?
                    (append (get history product)
                        {
                            holder: new-holder,
                            status: new-status,
                            timestamp: block-height
                        })
                    u10))
            })))))

(define-public (check-holder (product-id uint) (holder principal))
    (let (
        (product (unwrap! (get-product product-id) ERR-PRODUCT-NOT-FOUND)))
        (ok (is-eq (get current-holder product) holder))))