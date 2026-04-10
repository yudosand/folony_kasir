# Dev VPS Bootstrap

Dokumen ini dipakai saat SSH dari luar belum stabil, sehingga setup server dilakukan lewat web console provider dengan **1 command pendek**.

## File bootstrap

Script bootstrap ada di:

- `scripts/dev-bootstrap.sh`

## Cara pakai cepat

Setelah perubahan ini sudah dipush ke GitHub dan repo bisa diakses dari VPS, jalankan:

```bash
curl -fsSL https://raw.githubusercontent.com/yudosand/folony_kasir/master/scripts/dev-bootstrap.sh | bash
```

## Catatan penting

- Kalau repo masih private, `raw.githubusercontent.com` tidak akan bisa diakses tanpa autentikasi.
- Opsi paling mudah adalah membuat repo **public sementara** saat bootstrap pertama, lalu kembalikan ke private setelah server siap.
- Script akan meminta input interaktif untuk:
  - nama database
  - user database
  - password database
  - URL API `Foloni App`
  - kredensial admin `Foloni App`
- Script akan:
  - install dependency server utama
  - perbaiki config default Nginx agar tidak memakai IPv6 listen yang bentrok di image VPS ini
  - buat database dan user MySQL
  - clone / update repo
  - isi `.env`
  - jalankan `composer install`
  - jalankan `npm install`
  - build asset Vite
  - jalankan migration
  - setup Nginx untuk Laravel

## Setelah bootstrap

Verifikasi dasar:

```bash
cd /var/www/folony_kasir
php artisan about
php artisan route:list
sudo systemctl status nginx
sudo systemctl status php8.3-fpm
```
