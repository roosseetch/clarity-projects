(use-trait data-trait 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE.trait.data-trait)

(define-public (upgraded-user-info (data-contract <data-trait>) (user-id uint))
    (let
        (
            (user-info (try! (as-contract (contract-call? data-contract get-user-info user-id))))
            (user-age (unwrap-panic (get age user-info)))
        )
        (if (>= user-age u18)
            (ok user-info)
        (ok none)
        )
    )
)