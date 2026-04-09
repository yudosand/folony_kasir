# Admin Dashboard

## Scope
Dashboard admin v1 untuk Folony Kasir adalah web dashboard server-rendered di Laravel yang dipakai untuk monitoring operasional.

## Auth
- Login admin memakai endpoint admin `Foloni App`.
- Session dashboard admin terpisah dari auth mobile/API user kasir.

Environment yang dipakai:
- `ADMIN_DASHBOARD_PATH`
- `ADMIN_DASHBOARD_SESSION_KEY`
- `ADMIN_DASHBOARD_NAME`

Dashboard admin login ke:
- `POST /adm/user/login` pada `Foloni App`

## Menu
- Dashboard
- Users
- Invoices
- Transactions
- Products
- Member Points

## Dashboard
Menampilkan ringkasan:
- total user
- total produk
- total transaksi
- total omzet
- total tagihan belum lunas
- total nilai poin yang dipakai
- daftar invoice terbaru
- daftar user terbaru
- performa 7 hari terakhir

## Users
List user menampilkan:
- nama
- kontak
- tanggal bergabung
- total transaksi
- total produk
- omzet user

Export:
- Excel-compatible export mengikuti filter aktif di halaman

Detail user menampilkan:
- profil user
- member id Foloni App
- total transaksi
- total produk
- total omzet
- total kurang bayar
- daftar produk milik user
- daftar transaksi terbaru user

## Invoices
List invoice menampilkan:
- tanggal
- nomor invoice
- nama user
- total item
- harga total
- metode pembayaran
- status pembayaran

Filter invoice:
- search
- payment method
- payment status
- date from
- date to

Export:
- Excel-compatible export mengikuti filter aktif di halaman

Detail invoice menampilkan:
- ringkasan invoice
- item transaksi
- detail pembayaran
- detail penggunaan poin member jika ada

## Transactions
Halaman transaksi fokus pada monitoring operasional:
- tanggal
- invoice
- user
- metode pembayaran
- grand total
- total dibayar
- kurang bayar
- poin yang dipakai
- status pembayaran

Filter transaksi:
- search
- payment method
- payment status
- date from
- date to

Export:
- Excel-compatible export mengikuti filter aktif di halaman

## Products
Halaman produk global menampilkan:
- nama produk
- pemilik
- stok
- harga modal
- harga jual
- total quantity sold

Export:
- Excel-compatible export mengikuti filter aktif di halaman

Detail produk menampilkan:
- ringkasan produk
- pemilik
- kontak pemilik
- stok
- harga
- total qty terjual
- riwayat penjualan terkait

## Member Points
Halaman ini menampilkan transaksi yang memakai poin member:
- tanggal
- invoice
- user kasir
- member
- jumlah poin
- nilai rupiah
- status sinkronisasi

Export:
- Excel-compatible export mengikuti filter aktif di halaman

## Route Utama
- `/admin/login`
- `/admin`
- `/admin/users`
- `/admin/users/{user}`
- `/admin/invoices`
- `/admin/invoices/{transaction}`
- `/admin/transactions`
- `/admin/products`
- `/admin/products/{product}`
- `/admin/member-points`
