# API Reference

Base URL example:

```text
http://localhost:8000/api
```

All authenticated endpoints require:

```text
Authorization: Bearer {token}
Accept: application/json
```

## Auth

### POST `/auth/register`

Request body:

```json
{
  "name": "Yudosand",
  "phone": "085891585422",
  "password": "123456",
  "password_confirmation": "123456",
  "referal": "FOLONI_ADM01"
}
```

### POST `/auth/login`

Request body:

```json
{
  "phone": "085891585422",
  "password": "123456"
}
```

Optional fields for shared induk auth bridge:

```json
{
  "fcm_token": "",
  "lat": "",
  "long": "",
  "id_device": "folony-kasir-device",
  "os_version": "android"
}
```

### POST `/auth/logout`

Authenticated endpoint.

### GET `/auth/me`

Authenticated endpoint.

## Store Setting

### GET `/store-setting`

Returns the authenticated user's store setting or `null` if not created yet.

### PUT `/store-setting`

Multipart or JSON body:

```json
{
  "store_name": "Warung Yudo",
  "store_address": "Jl. Demo POS No. 1",
  "phone_number": "0812-3456-7890",
  "invoice_footer": "Powered by Foloni - Aplikasi Kasir Demo",
  "remove_logo": false
}
```

Optional multipart file:

```text
logo
```

## Products

### GET `/products`

Query params:

- `search`
- `page`
- `per_page`

### POST `/products`

Multipart or JSON body:

```json
{
  "name": "Indomie Goreng",
  "stock": 100,
  "cost_price": 2500,
  "selling_price": 3500
}
```

Optional multipart file:

```text
image
```

### GET `/products/{id}`

Returns a single owned product.

### PUT `/products/{id}`

Multipart or JSON body:

```json
{
  "name": "Indomie Goreng Jumbo",
  "stock": 120,
  "selling_price": 4000,
  "remove_image": false
}
```

Optional multipart file:

```text
image
```

### DELETE `/products/{id}`

Soft deletes the owned product.

## Transactions

### GET `/transactions`

Query params:

- `search`
- `payment_method`
- `payment_status`
- `date_from`
- `date_to`
- `page`
- `per_page`

### POST `/transactions`

Request body:

```json
{
  "items": [
    {
      "product_id": 1,
      "quantity": 2
    },
    {
      "product_id": 3,
      "quantity": 1
    }
  ],
  "member_id": 11,
  "points_used": 10000,
  "payment_method": "split",
  "cash_amount": 10000,
  "non_cash_amount": 5000
}
```

Rules:

- `payment_method` supports `cash`, `non_cash`, `split`
- Underpayment is allowed
- Product ownership is validated
- Product stock must be sufficient
- Product prices are snapped from the master product at transaction time
- Member points are optional
- `member_id` and `points_used` must be sent together
- `1 poin = Rp1`
- `points_used` cannot exceed the product subtotal
- When member points are used, `grand_total` becomes `subtotal - points_used`
- After Folony Kasir requests a point deduction, it verifies the deduction against Foloni App. It first re-checks the member balance and may fall back to the matching point history entry when the provider history updates faster than the member balance endpoint

### GET `/transactions/{id}`

Returns the owned transaction detail plus item snapshots.

### GET `/transactions/{id}/invoice`

Returns invoice data for re-open, print, or sharing use cases.

## Member Points

### GET `/member-points/members`

Authenticated endpoint. This route is served by Folony Kasir, then bridged server-side to Foloni App using the configured admin credential.

Query params:

- `member_id` optional exact lookup to Foloni App member id

Example response payload:

```json
{
  "members": [
    {
      "id": 11,
      "name": "yudosand",
      "points": 10982265
    }
  ],
  "total_records": 1
}
```

### POST `/member-points/mutations`

Authenticated endpoint. This route is served by Folony Kasir, then bridged server-side to Foloni App using the configured admin credential.

Request body:

```json
{
  "member_id": 11,
  "type": "2",
  "amount": 10000,
  "description": "Potong poin untuk transaksi manual QA"
}
```

Rules:

- `type=1` adds points
- `type=2` subtracts points
- `amount` is sent to Foloni App as the exact point amount string
- mobile clients must never call Foloni App admin endpoints directly

## Notes

- `non_cash` transactions never return `change_amount`
- `cash` and `split` can return `change_amount` when overpaid
- `payment_status` becomes `partial` when `due_amount > 0`
- Invoice numbers follow the pattern `INVYYYYMMDDNNNN`
- Member points remain sourced from Foloni App; mobile clients must never call Foloni App admin endpoints directly
