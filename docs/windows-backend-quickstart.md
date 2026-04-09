# Windows Backend Quickstart

Dokumentasi ini untuk menjalankan backend Folony Kasir di Windows dengan:

- PHP XAMPP: `C:\xampp\php\php.exe`
- MySQL80
- Project path: `C:\Users\user\Desktop\folony_kasir`

## 1. Jalankan Project

Buka Windows Terminal:

```powershell
cd C:\Users\user\Desktop\folony_kasir
& "C:\xampp\php\php.exe" artisan serve --host=127.0.0.1 --port=8000
```

Backend akan aktif di:

```text
http://127.0.0.1:8000
```

## 2. Contoh `.env` MySQL

Gunakan konfigurasi seperti ini di `.env`:

```env
APP_NAME="Folony Kasir API"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://127.0.0.1:8000

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=folony_pos
DB_USERNAME=root
DB_PASSWORD=root

SESSION_DRIVER=file
CACHE_STORE=file
QUEUE_CONNECTION=sync
FILESYSTEM_DISK=public
```

## 3. Perintah Migration

```powershell
cd C:\Users\user\Desktop\folony_kasir
& "C:\xampp\php\php.exe" artisan config:clear
& "C:\xampp\php\php.exe" artisan migrate
```

Kalau perlu reset semua tabel:

```powershell
& "C:\xampp\php\php.exe" artisan migrate:fresh
```

## 4. Perintah `storage:link`

```powershell
cd C:\Users\user\Desktop\folony_kasir
& "C:\xampp\php\php.exe" artisan storage:link
```

## 5. Test Endpoint Utama

### Register

```powershell
curl.exe -X POST "http://127.0.0.1:8000/api/auth/register" `
  -H "Accept: application/json" `
  -H "Content-Type: application/json" `
  -d "{\"name\":\"Demo User\",\"email\":\"demo@example.com\",\"password\":\"123456\"}"
```

### Login

```powershell
curl.exe -X POST "http://127.0.0.1:8000/api/auth/login" `
  -H "Accept: application/json" `
  -H "Content-Type: application/json" `
  -d "{\"email\":\"demo@example.com\",\"password\":\"123456\"}"
```

Simpan token dari response:

```powershell
$token = "PASTE_TOKEN_DI_SINI"
```

### Me

```powershell
curl.exe -X GET "http://127.0.0.1:8000/api/auth/me" `
  -H "Accept: application/json" `
  -H "Authorization: Bearer $token"
```

### Store Setting Update

```powershell
curl.exe -X PUT "http://127.0.0.1:8000/api/store-setting" `
  -H "Accept: application/json" `
  -H "Authorization: Bearer $token" `
  -H "Content-Type: application/json" `
  -d "{\"store_name\":\"Warung Demo\",\"store_address\":\"Jl. Demo No. 1\",\"phone_number\":\"081234567890\",\"invoice_footer\":\"Powered by Folony\"}"
```

### Create Product

```powershell
curl.exe -X POST "http://127.0.0.1:8000/api/products" `
  -H "Accept: application/json" `
  -H "Authorization: Bearer $token" `
  -H "Content-Type: application/json" `
  -d "{\"name\":\"Indomie Goreng\",\"stock\":10,\"cost_price\":2000,\"selling_price\":3500}"
```

### List Products

```powershell
curl.exe -X GET "http://127.0.0.1:8000/api/products" `
  -H "Accept: application/json" `
  -H "Authorization: Bearer $token"
```

### Create Transaction

```powershell
curl.exe -X POST "http://127.0.0.1:8000/api/transactions" `
  -H "Accept: application/json" `
  -H "Authorization: Bearer $token" `
  -H "Content-Type: application/json" `
  -d "{\"items\":[{\"product_id\":1,\"quantity\":2}],\"payment_method\":\"cash\",\"cash_amount\":8000}"
```

### List Transactions

```powershell
curl.exe -X GET "http://127.0.0.1:8000/api/transactions" `
  -H "Accept: application/json" `
  -H "Authorization: Bearer $token"
```

### Transaction Detail

```powershell
curl.exe -X GET "http://127.0.0.1:8000/api/transactions/1" `
  -H "Accept: application/json" `
  -H "Authorization: Bearer $token"
```

### Invoice Payload

```powershell
curl.exe -X GET "http://127.0.0.1:8000/api/transactions/1/invoice" `
  -H "Accept: application/json" `
  -H "Authorization: Bearer $token"
```

## 6. Troubleshooting Singkat

### `could not find driver`

Biasanya PHP yang dipakai bukan PHP XAMPP atau `pdo_mysql` belum aktif.

Pakai:

```powershell
& "C:\xampp\php\php.exe" -m
```

Pastikan ada:

- `pdo_mysql`
- `mbstring`

### `Access denied for user 'root'@'localhost'`

Cek ulang `.env`:

```env
DB_USERNAME=root
DB_PASSWORD=root
```

Lalu clear config:

```powershell
& "C:\xampp\php\php.exe" artisan config:clear
```

### `SQLSTATE[HY000] [2002] Connection refused`

MySQL80 belum aktif atau port salah.

Cek service:

```powershell
Get-Service MySQL80
```

### `Class not found` atau autoload bermasalah

Jalankan:

```powershell
composer install
composer dump-autoload
```

### Link storage belum ada

Jalankan ulang:

```powershell
& "C:\xampp\php\php.exe" artisan storage:link
```
