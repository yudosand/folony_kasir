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
- stock_movements

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
- `StockMovementService`
- `StockBookkeepingService`
- `SalesProfitReportService`

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

### Stock Bookkeeping
- GET `/api/stock-bookkeeping`
- GET `/api/stock-bookkeeping/report`
- GET `/api/products/{id}/stock-card`
- POST `/api/products/{id}/restocks`
- POST `/api/products/{id}/adjustments`

### Sales Profit
- GET `/api/sales-profit/report`

### Transactions
- GET `/api/transactions`
- POST `/api/transactions`
- GET `/api/transactions/{id}`
- GET `/api/transactions/{id}/invoice`

## Sales Profit Rules

- `transaction_items.cost_price_snapshot` harus menyimpan modal saat transaksi terjadi.
- `transaction_items.selling_price_snapshot` harus menyimpan harga jual saat transaksi terjadi.
- Item manual wajib membawa `cost_price` dan `unit_price` agar profit tidak salah dihitung.
- Endpoint mobile `sales-profit/report` hanya boleh menampilkan transaksi milik user yang sedang login.
- Profit kotor per item dihitung sebagai:
  - `qty x selling_price_snapshot`
  - dikurangi `qty x cost_price_snapshot`

## Stock Bookkeeping Rules

- Produk menyimpan `stock` untuk pembacaan cepat stok saat ini.
- Produk juga menyimpan `minimum_stock` untuk insight restock.
- Semua perubahan stok penting harus menghasilkan baris baru di `stock_movements`.
- Tipe mutasi yang didukung:
  - `opening`
  - `sale`
  - `restock`
  - `adjustment`
- Stok awal produk harus tetap bisa ditelusuri dari mutasi pertama.

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
