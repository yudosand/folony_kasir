# Business Rules

## Session / Authentication
- One active token per user policy
- If a new login occurs, old token may be revoked
- If token is expired or invalid, client must logout
- Folony Kasir login may bridge to the shared induk auth API
- Shared login uses phone number and password as the primary credentials
- Shared login response must be synced into the local kasir user record
- Local kasir API still issues and validates its own Sanctum token
- Shared register may bridge to the shared induk auth API
- Shared register uses name, phone, password, password confirmation, and referal
- Successful shared register should immediately continue with shared login and local token issuance
- Foloni App member points must be accessed from Folony Kasir backend only
- Foloni App admin credentials and tokens must stay server-side

## Member Points
- Foloni App remains the source of truth for member points
- Folony Kasir mobile app must call only Folony Kasir API for member point features
- Folony Kasir backend may lookup member points through Foloni App admin APIs
- Member lookup currently supports exact member lookup by Foloni App member id plus default list retrieval
- Point mutation to Foloni App must happen from Folony Kasir backend only
- `type=1` means add points, `type=2` means subtract points
- Checkout conversion rule: `1 poin = Rp1`
- `points_used` cannot exceed the transaction subtotal
- When points are used, the payable `grand_total` is reduced by the same nominal amount
- After a point deduction call succeeds, Folony Kasir must verify the deduction against Foloni App. It should first re-check the member balance, and if that balance is still delayed it may confirm the deduction from the matching point history entry for the same invoice description and amount.
- If point deduction succeeds but local transaction save fails, Folony Kasir should attempt a compensating point add

## Store
- One user has one store setting record
- Store info appears in invoice payload

## Products
- User creates and owns their own products
- Users may only access their own products
- Product stock cannot go below zero
- Product prices are stored as numeric values in database
- Product images are stored in filesystem storage and database stores only the path or URL
- Mobile clients should optimize product images before upload to reduce upload time and storage usage
- Current mobile optimization target is a longest side around `1280px` with compressed quality around `78`
- If optimization fails or the optimized file is not smaller, the original selected image may be uploaded as a fallback

## Checkout and Transaction
- Checkout uses master product prices at the time transaction is created
- Transaction items must save snapshot fields:
  - product_name_snapshot
  - cost_price_snapshot
  - selling_price_snapshot
- Stock reduces only after transaction is successfully saved
- If stock is insufficient, transaction must fail
- Transaction may contain mixed items:
  - catalog items linked to master products
  - manual items without `product_id`
- Manual items do not reduce stock

## Payment Methods
### cash
- cash amount entered by user
- amount_paid = cash_amount
- if amount_paid > grand_total, set change_amount
- if amount_paid < grand_total, set due_amount and payment_status = partial

### non_cash
- amount_paid = non_cash_amount
- change_amount must be 0
- if amount_paid < grand_total, set due_amount and payment_status = partial

### split
- amount_paid = cash_amount + non_cash_amount
- if amount_paid > grand_total, set change_amount
- if amount_paid < grand_total, set due_amount and payment_status = partial

## Payment Status
- `paid` when due_amount = 0
- `partial` when due_amount > 0

## Invoice
- Invoice number must be auto-generated
- Invoice can be reopened later from transaction history
- Invoice payload must include store information, items, totals, and payment information
