# Database Schema Notes

Database example name:

```text
folony_pos
```

## Main Tables

### `users`

- Default Laravel auth user
- Owns products, store setting, and transactions

### `personal_access_tokens`

- Sanctum access tokens
- Login revokes previous tokens so only one active token remains

### `store_settings`

- One-to-one with `users`
- Stores invoice-facing store identity

Columns:

- `user_id`
- `store_name`
- `store_address`
- `phone_number`
- `invoice_footer`
- `logo_path`

### `products`

- One-to-many from `users`
- Soft deletes enabled

Columns:

- `user_id`
- `name`
- `stock`
- `minimum_stock`
- `cost_price`
- `selling_price`
- `image_path`

### `stock_movements`

- One-to-many from `products`
- Ledger stok immutable untuk stok awal, penjualan, restock, dan penyesuaian

Columns:

- `user_id`
- `product_id`
- `product_name_snapshot`
- `type` (`opening`, `sale`, `restock`, `adjustment`)
- `direction` (`in`, `out`)
- `quantity`
- `stock_before`
- `stock_after`
- `unit_cost_snapshot`
- `reference_type`
- `reference_id`
- `notes`
- `metadata`

### `transactions`

- One-to-many from `users`
- Keeps store and cashier snapshots for invoice stability

Columns:

- `user_id`
- `invoice_number`
- `store_name_snapshot`
- `store_address_snapshot`
- `store_phone_snapshot`
- `store_logo_path_snapshot`
- `invoice_footer_snapshot`
- `cashier_name_snapshot`
- `cashier_email_snapshot`
- `item_count`
- `subtotal`
- `grand_total`
- `payment_method`
- `payment_status`
- `cash_amount`
- `non_cash_amount`
- `amount_paid`
- `change_amount`
- `due_amount`

### `transaction_items`

- One-to-many from `transactions`
- Holds immutable product snapshots

Columns:

- `transaction_id`
- `product_id`
- `quantity`
- `product_name_snapshot`
- `cost_price_snapshot`
- `selling_price_snapshot`
- `line_subtotal`

## Relationships

- `users 1:1 store_settings`
- `users 1:N products`
- `users 1:N transactions`
- `users 1:N stock_movements`
- `transactions 1:N transaction_items`
- `products 1:N transaction_items` for historical reference only
- `products 1:N stock_movements`

## Why Snapshots Matter

Invoices must still be correct after:

- product names are edited
- product prices are edited
- store details are changed later
- a product is deleted or archived

For that reason, transaction and transaction item rows keep the values that were true when checkout happened.

## Why Stock Ledger Matters

Pembukuan stok sekarang tidak lagi hanya mengandalkan angka `products.stock`.

Setiap perubahan stok akan dicatat ke `stock_movements`, sehingga sistem bisa:

- menjaga catatan stok awal saat produk pertama kali dibuat
- menelusuri stok keluar dari transaksi
- mencatat restock manual
- mencatat penyesuaian manual
- membuat laporan barang menipis / habis / perlu restock
