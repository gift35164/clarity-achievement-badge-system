;; Achievement Badge System for Gaming Milestones
;; This contract allows the creation, transfer, and burning of non-fungible tokens (NFTs) representing achievement badges in a gaming platform.
;; It includes functionality for:
;; - Minting achievement badges (single or in batches) with unique URIs as metadata.
;; - Transferring badges between players.
;; - Burning badges to signify revocation or loss of achievement.
;; - Updating badge URIs to reflect changes in associated metadata.
;; - Verifying badge ownership, validity, and burn status.
;; The contract maintains mappings of badge URIs, tracks burned badges, and ensures only the rightful owners can modify or burn their badges.
;; Constants for error handling and validation ensure smooth operation.
;; Maximum URI length is capped to ensure consistency and prevent excessive data storage.

;; Constants for error codes and maximum URI length
(define-constant err-owner-only (err u100))               ;; Error if the caller is not the badge owner
(define-constant err-not-badge-owner (err u101))          ;; Error if the caller is not the badge owner
(define-constant err-badge-exists (err u102))             ;; Error if the badge already exists
(define-constant err-badge-not-found (err u103))          ;; Error if the badge cannot be found
(define-constant err-invalid-uri (err u104))              ;; Error if the URI provided is invalid
(define-constant err-already-burned (err u105))           ;; Error if the badge has already been burned
(define-constant max-uri-length u256)                     ;; Maximum allowed length for URI

;; Data Variables
(define-non-fungible-token achievement-badge uint)         ;; NFT token representing unique badges
(define-data-var last-badge-id uint u0)                   ;; Tracks the latest badge ID issued

;; Maps to store badge URIs and burned badge status
(define-map badge-uri uint (string-ascii 256))            ;; Map badge ID to its URI (metadata of the badge)
(define-map burned-badges uint bool)                      ;; Track if a badge has been burned (revoked)

;; Helper Functions

(define-private (is-valid-uri (uri (string-ascii 256)))
    (let ((uri-length (len uri)))
        (and (>= uri-length u1) (<= uri-length max-uri-length))))

(define-private (is-badge-owner (badge-id uint) (sender principal))
    (is-eq sender (unwrap! (nft-get-owner? achievement-badge badge-id) false)))

(define-private (is-badge-burned (badge-id uint))
    (default-to false (map-get? burned-badges badge-id)))

(define-private (create-single-badge (badge-uri-data (string-ascii 256)))
    (let ((badge-id (+ (var-get last-badge-id) u1)))
        (asserts! (is-valid-uri badge-uri-data) err-invalid-uri) ;; Check URI validity
        (try! (nft-mint? achievement-badge badge-id tx-sender))   ;; Mint the badge NFT
        (map-set badge-uri badge-id badge-uri-data)               ;; Store the badge URI
        (var-set last-badge-id badge-id)                          ;; Update the last badge ID issued
        (ok badge-id)))                                           ;; Return the badge ID created

;; Public Functions

;; Mints a new badge with the specified URI for a given milestone
(define-public (mint-achievement-badge (uri (string-ascii 256)))
    (begin
        (asserts! (is-valid-uri uri) err-invalid-uri)    ;; Validate URI length
        (create-single-badge uri)))                      ;; Create the badge and return its ID

;; Mints multiple badges for different milestones in a batch
(define-public (batch-mint-achievements (uris (list 100 (string-ascii 256))))
    (let ((batch-size (len uris)))
        (begin
            (asserts! (<= batch-size u100) (err u108)) ;; Check if the batch size is within the allowed limit (100)
            (ok (fold mint-single-in-batch uris (list))) ;; Mint badges for each URI in the batch
        )))

(define-private (mint-single-in-batch (uri (string-ascii 256)) (previous-results (list 100 uint)))
    (match (create-single-badge uri)
        success (unwrap-panic (as-max-len? (append previous-results success) u100))
        error previous-results))

;; Burns a badge based on the given badge ID
(define-public (burn-achievement-badge (badge-id uint))
    (let ((badge-owner (unwrap! (nft-get-owner? achievement-badge badge-id) err-badge-not-found)))
        (asserts! (is-eq tx-sender badge-owner) err-not-badge-owner) ;; Check if the sender is the owner of the badge
        (asserts! (not (is-badge-burned badge-id)) err-already-burned) ;; Ensure the badge has not been burned
        (try! (nft-burn? achievement-badge badge-id badge-owner))    ;; Burn the badge NFT
        (map-set burned-badges badge-id true)                        ;; Mark the badge as burned
        (ok true)))

;; Transfers a badge to another user
(define-public (transfer-achievement-badge (badge-id uint) (recipient principal))
    (begin
        (asserts! (not (is-badge-burned badge-id)) err-already-burned) ;; Ensure badge is not burned
        (let ((badge-owner (unwrap! (nft-get-owner? achievement-badge badge-id) err-not-badge-owner)))
            (asserts! (is-eq badge-owner tx-sender) err-not-badge-owner) ;; Ensure the sender owns the badge
            (try! (nft-transfer? achievement-badge badge-id tx-sender recipient)) ;; Transfer the badge
            (ok true))))

;; Updates the URI of a badge
(define-public (update-achievement-uri (badge-id uint) (new-uri (string-ascii 256)))
    (begin
        (let ((badge-owner (unwrap! (nft-get-owner? achievement-badge badge-id) err-badge-not-found)))
            (asserts! (is-eq badge-owner tx-sender) err-not-badge-owner) ;; Check ownership
            (asserts! (is-valid-uri new-uri) err-invalid-uri)            ;; Validate new URI
            (map-set badge-uri badge-id new-uri)                         ;; Update the badge URI
            (ok true))))

;; Read-Only Functions

;; Retrieves the URI associated with a specific badge ID
(define-read-only (get-achievement-uri (badge-id uint))
    (ok (map-get? badge-uri badge-id)))

;; Retrieves the owner of a specific badge
(define-read-only (get-achievement-owner (badge-id uint))
    (ok (nft-get-owner? achievement-badge badge-id)))

;; Returns the ID of the last minted badge
(define-read-only (get-last-achievement-id)
    (ok (var-get last-badge-id)))

;; Checks if a badge has been burned
(define-read-only (is-achievement-burned (badge-id uint))
    (ok (is-badge-burned badge-id)))

g