-- ============================================================
--  Migrasi: hapus presensi duplikat + pasang PRIMARY KEY & UNIQUE KEY
-- ------------------------------------------------------------
--  Cara pakai (phpMyAdmin):
--    1. Klik nama database aplikasi di panel kiri (harus terpilih).
--    2. Tab SQL / Import -> jalankan berkas ini.
--  Aman dijalankan berulang kali.
--
--  Yang dilakukan:
--    (a) Menyisakan SATU baris per (tanggal, shift, petugas_id).
--        Urutan prioritas baris yang dipertahankan:
--        punya jam keluar > punya foto keluar > punya foto masuk > jam masuk paling awal.
--    (b) Memastikan kolom id adalah PRIMARY KEY.
--    (c) Menambah UNIQUE KEY uq_presensi (tanggal, shift, petugas_id).
--
--  Data asli disalin dulu ke tabel `presensi_cadangan` (hanya pada
--  pemakaian pertama). Hapus tabel itu setelah hasilnya Anda periksa:
--      DROP TABLE presensi_cadangan;
-- ============================================================

-- Cadangan data asli (tidak ditimpa bila sudah ada)
CREATE TABLE IF NOT EXISTS presensi_cadangan AS SELECT * FROM presensi;

SELECT COUNT(*) AS jumlah_baris_sebelum FROM presensi;

-- Tabel baru dengan struktur yang benar
DROP TABLE IF EXISTS presensi_baru;
CREATE TABLE presensi_baru (
  id          VARCHAR(40)  PRIMARY KEY,
  tanggal     DATE         NOT NULL,
  shift       TINYINT      NOT NULL,   -- 1 = Pagi, 2 = Siang
  petugas_id  VARCHAR(40)  NOT NULL,
  nama        VARCHAR(120) NOT NULL,
  masuk       DATETIME     NULL,
  keluar      DATETIME     NULL,
  foto_masuk  VARCHAR(255) NULL,
  foto_keluar VARCHAR(255) NULL,
  updated     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_tanggal (tanggal),
  INDEX idx_petugas (petugas_id),
  UNIQUE KEY uq_presensi (tanggal, shift, petugas_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Salin berurutan dari baris terbaik; baris yang bentrok dengan
-- PRIMARY KEY / UNIQUE KEY (duplikat) dilewati oleh INSERT IGNORE.
INSERT IGNORE INTO presensi_baru
  (id, tanggal, shift, petugas_id, nama, masuk, keluar, foto_masuk, foto_keluar)
SELECT id, tanggal, shift, petugas_id, nama, masuk, keluar, foto_masuk, foto_keluar
FROM presensi
ORDER BY
  tanggal, shift, petugas_id,
  (keluar IS NOT NULL) DESC,
  (foto_keluar IS NOT NULL AND foto_keluar <> '') DESC,
  (foto_masuk  IS NOT NULL AND foto_masuk  <> '') DESC,
  (masuk IS NULL), masuk ASC,
  id ASC;

-- Tukar tabel
RENAME TABLE presensi TO presensi_lama, presensi_baru TO presensi;
DROP TABLE presensi_lama;

SELECT COUNT(*) AS jumlah_baris_sesudah FROM presensi;

-- Harus kosong (tidak ada lagi duplikat):
SELECT tanggal, shift, petugas_id, COUNT(*) AS jumlah
FROM presensi GROUP BY tanggal, shift, petugas_id HAVING COUNT(*) > 1;
