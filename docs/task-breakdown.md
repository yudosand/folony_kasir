# Task Breakdown

## Phase 1 - Backend
### Module 1: Project setup
- initialize Laravel API project
- install Sanctum
- configure environment
- configure database connection

### Module 2: Database
- create migrations
- define foreign keys
- add indexes
- add soft deletes to products

### Module 3: Models and relations
- User
- StoreSetting
- Product
- Transaction
- TransactionItem

### Module 4: Auth API
- register
- login
- logout
- me
- revoke old tokens on login

### Module 5: Store Setting API
- fetch store setting
- create/update store setting
- optional logo upload handling

### Module 6: Product API
- list products
- create product
- update product
- delete product
- upload/remove image
- pagination/search

### Module 7: Transaction API
- validate cart items
- load products by ownership
- validate stock
- create invoice number
- calculate totals/payments
- write transaction + items in DB transaction
- reduce stock

### Module 8: Invoice / history
- list transactions
- transaction detail
- invoice payload endpoint

### Module 9: Verification
- check auth flow
- check product CRUD
- check stock deduction
- check cash / non_cash / split calculations
- check underpayment partial status

## Phase 2 - Android Frontend
- to be implemented after backend is stable
