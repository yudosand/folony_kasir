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
- `cost_price`
- `selling_price`
- `image_path`

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
- `transactions 1:N transaction_items`
- `products 1:N transaction_items` for historical reference only

## Why Snapshots Matter

Invoices must still be correct after:

- product names are edited
- product prices are edited
- store details are changed later
- a product is deleted or archived

For that reason, transaction and transaction item rows keep the values that were true when checkout happened.
