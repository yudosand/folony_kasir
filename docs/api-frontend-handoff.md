# API Frontend Handoff

Dokumen ini adalah ringkasan final backend Folony Kasir yang siap dipakai oleh frontend Android.

Backend saat ini sudah mencakup:

- register
- login
- logout
- me
- store setting show/update
- product CRUD
- transaction create/list/show
- invoice payload

## 1. Ringkasan Final Backend

Status backend:

- Laravel API aktif
- Database MySQL berjalan di `folony_pos`
- Migration sudah sukses
- Auth memakai Sanctum token
- One active token policy aktif
- User hanya bisa akses product dan transaction miliknya sendiri
- Checkout memakai snapshot harga dan nama product saat transaksi dibuat
- Stock dikurangi saat transaksi berhasil disimpan
- Underpayment didukung dan akan menjadi `partial`
- Invoice payload bisa dipakai untuk reopen, reprint, dan share

Response standard:

Success:

```json
{
  "success": true,
  "message": "Message",
  "data": {}
}
```

Error:

```json
{
  "success": false,
  "message": "Validation error",
  "errors": {}
}
```

Auth header:

```text
Authorization: Bearer {token}
Accept: application/json
```

Base URL example:

```text
http://127.0.0.1:8000/api
```

## 2. Daftar Endpoint Final

### Auth

- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/logout`
- `GET /api/auth/me`

### Store Setting

- `GET /api/store-setting`
- `PUT /api/store-setting`

### Products

- `GET /api/products`
- `POST /api/products`
- `GET /api/products/{product}`
- `PUT /api/products/{product}`
- `DELETE /api/products/{product}`

### Transactions

- `GET /api/transactions`
- `POST /api/transactions`
- `GET /api/transactions/{transaction}`
- `GET /api/transactions/{transaction}/invoice`

## 3. Request dan Response Contoh

### Register

Request:

```http
POST /api/auth/register
Content-Type: application/json
Accept: application/json
```

```json
{
  "name": "Yudosand",
  "email": "demo@foloni.com",
  "password": "123456"
}
```

Response:

```json
{
  "success": true,
  "message": "Registration successful.",
  "data": {
    "token": "1|plain-text-token",
    "token_type": "Bearer",
    "user": {
      "id": 1,
      "name": "Yudosand",
      "email": "demo@foloni.com",
      "created_at": "2026-03-27T07:19:10.000000Z"
    }
  }
}
```

### Login

Request:

```http
POST /api/auth/login
Content-Type: application/json
Accept: application/json
```

```json
{
  "email": "demo@foloni.com",
  "password": "123456"
}
```

Response:

```json
{
  "success": true,
  "message": "Login successful.",
  "data": {
    "token": "2|plain-text-token",
    "token_type": "Bearer",
    "user": {
      "id": 1,
      "name": "Yudosand",
      "email": "demo@foloni.com",
      "created_at": "2026-03-27T07:19:10.000000Z"
    }
  }
}
```

### Me

Request:

```http
GET /api/auth/me
Authorization: Bearer {token}
Accept: application/json
```

Response:

```json
{
  "success": true,
  "message": "Authenticated user retrieved successfully.",
  "data": {
    "user": {
      "id": 1,
      "name": "Yudosand",
      "email": "demo@foloni.com",
      "created_at": "2026-03-27T07:19:10.000000Z"
    }
  }
}
```

### Store Setting Show

Request:

```http
GET /api/store-setting
Authorization: Bearer {token}
Accept: application/json
```

Response:

```json
{
  "success": true,
  "message": "Store setting retrieved successfully.",
  "data": {
    "store_setting": {
      "id": 1,
      "store_name": "Warung Yudo",
      "store_address": "Jl. Demo POS No. 1",
      "phone_number": "0812-3456-7890",
      "invoice_footer": "Powered by Foloni",
      "logo_path": "store-logos/logo.png",
      "logo_url": "http://127.0.0.1:8000/storage/store-logos/logo.png",
      "created_at": "2026-03-27T07:30:00.000000Z",
      "updated_at": "2026-03-27T07:30:00.000000Z"
    }
  }
}
```

### Store Setting Update

Request:

```http
PUT /api/store-setting
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

```json
{
  "store_name": "Warung Yudo",
  "store_address": "Jl. Demo POS No. 1",
  "phone_number": "0812-3456-7890",
  "invoice_footer": "Powered by Foloni"
}
```

Response:

```json
{
  "success": true,
  "message": "Store setting saved successfully.",
  "data": {
    "store_setting": {
      "id": 1,
      "store_name": "Warung Yudo",
      "store_address": "Jl. Demo POS No. 1",
      "phone_number": "0812-3456-7890",
      "invoice_footer": "Powered by Foloni",
      "logo_path": null,
      "logo_url": null,
      "created_at": "2026-03-27T07:30:00.000000Z",
      "updated_at": "2026-03-27T07:35:00.000000Z"
    }
  }
}
```

### Product List

Request:

```http
GET /api/products?search=indomie&per_page=10
Authorization: Bearer {token}
Accept: application/json
```

Response:

```json
{
  "success": true,
  "message": "Products retrieved successfully.",
  "data": {
    "products": [
      {
        "id": 1,
        "name": "Indomie Goreng",
        "stock": 10,
        "cost_price": 2000,
        "selling_price": 3500,
        "image_path": null,
        "image_url": null,
        "created_at": "2026-03-27T07:40:00.000000Z",
        "updated_at": "2026-03-27T07:40:00.000000Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "last_page": 1,
      "per_page": 10,
      "total": 1
    }
  }
}
```

### Product Create

Request:

```http
POST /api/products
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

```json
{
  "name": "Indomie Goreng",
  "stock": 10,
  "cost_price": 2000,
  "selling_price": 3500
}
```

Response:

```json
{
  "success": true,
  "message": "Product created successfully.",
  "data": {
    "product": {
      "id": 1,
      "name": "Indomie Goreng",
      "stock": 10,
      "cost_price": 2000,
      "selling_price": 3500,
      "image_path": null,
      "image_url": null,
      "created_at": "2026-03-27T07:40:00.000000Z",
      "updated_at": "2026-03-27T07:40:00.000000Z"
    }
  }
}
```

### Product Show

Request:

```http
GET /api/products/1
Authorization: Bearer {token}
Accept: application/json
```

Response:

```json
{
  "success": true,
  "message": "Product retrieved successfully.",
  "data": {
    "product": {
      "id": 1,
      "name": "Indomie Goreng",
      "stock": 10,
      "cost_price": 2000,
      "selling_price": 3500,
      "image_path": null,
      "image_url": null,
      "created_at": "2026-03-27T07:40:00.000000Z",
      "updated_at": "2026-03-27T07:40:00.000000Z"
    }
  }
}
```

### Product Update

Request:

```http
PUT /api/products/1
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

```json
{
  "stock": 12,
  "selling_price": 3600
}
```

Response:

```json
{
  "success": true,
  "message": "Product updated successfully.",
  "data": {
    "product": {
      "id": 1,
      "name": "Indomie Goreng",
      "stock": 12,
      "cost_price": 2000,
      "selling_price": 3600,
      "image_path": null,
      "image_url": null,
      "created_at": "2026-03-27T07:40:00.000000Z",
      "updated_at": "2026-03-27T07:45:00.000000Z"
    }
  }
}
```

### Product Delete

Request:

```http
DELETE /api/products/1
Authorization: Bearer {token}
Accept: application/json
```

Response:

```json
{
  "success": true,
  "message": "Product deleted successfully.",
  "data": {}
}
```

### Transaction Create

Request:

```http
POST /api/transactions
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

```json
{
  "items": [
    {
      "product_id": 1,
      "quantity": 2
    }
  ],
  "payment_method": "cash",
  "cash_amount": 8000
}
```

Response:

```json
{
  "success": true,
  "message": "Transaction saved successfully.",
  "data": {
    "transaction": {
      "id": 1,
      "invoice_number": "INV202603270001",
      "payment_method": "cash",
      "payment_status": "paid",
      "item_count": 2,
      "subtotal": 7200,
      "grand_total": 7200,
      "cash_amount": 8000,
      "non_cash_amount": 0,
      "amount_paid": 8000,
      "change_amount": 800,
      "due_amount": 0,
      "store": {
        "name": "Warung Yudo",
        "address": "Jl. Demo POS No. 1",
        "phone_number": "0812-3456-7890",
        "logo_path": null,
        "logo_url": null,
        "invoice_footer": "Powered by Foloni"
      },
      "cashier": {
        "name": "Yudosand",
        "email": "demo@foloni.com"
      },
      "items": [
        {
          "id": 1,
          "product_id": 1,
          "quantity": 2,
          "product_name_snapshot": "Indomie Goreng",
          "cost_price_snapshot": 2000,
          "selling_price_snapshot": 3600,
          "line_subtotal": 7200
        }
      ],
      "created_at": "2026-03-27T07:50:00.000000Z",
      "updated_at": "2026-03-27T07:50:00.000000Z"
    }
  }
}
```

### Transaction List

Request:

```http
GET /api/transactions?per_page=10
Authorization: Bearer {token}
Accept: application/json
```

Response:

```json
{
  "success": true,
  "message": "Transactions retrieved successfully.",
  "data": {
    "transactions": [
      {
        "id": 1,
        "invoice_number": "INV202603270001",
        "payment_method": "cash",
        "payment_status": "paid",
        "item_count": 2,
        "grand_total": 7200,
        "amount_paid": 8000,
        "change_amount": 800,
        "due_amount": 0,
        "created_at": "2026-03-27T07:50:00.000000Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "last_page": 1,
      "per_page": 10,
      "total": 1
    }
  }
}
```

### Transaction Show

Request:

```http
GET /api/transactions/1
Authorization: Bearer {token}
Accept: application/json
```

Response:

```json
{
  "success": true,
  "message": "Transaction retrieved successfully.",
  "data": {
    "transaction": {
      "id": 1,
      "invoice_number": "INV202603270001",
      "payment_method": "cash",
      "payment_status": "paid",
      "item_count": 2,
      "subtotal": 7200,
      "grand_total": 7200,
      "cash_amount": 8000,
      "non_cash_amount": 0,
      "amount_paid": 8000,
      "change_amount": 800,
      "due_amount": 0,
      "store": {
        "name": "Warung Yudo",
        "address": "Jl. Demo POS No. 1",
        "phone_number": "0812-3456-7890",
        "logo_path": null,
        "logo_url": null,
        "invoice_footer": "Powered by Foloni"
      },
      "cashier": {
        "name": "Yudosand",
        "email": "demo@foloni.com"
      },
      "items": [
        {
          "id": 1,
          "product_id": 1,
          "quantity": 2,
          "product_name_snapshot": "Indomie Goreng",
          "cost_price_snapshot": 2000,
          "selling_price_snapshot": 3600,
          "line_subtotal": 7200
        }
      ],
      "created_at": "2026-03-27T07:50:00.000000Z",
      "updated_at": "2026-03-27T07:50:00.000000Z"
    }
  }
}
```

### Invoice Payload

Request:

```http
GET /api/transactions/1/invoice
Authorization: Bearer {token}
Accept: application/json
```

Response:

```json
{
  "success": true,
  "message": "Invoice payload retrieved successfully.",
  "data": {
    "invoice": {
      "invoice_number": "INV202603270001",
      "issued_at": "2026-03-27T07:50:00.000000Z",
      "store": {
        "name": "Warung Yudo",
        "address": "Jl. Demo POS No. 1",
        "phone_number": "0812-3456-7890",
        "logo_path": null,
        "logo_url": null,
        "invoice_footer": "Powered by Foloni"
      },
      "cashier": {
        "name": "Yudosand",
        "email": "demo@foloni.com"
      },
      "payment": {
        "method": "cash",
        "status": "paid",
        "cash_amount": 8000,
        "non_cash_amount": 0,
        "amount_paid": 8000,
        "change_amount": 800,
        "due_amount": 0
      },
      "totals": {
        "item_count": 2,
        "subtotal": 7200,
        "grand_total": 7200
      },
      "items": [
        {
          "product_name": "Indomie Goreng",
          "quantity": 2,
          "selling_price": 3600,
          "line_subtotal": 7200
        }
      ]
    }
  }
}
```

## 4. Field Penting untuk Frontend Android

### Auth

- `data.token`
  Simpan sebagai bearer token untuk request authenticated.
- `data.token_type`
  Saat ini bernilai `Bearer`.
- `data.user`
  Data user aktif setelah register/login.

### Store Setting

- `store_name`
  Nama toko untuk header invoice dan halaman pengaturan.
- `store_address`
  Alamat toko.
- `phone_number`
  Nomor kontak toko.
- `invoice_footer`
  Footer invoice.
- `logo_url`
  URL logo untuk preview invoice bila ada.

### Product

- `id`
  Dipakai sebagai `product_id` saat checkout.
- `name`
  Nama product.
- `stock`
  Stok yang ditampilkan di daftar product dan home POS.
- `cost_price`
  Harga beli.
- `selling_price`
  Harga jual yang dipakai UI.
- `image_url`
  URL gambar product jika ada.

### Transaction

- `invoice_number`
  ID invoice untuk history dan detail.
- `payment_method`
  Nilai final: `cash`, `non_cash`, `split`
- `payment_status`
  Nilai final: `paid`, `partial`
- `item_count`
  Jumlah item total pada transaksi.
- `grand_total`
  Nilai total transaksi.
- `amount_paid`
  Nilai total pembayaran yang masuk.
- `change_amount`
  Kembalian.
- `due_amount`
  Sisa tagihan jika belum lunas.
- `items`
  Snapshot final item transaksi, bukan membaca ulang dari tabel product.

### Invoice Payload

- `invoice.store`
  Data toko final untuk tampilan invoice.
- `invoice.cashier`
  Data user/kasir pada saat transaksi.
- `invoice.payment`
  Ringkasan pembayaran final.
- `invoice.totals`
  Nilai total final untuk invoice.
- `invoice.items`
  Daftar item final untuk invoice, share, dan print.

## 5. Catatan Implementasi Frontend

- Frontend Android harus selalu mengirim token setelah login.
- Jangan hitung ulang invoice dari product master; gunakan payload transaction/invoice dari backend.
- Untuk checkout, frontend hanya kirim:
  - `items[].product_id`
  - `items[].quantity`
  - `payment_method`
  - `cash_amount`
  - `non_cash_amount`
- Source of truth untuk:
  - stok final
  - status pembayaran
  - due/change
  - nomor invoice
  adalah backend.
