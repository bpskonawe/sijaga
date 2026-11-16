# SIJAGA

**Sistem Informasi Jadwal Petugas Pelayanan** — BPS Kabupaten Konawe.

Aplikasi web untuk jadwal piket dan presensi petugas loket pelayanan: petugas
mencatat jam masuk/pulang beserta foto atribut dari HP, layar loket menampilkan
petugas yang bertugas, dan admin mengelola jadwal, petugas, serta rekap.

- **Aplikasi produksi**: `public/standalone/` (HTML + JS murni + `api/api.php` + MySQL di XAMPP).
  Petunjuk pasang: `public/standalone/BACA-SAYA.txt` atau `panduan.html`.
- **Halaman pratinjau React**: `src/App.tsx` (`npm install && npm run dev`).
- **Database**: impor `public/standalone/database/sijaga.sql`. Untuk database lama,
  jalankan juga `public/standalone/database/migrasi_hapus_duplikat.sql`.
