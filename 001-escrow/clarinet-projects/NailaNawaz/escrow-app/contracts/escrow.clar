
;;shipment of item from seller to buyer

;; constants
(define-constant ERR_PAYMENT (err u1))
(define-constant ERR_NOT_BUYER (err u2))
(define-constant ERR_PAID_AMOUNT (err u3)) ;;price high or less than paid amount
;; data variable
(define-data-var item-buyer (optional principal) none)
(define-data-var item-seller (optional principal) none)
(define-data-var item-price uint u10)


;; this function will be called by seller
;; the price of item will be set as half of the amount send by seller to contract

(define-public (amountBySeller (amountPaid uint))
    (begin 
        (var-set item-price amountPaid u2)
        (unwrap! (stx-transfer? amountPaid tx-sender (as-contract tx-sender)) (err ERR_PAYMENT))
        (var-set item-seller (some tx-sender))
        (ok true)
    )
)

;; customer will call this method to transfer money to contract
;; check if the amount is 2x the price of item (saved in item-price variable)
;; if amount is equal to item-price then save the sender id and transfer amount to contract
;; if the amount is not equal to item-price, then throw error
;; sender id will be saved in the item-buyer variable
;;tx-sender is the one who calls the contract
   
(define-public (purchaseItem (amountPaid uint))
    (begin
        (asserts! (is-eq amountPaid (var-get item-price)) ERR_PAID_AMOUNT)
        (try! (stx-transfer? amountPaid tx-sender (as-contract tx-sender)))
        (var-set item-buyer (some tx-sender))
        (ok true)
    )
)

;; this method is called by buyer on receving item
;; return the item-price / 2 from contract to buyer
;; return the (item-price ) the price by seller + the item price paid by buyer to seller (half of amount saved in item-price variable)

(define-public (itemReceived)
    (begin 
        (asserts! (is-eq (some tx-sender) (var-get item-buyer)) ERR_NOT_BUYER)
        (try! (stx-transfer? (/ (var-get item-price) u2) (as-contract tx-sender) (unwrap-panic (var-get item-buyer))))
        (try! (stx-transfer? (+  (var-get item-price)  (/ (var-get item-price) u2)) (as-contract tx-sender) (unwrap-panic (var-get item-seller))))
        (var-set item-price u0)
        (var-set item-buyer none)
        (var-set item-seller none)
        (ok true)
    )
)

(define-read-only (itemNotReceived)
    (begin
        ;; confirmation from seller required
        (ok true)
    )
)

