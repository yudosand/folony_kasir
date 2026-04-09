# Backend Architecture

## Stack
- Laravel API
- MySQL
- Sanctum

## Database Name
`folony_pos`

## Main Tables
- users
- personal_access_tokens
- store_settings
- products
- transactions
- transaction_items

## Suggested App Structure
```text
app/
├─ Http/
│  ├─ Controllers/Api/
│  ├─ Requests/
│  └─ Resources/
├─ Models/
└─ Services/

database/
├─ migrations/
└─ seeders/

routes/
└─ api.php
```

## Suggested Services
- `InvoiceNumberService`
- `ProductImageService`
- `TransactionService`
- `PaymentCalculationService`

## Main Endpoints
### Auth
- POST `/api/auth/register`
- POST `/api/auth/login`
- POST `/api/auth/logout`
- GET `/api/auth/me`

### Store Setting
- GET `/api/store-setting`
- POST `/api/store-setting`

### Products
- GET `/api/products`
- POST `/api/products`
- GET `/api/products/{id}`
- POST `/api/products/{id}` with `_method=PUT` for multipart update
- DELETE `/api/products/{id}`

### Transactions
- GET `/api/transactions`
- POST `/api/transactions`
- GET `/api/transactions/{id}`
- GET `/api/transactions/{id}/invoice`

## Response Standard
### success
```json
{
  "success": true,
  "message": "Message",
  "data": {}
}
```

### validation error
```json
{
  "success": false,
  "message": "Validation error",
  "errors": {}
}
```
