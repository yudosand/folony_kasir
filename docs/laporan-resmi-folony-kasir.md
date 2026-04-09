# Laporan Resmi Proyek Folony Kasir

## Ringkasan Proyek
Folony Kasir adalah aplikasi point of sale yang ditargetkan untuk platform Android, dengan backend API Laravel dan dashboard admin berbasis web. Proyek ini dibangun dengan pendekatan backend-first dan API-first agar siap melayani client Android secara konsisten, terstruktur, dan mudah dikembangkan.

Selain fitur inti kasir, sistem ini juga terintegrasi dengan `Foloni App` untuk kebutuhan autentikasi pengguna kasir dan pengelolaan member points.

## Tujuan Pengembangan
- Menyediakan aplikasi kasir Android yang ringan, rapi, dan siap dipakai untuk operasional dasar.
- Menyediakan backend yang terstruktur untuk produk, transaksi, invoice, pembayaran, dan integrasi eksternal.
- Menyediakan dashboard admin untuk monitoring user, invoice, transaksi, produk, dan penggunaan member points.
- Menjaga agar integrasi dengan `Foloni App` tetap aman dengan pola server-to-server.

## Arsitektur Sistem

### Mobile App
- Flutter
- Target utama Android

### Backend
- Laravel API
- MySQL
- Sanctum token auth

### Admin Dashboard
- Laravel server-rendered web dashboard

### Integrasi Eksternal
- `Foloni App` untuk:
  - login dan register user kasir
  - lookup member points
  - mutasi tambah dan kurang poin
  - login admin dashboard

## Hasil Pengembangan Mobile App

### 1. Autentikasi Pengguna Kasir
Fitur autentikasi mobile telah disesuaikan dengan pola `Foloni App`.

Login:
- nomor HP
- password

Register:
- nama
- nomor HP
- password
- konfirmasi password
- referal

Perilaku penting:
- register sukses langsung auto-login
- backend `Folony Kasir` menjadi bridge ke API `Foloni App`
- data penting user disimpan di database lokal `Folony Kasir`
- payload login dari `Foloni App` juga disimpan sebagai snapshot JSON untuk kebutuhan integrasi lanjutan

### 2. Produk
Fitur produk yang telah selesai:
- tambah produk
- edit produk
- hapus produk
- upload foto produk
- ambil foto dari galeri atau kamera
- hapus foto produk
- tap item produk langsung membuka form edit

Setiap user mengelola produk miliknya sendiri sesuai business rule yang telah disepakati.

### 3. Home dan Cart
Perbaikan perilaku home dan cart yang telah selesai:
- pola `+` lalu berubah menjadi `- qty +`
- penyesuaian quantity tanpa snackbar yang mengganggu
- warning hanya muncul saat stok mentok
- konsistensi warna, radius, dan header

### 4. Checkout dan Pembayaran
Metode pembayaran yang didukung:
- `cash`
- `non_cash`
- `split`

Aturan pembayaran yang sudah diterapkan:
- underpayment diperbolehkan
- status pembayaran menjadi `partial` bila belum lunas
- `change_amount`, `due_amount`, dan `amount_paid` dihitung sesuai business rule

### 5. Transaksi Manual
Fitur transaksi manual telah selesai dan mendukung:
- ambil item dari master produk
- tambah item manual
- campuran item produk dan item manual dalam satu transaksi

UX item manual dibuat sederhana:
- user isi nama item terlebih dahulu
- setelah nama terisi, field qty dan harga baru muncul
- field harga memakai format rupiah yang konsisten

### 6. Invoice
Fitur invoice yang sudah tersedia:
- invoice dapat dibuka ulang
- invoice dapat dibagikan
- invoice dapat diunduh menjadi PDF
- isi invoice menyesuaikan metode pembayaran dan penggunaan poin

### 7. Rekap Transaksi PDF
Fitur rekap transaksi PDF telah dibuat dengan pendekatan sederhana untuk data yang banyak.

Pilihan filter saat download:
- semua transaksi
- hari ini
- minggu ini
- bulan ini
- rentang tanggal

Format rekap dibuat ringkas:
- tanggal
- invoice
- barang
- pembayaran
- nominal
- status

Kolom barang diringkas, misalnya `3 item`, agar laporan tetap mudah dibaca ketika transaksi banyak.

### 8. Lokasi File Download
File PDF diarahkan ke folder yang mudah diakses user:
- `Download/FolonyKasir/Invoices`
- `Download/FolonyKasir/Reports`

## Integrasi Dengan Foloni App

### 1. Auth Bridge
`Folony Kasir` tidak melakukan login langsung dari mobile ke `Foloni App`. Backend `Folony Kasir` menjadi bridge agar:
- kontrak mobile tetap stabil
- token eksternal tidak bocor ke client
- data user bisa disimpan lokal dengan aman

### 2. Data User Yang Disimpan
Data user dari `Foloni App` disimpan dalam dua bentuk:
- field terstruktur untuk kebutuhan query dan operasional
- payload JSON mentah untuk kebutuhan integrasi berikutnya

Contoh data yang disimpan:
- member id
- nomor HP
- nama
- email
- account type
- lokasi default
- saldo dan point snapshot
- payload eksternal lengkap

### 3. Member Points
Integrasi member points telah selesai di sisi backend dan mobile.

Alur yang sudah berjalan:
- kasir cek member dari backend `Folony Kasir`
- backend login admin ke `Foloni App`
- backend mengambil data member dan poin
- user mengisi jumlah poin yang ingin dipakai
- backend `Folony Kasir` melakukan request pengurangan poin ke `Foloni App`

Aturan bisnis yang diterapkan:
- `1 poin = Rp1`
- poin dapat mengurangi total transaksi
- jika poin menutup seluruh tagihan, metode pembayaran pada invoice menjadi `Poin`
- jika poin hanya menutup sebagian, metode pembayaran tunai, non tunai, atau split menghitung sisa setelah potongan poin

Pengaman integrasi:
- transaksi tidak dianggap sukses bila potongan poin belum terkonfirmasi
- backend melakukan verifikasi melalui saldo member atau riwayat poin pada `Foloni App`

## Hasil Pengembangan Admin Dashboard

### 1. Login Admin
Dashboard admin tidak lagi memakai akun lokal terpisah. Login admin menggunakan endpoint admin `Foloni App`.

### 2. Dashboard Ringkasan
Halaman dashboard menampilkan:
- total user
- total produk
- total transaksi
- total omzet
- total tagihan belum lunas
- total nilai poin yang dipakai
- invoice terbaru
- user terbaru
- performa 7 hari terakhir

### 3. Users
Halaman users menampilkan:
- nama user
- kontak
- tanggal bergabung
- total transaksi
- total produk
- omzet user

Detail user menampilkan:
- profil user
- member id `Foloni App`
- total transaksi
- total produk
- total omzet
- total kurang bayar
- daftar produk milik user
- daftar transaksi terbaru user

### 4. Invoices
Halaman invoices menampilkan:
- tanggal
- nomor invoice
- nama user
- total item
- harga total
- metode pembayaran
- status pembayaran

Detail invoice menampilkan:
- ringkasan invoice
- item transaksi
- detail pembayaran
- detail penggunaan poin member

### 5. Transactions
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

### 6. Products
Halaman produk global menampilkan:
- nama produk
- pemilik
- stok
- harga modal
- harga jual
- total quantity sold

Detail produk menampilkan:
- ringkasan produk
- pemilik
- kontak pemilik
- stok
- harga
- total qty terjual
- riwayat penjualan terkait

### 7. Member Points
Halaman ini digunakan untuk monitoring transaksi yang memakai poin member.

Informasi yang tersedia:
- tanggal
- invoice
- user kasir
- member
- jumlah poin
- nilai rupiah
- status sinkronisasi

### 8. Export Excel
Dashboard admin sudah mendukung export Excel-compatible untuk:
- users
- invoices
- transactions
- products
- member points

Export mengikuti filter aktif pada halaman masing-masing.

## Pengujian Dan Validasi

### Mobile
- `flutter analyze` dijalankan berulang pada perubahan besar
- `flutter test` dijalankan untuk memvalidasi logika utama
- APK debug dan release berhasil dibuild
- pengujian manual dilakukan di device Android yang terhubung

### Backend
- `php artisan test` dijalankan untuk feature test dan alur utama
- validasi positif dan negatif dilakukan untuk:
  - auth
  - produk
  - transaksi
  - invoice
  - member points

### Admin Dashboard
- route admin tervalidasi
- login admin tervalidasi
- export Excel tervalidasi
- feature test admin dashboard lulus

## Status Proyek Saat Ini
Secara fungsional, `Folony Kasir` sudah berada pada tahap layak untuk internal testing dan operasional dasar.

Area yang sudah stabil:
- mobile app kasir inti
- auth terintegrasi dengan `Foloni App`
- transaksi manual
- invoice dan rekap PDF
- member points
- admin dashboard v1
- export Excel admin

## Catatan Pengembangan Lanjutan
Area yang masih dapat dikembangkan pada fase berikutnya:
- export PDF dari admin dashboard
- role dan permission admin
- audit log admin
- pencarian member yang lebih fleksibel
- penyempurnaan UI dashboard admin
- laporan lanjutan per user, metode pembayaran, dan periode

## Kesimpulan
Proyek `Folony Kasir` telah berkembang dari referensi alur berbasis demo menjadi sistem yang terdiri dari:
- aplikasi mobile Android-ready
- backend API Laravel yang terstruktur
- integrasi aman dengan `Foloni App`
- dashboard admin untuk monitoring dan export data

Fondasi teknis dan fungsional yang sudah dibangun saat ini cukup kuat untuk melanjutkan ke tahap refinement, perluasan laporan, dan penguatan operasional.
