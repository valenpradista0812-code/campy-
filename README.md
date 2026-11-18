# Campy Flutter App

## Menjalankan aplikasi

1. Pastikan backend Campy berjalan dan database Supabase sudah disiapkan sesuai
   [panduan backend](../backend/README.md).
2. Dari direktori `campy-`, jalankan:

   ```bash
   flutter pub get
   flutter run
   ```

Secara default, aplikasi memakai `http://10.0.2.2:5001` pada Android Emulator
dan `http://localhost:5001` pada platform lain. Untuk perangkat fisik atau
alamat backend lain, berikan URL yang dapat dijangkau perangkat:

```bash
flutter run --dart-define=API_URL=http://192.168.1.10:5001
```

Ganti alamat contoh dengan alamat IP komputer yang menjalankan backend.
Perangkat fisik dan komputer harus dapat berkomunikasi di jaringan yang sama.
Jangan masukkan kredensial Supabase atau `service_role` ke dalam aplikasi.

## Pemeriksaan

```bash
flutter analyze
flutter test
```
