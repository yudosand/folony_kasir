# Windows Android Runtime - Phase 1

Dokumen ini fokus untuk menjalankan Flutter app Phase 1 Folony Kasir di Android emulator pada Windows.

## Yang sudah disiapkan di project

- Base URL default emulator sudah memakai `http://10.0.2.2:8000/api`
- Android debug build sudah diizinkan mengakses backend HTTP lokal
- Permission internet sudah ada di manifest utama
- Namespace Android sudah memakai `com.folony.kasir`

File terkait:

- [mobile_app/lib/core/network/network_config.dart](/C:/Users/user/Desktop/folony_kasir/mobile_app/lib/core/network/network_config.dart)
- [mobile_app/android/app/src/main/AndroidManifest.xml](/C:/Users/user/Desktop/folony_kasir/mobile_app/android/app/src/main/AndroidManifest.xml)
- [mobile_app/android/app/src/debug/AndroidManifest.xml](/C:/Users/user/Desktop/folony_kasir/mobile_app/android/app/src/debug/AndroidManifest.xml)

## 1. Cek atau install Android Studio

Kalau Android Studio belum ada, install dari:

- [https://developer.android.com/studio](https://developer.android.com/studio)

Saat installer berjalan, pastikan komponen ini ikut terpasang:

- Android SDK
- Android SDK Platform
- Android Virtual Device
- Android SDK Command-line Tools
- Android Emulator

## 2. Environment yang dipakai di repo ini

Di Windows Terminal, dari root project:

```powershell
cd C:\Users\user\Desktop\folony_kasir

$env:JAVA_HOME='C:\Users\user\Desktop\folony_kasir\tools\java\jdk-17.0.17+10'
$env:ANDROID_SDK_ROOT='C:\Users\user\Desktop\folony_kasir\tools\android-sdk'
$env:ANDROID_AVD_HOME='C:\Users\user\Desktop\folony_kasir\temp\android-avd'
$env:ANDROID_EMULATOR_HOME='C:\Users\user\Desktop\folony_kasir\temp\android-emulator-home'
$env:ANDROID_USER_HOME='C:\Users\user\Desktop\folony_kasir\temp\android-user-home'
$env:APPDATA='C:\Users\user\Desktop\folony_kasir\temp\flutter_appdata'
$env:LOCALAPPDATA='C:\Users\user\Desktop\folony_kasir\temp\flutter_localappdata'
```

Kalau kamu memilih memakai Android Studio global, kamu boleh ganti `JAVA_HOME` dan `ANDROID_SDK_ROOT` ke lokasi instalasi global milikmu.

## 3. Cek Flutter doctor

```powershell
.\\tools\\flutter\\bin\\flutter.bat doctor -v
```

Target minimal yang harus hijau:

- `Flutter`
- `Android toolchain`

## 4. Buat emulator

List profile device:

```powershell
& '.\tools\android-sdk\cmdline-tools\latest\bin\avdmanager.bat' list device
```

Buat AVD:

```powershell
'no' | & '.\tools\android-sdk\cmdline-tools\latest\bin\avdmanager.bat' create avd -n Folony_API_35 -k 'system-images;android-35;google_apis;x86_64' -d pixel_6
```

List AVD:

```powershell
& '.\tools\android-sdk\emulator\emulator.exe' -list-avds
```

## 5. Jalankan emulator

Mode normal:

```powershell
& '.\tools\android-sdk\emulator\emulator.exe' -avd Folony_API_35
```

Mode headless:

```powershell
& '.\tools\android-sdk\emulator\emulator.exe' -avd Folony_API_35 -no-window -no-audio -no-boot-anim -no-snapshot -no-metrics
```

Cek device:

```powershell
& '.\tools\android-sdk\platform-tools\adb.exe' devices -l
```

Kalau emulator hidup, akan muncul device seperti `emulator-5554`.

## 6. Jalankan backend lokal

Backend Laravel harus hidup dulu:

```powershell
cd C:\Users\user\Desktop\folony_kasir
& 'C:\xampp\php\php.exe' artisan serve --host=0.0.0.0 --port=8000
```

Untuk Android emulator, `10.0.2.2` otomatis mengarah ke host Windows kamu, jadi app tidak perlu ganti base URL lagi selama backend jalan di port `8000`.

## 7. Jalankan app Flutter ke Android

Di terminal baru:

```powershell
cd C:\Users\user\Desktop\folony_kasir\mobile_app

$env:JAVA_HOME='C:\Users\user\Desktop\folony_kasir\tools\java\jdk-17.0.17+10'
$env:ANDROID_SDK_ROOT='C:\Users\user\Desktop\folony_kasir\tools\android-sdk'
$env:ANDROID_AVD_HOME='C:\Users\user\Desktop\folony_kasir\temp\android-avd'
$env:ANDROID_EMULATOR_HOME='C:\Users\user\Desktop\folony_kasir\temp\android-emulator-home'
$env:ANDROID_USER_HOME='C:\Users\user\Desktop\folony_kasir\temp\android-user-home'
$env:APPDATA='C:\Users\user\Desktop\folony_kasir\temp\flutter_appdata'
$env:LOCALAPPDATA='C:\Users\user\Desktop\folony_kasir\temp\flutter_localappdata'

..\tools\flutter\bin\flutter.bat pub get
..\tools\flutter\bin\flutter.bat run -d emulator-5554
```

Kalau kamu mau override base URL secara manual:

```powershell
..\tools\flutter\bin\flutter.bat run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

## 8. Test login/register ke backend lokal

Lakukan urutan ini di emulator:

1. Buka app
2. Tekan `Daftar`
3. Isi nama, email unik, dan password minimal 6 karakter
4. Submit register
5. App harus masuk ke halaman home Phase 1
6. Tutup app lalu buka lagi
7. App harus restore session otomatis lewat `/auth/me`
8. Tekan `Logout`
9. Login lagi dengan akun yang sama

## 9. Troubleshooting

### Flutter doctor belum hijau

Pastikan:

- `JAVA_HOME` benar
- `ANDROID_SDK_ROOT` benar
- command-line tools, platform-tools, emulator, dan platform Android sudah terpasang

### Emulator tidak muncul di `adb devices`

Coba:

```powershell
& '.\tools\android-sdk\platform-tools\adb.exe' kill-server
& '.\tools\android-sdk\platform-tools\adb.exe' start-server
& '.\tools\android-sdk\platform-tools\adb.exe' devices -l
```

### Emulator langsung tertutup

Kemungkinan terbesar:

- fitur virtualisasi Windows belum aktif
- Hyper-V / Windows Hypervisor Platform belum aktif
- BIOS virtualization belum aktif

Perintah admin yang biasanya dibutuhkan:

```powershell
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
dism.exe /online /enable-feature /featurename:HypervisorPlatform /all /norestart
```

Untuk Windows Pro, kadang perlu juga:

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Hyper-V-All /all /norestart
```

Setelah itu restart Windows lalu coba lagi.

### App tidak bisa akses backend lokal

Pastikan:

- backend Laravel jalan di `0.0.0.0:8000`
- emulator memakai `10.0.2.2`, bukan `127.0.0.1`
- app dijalankan dalam mode debug

### Kalau pakai device fisik, bukan emulator

`10.0.2.2` tidak berlaku. Pakai IP LAN laptop/PC kamu:

```powershell
..\tools\flutter\bin\flutter.bat run --dart-define=API_BASE_URL=http://192.168.x.x:8000/api
```
