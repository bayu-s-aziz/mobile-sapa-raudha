-- Migration Script: Remove Admins Table
-- Tujuan: Mengintegrasikan tabel admins ke dalam tabel gurus
-- Tanggal: 16 Desember 2025

-- PERINGATAN: Backup database terlebih dahulu sebelum menjalankan script ini!

-- Step 1: Tambahkan role 'admin' ke enum role di tabel gurus
ALTER TABLE gurus MODIFY COLUMN role ENUM('guru','kepsek','admin') DEFAULT 'guru';

-- Step 2: Pindahkan data admin ke tabel gurus
INSERT INTO gurus (nik, name, email, phone, role, subject, password_hash, photo_url, created_at, updated_at)
SELECT 
  nik, 
  name, 
  email, 
  phone, 
  'admin' as role,
  'Administrator' as subject,
  password_hash,
  photo_url,
  created_at,
  updated_at
FROM admins;

-- Step 3: Update announcements author_type enum untuk hanya memiliki 'guru'
-- Pertama, update semua announcements yang dibuat oleh admin
UPDATE announcements 
SET author_type = 'guru'
WHERE author_type = 'admin';

-- Step 4: Alter announcements table untuk mengubah enum
ALTER TABLE announcements 
MODIFY COLUMN author_type ENUM('guru') NOT NULL DEFAULT 'guru';

-- Step 5: Drop tabel admins (hati-hati!)
DROP TABLE IF EXISTS admins;

-- Verifikasi hasil migration
SELECT 'Migration completed successfully!' as status;

-- Cek jumlah users dengan role admin di tabel gurus
SELECT COUNT(*) as admin_count FROM gurus WHERE role = 'admin';

-- Cek semua announcements sudah menggunakan author_type 'guru'
SELECT COUNT(*) as announcement_count FROM announcements WHERE author_type = 'guru';
