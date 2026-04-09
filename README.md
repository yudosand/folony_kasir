# Folony Kasir

Folony Kasir adalah sistem point of sale dengan target utama Android. Repository ini berisi backend API Laravel, mobile app Flutter untuk Android, dan admin dashboard web untuk monitoring operasional.

Integrasi eksternal utama proyek ini adalah `Foloni App`, yang dipakai untuk autentikasi pengguna kasir, login admin dashboard, dan pengelolaan member points.

## Cakupan Repository

Repository ini digabung dalam satu codebase, tetapi tetap dibedakan secara struktur:

- backend API Laravel di root project
- admin dashboard web di Laravel views dan routes web
- mobile app Flutter di folder [mobile_app](/C:/Users/user/Desktop/folony_kasir/mobile_app)
- dokumentasi proyek di folder [docs](/C:/Users/user/Desktop/folony_kasir/docs)

## Komponen Utama

### 1. Backend API
Backend dipakai untuk melayani mobile app dan menyimpan seluruh data inti Folony Kasir.

Fungsi utama:
- auth API user kasir
- produk
- transaksi
- invoice
- transaksi manual
- payment logic `cash`, `non_cash`, `split`
- PDF invoice dan rekap transaksi
- bridge auth ke `Foloni App`
- bridge member points ke `Foloni App`

### 2. Mobile App
Mobile app dibangun dengan Flutter dan ditujukan untuk Android.

Fitur utama yang sudah tersedia:
- login nomor HP + password
- register dengan referal
- home produk
- cart dan checkout
- transaksi manual
- invoice PDF
- rekap transaksi PDF
- pembayaran menggunakan member points

### 3. Admin Dashboard
Admin dashboard dibangun di Laravel dan dipakai untuk monitoring data operasional.

Menu utama:
- Dashboard
- Users
- Invoices
- Transactions
- Products
- Member Points

Dashboard juga sudah mendukung export Excel-compatible untuk halaman utama admin.

## Stack

- Laravel
- MySQL
- Laravel Sanctum
- Flutter
- Filesystem-based media storage

## Aturan Bisnis Inti

- target utama client adalah Android
- setiap user mengelola produk miliknya sendiri
- transaksi menyimpan snapshot item dan harga saat checkout
- stok berkurang setelah transaksi berhasil disimpan
- metode pembayaran mendukung `cash`, `non_cash`, dan `split`
- underpayment diperbolehkan dan menjadi `partial`
- invoice harus bisa dibuka ulang, dibagikan, dan diunduh
- image disimpan di filesystem, bukan sebagai binary database
- member points mengikuti source of truth dari `Foloni App`

## Struktur Folder Penting

```text
app/
app/Http/Controllers/Api/
app/Http/Controllers/Admin/
app/Http/Requests/
app/Http/Resources/
app/Models/
app/Services/
database/migrations/
docs/
mobile_app/
resources/views/admin/
routes/api.php
routes/web.php
```

## Menjalankan Backend Secara Lokal

1. Copy file environment.

```bash
cp .env.example .env
```

2. Sesuaikan konfigurasi database dan service.

3. Install dependency PHP.

```bash
composer install
```

4. Generate key.

```bash
php artisan key:generate
```

5. Jalankan migration.

```bash
php artisan migrate
```

6. Buat storage link bila dibutuhkan.

```bash
php artisan storage:link
```

7. Jalankan server lokal.

```bash
php artisan serve
```

## Menjalankan Mobile App

Mobile app berada di:
- [mobile_app](/C:/Users/user/Desktop/folony_kasir/mobile_app)

Command umum:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Endpoint Auth Kasir

- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/logout`
- `GET /api/auth/me`

Mobile app tetap login ke backend `Folony Kasir`, lalu backend menjadi bridge ke `Foloni App` bila diperlukan.

## Dokumentasi

- [docs/api-reference.md](/C:/Users/user/Desktop/folony_kasir/docs/api-reference.md)
- [docs/business-rules.md](/C:/Users/user/Desktop/folony_kasir/docs/business-rules.md)
- [docs/database-schema.md](/C:/Users/user/Desktop/folony_kasir/docs/database-schema.md)
- [docs/admin-dashboard-v1.md](/C:/Users/user/Desktop/folony_kasir/docs/admin-dashboard-v1.md)
- [docs/laporan-resmi-folony-kasir.md](/C:/Users/user/Desktop/folony_kasir/docs/laporan-resmi-folony-kasir.md)

## Pengujian

Backend:

```bash
php artisan test
```

Mobile:

```bash
flutter analyze
flutter test
```

## Catatan

- Web demo awal hanya dipakai sebagai referensi alur dan perilaku, bukan target platform akhir.
- Bila repository ini dibuat private, dokumentasi internal dan struktur proyek dapat tetap disimpan dengan aman di dalam repo.
