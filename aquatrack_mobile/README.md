# AQUATRACK Mobile

Flutter mobile app for AQUATRACK, connected to Laravel API.

## 1) Run Backend (Laravel)

Masuk ke folder backend:

```bash
cd ../aquatrack_backend
```

Pastikan `.env` MySQL sudah benar, lalu:

```bash
php artisan key:generate
php artisan migrate:fresh --seed
php artisan serve --host=0.0.0.0 --port=8000
```

Ambil IP LAN laptop/PC kamu (contoh `192.168.1.10`):

```bash
hostname -I
```

## 2) Run Mobile (Flutter)

Masuk ke folder mobile:

```bash
cd ../aquatrack_mobile
flutter pub get
```

### Android Emulator

```bash
flutter run
```

Default emulator pakai `http://10.0.2.2:8000/api/v1`.

### HP Android eksternal (wireless)

Atur IP LAN backend di file berikut:

- `lib/core/config/app_config.dart`
- Ubah `serverHost` menjadi IP laptop/PC kamu (contoh `192.168.1.10`)

Setelah itu cukup jalankan:

```bash
flutter run
```

## 3) Akun Login Seeder

- Admin: `admin@aquatrack.test` / `password`
- Penagih: `penagih@aquatrack.test` / `password`
- Pelanggan: `pelanggan1@aquatrack.test` / `password`

## 4) Kenapa HP tidak bisa login? Checklist

1. HP dan laptop harus di WiFi yang sama.
2. Jalankan backend dengan `--host=0.0.0.0`.
3. Pastikan `serverHost` di `lib/core/config/app_config.dart` sudah benar.
4. Cek firewall OS (port `8000` harus terbuka).
5. Uji dari browser HP:
   - `http://<IP-LAN>:8000/up` harus tampil status Laravel.
6. Jika endpoint sudah benar tapi login gagal, jalankan:
   - `php artisan migrate:fresh --seed`
   - lalu login dengan akun seeder di atas.

## 5) Verifikasi Cepat API

Test manual dari terminal:

```bash
curl -X POST http://<IP-LAN>:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@aquatrack.test","password":"password"}'
```

Jika ini sukses, mobile harus bisa login dengan base URL yang sama.
