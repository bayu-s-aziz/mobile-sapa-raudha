# Perubahan Arsitektur: Penghapusan Tabel Admins

## Ringkasan Perubahan
Tabel `admins` telah dihapus dan digabungkan ke dalam tabel `gurus` dengan menambahkan role `'admin'` pada enum role.

## Motivasi
- Simplifikasi struktur database
- Guru dengan role 'admin', 'kepsek', atau 'guru' biasa semua dapat login ke aplikasi mobile dengan fungsi yang sama
- Mengurangi duplikasi kode dan kompleksitas maintenance

## Perubahan Database

### Schema Changes

#### Tabel `gurus`
**Sebelum:**
```sql
role ENUM('guru','kepsek') DEFAULT 'guru'
```

**Sesudah:**
```sql
role ENUM('guru','kepsek','admin') DEFAULT 'guru'
```

#### Tabel `announcements`
**Sebelum:**
```sql
author_type ENUM('admin','guru') NOT NULL
```

**Sesudah:**
```sql
author_type ENUM('guru') NOT NULL DEFAULT 'guru'
```

#### Tabel `admins`
**Status:** DIHAPUS ❌

## Perubahan Backend API

### Endpoints yang Dihapus
- `POST /auth/admin/login` - Tidak diperlukan lagi

### Endpoints yang Diperbarui

#### `POST /auth/guru/login`
- Tetap sama, sekarang juga menangani login untuk role 'admin'

#### `POST /auth/login` (Unified Login)
- Menghapus pengecekan tabel admins
- Hanya mengecek tabel gurus untuk NIK (mencakup admin, guru, kepsek)
- Tetap mengecek tabel parents untuk NISN

#### `GET /announcements`
- Query disederhanakan, hanya JOIN dengan tabel gurus
- Menghapus CASE statement untuk author_type

#### `POST /announcements`
- `author_type` selalu diset ke `'guru'`
- Tidak lagi mengecek role untuk menentukan author_type

#### `GET /profile`
- Role 'admin' sekarang mengambil data dari tabel gurus
- Menggabungkan pengecekan: `if (role === 'admin' || role === 'guru' || role === 'kepsek')`

#### `PUT /profile/photo`
- Update foto untuk role 'admin' sekarang ke tabel gurus

## Migration Path

### Untuk Database Baru
Jalankan file berikut secara berurutan:
1. `schema.sql` - Sudah diperbarui dengan struktur baru
2. `seed.sql` - Sudah diperbarui dengan data sample

### Untuk Database yang Sudah Ada
Jalankan migration script:
```bash
mysql -u root -p sapa_raudha < migrate_remove_admins.sql
```

Script migration akan:
1. Mengubah enum role di tabel gurus
2. Memindahkan semua data dari tabel admins ke gurus
3. Mengupdate author_type di announcements
4. Menghapus tabel admins

## Perubahan Credentials Login

### Admin
**Sebelum:**
- Login menggunakan endpoint khusus `/auth/admin/login`
- Data tersimpan di tabel `admins`

**Sesudah:**
- Login menggunakan `/auth/guru/login` atau `/auth/login`
- Data tersimpan di tabel `gurus` dengan role='admin'
- Credentials default dari seed data:
  - NIK: `1234567890123456`
  - Password: `admin123`

### Guru & Kepala Sekolah
**Tidak ada perubahan** - Tetap menggunakan credentials yang sama

## Fungsi Aplikasi Mobile

Semua role (guru, kepsek, admin) ketika login ke aplikasi mobile akan mendapatkan **fungsi yang sama yaitu fungsi guru**, termasuk:
- Melihat daftar siswa
- Mengubah status kehadiran
- Scan QR code presensi
- Membuat pengumuman
- Konfirmasi izin
- Melihat riwayat presensi

## Akses Web Admin

Guru dengan role 'admin' dapat mengakses fitur-fitur administratif di web interface, seperti:
- Manajemen siswa lengkap (CRUD)
- Manajemen guru
- Manajemen kelas
- Manajemen presensi
- Laporan dan analitik

## Verifikasi

Setelah migration, verifikasi dengan:

```sql
-- Cek data admin sudah pindah
SELECT * FROM gurus WHERE role = 'admin';

-- Cek tidak ada announcements dengan author_type selain 'guru'
SELECT DISTINCT author_type FROM announcements;

-- Cek tabel admins sudah tidak ada
SHOW TABLES LIKE 'admins';
```

## Rollback (Jika Diperlukan)

Jika perlu rollback, Anda harus:
1. Restore database dari backup
2. Kembalikan kode backend ke commit sebelumnya
3. Restart server

**PENTING:** Selalu backup database sebelum menjalankan migration!

## Testing Checklist

- [ ] Login sebagai admin dengan NIK dan password admin
- [ ] Login sebagai guru biasa
- [ ] Login sebagai kepala sekolah
- [ ] Login sebagai orang tua dengan NISN
- [ ] Buat pengumuman sebagai admin
- [ ] Buat pengumuman sebagai guru
- [ ] Edit/delete pengumuman
- [ ] Update foto profil untuk semua role
- [ ] Verifikasi API /profile untuk semua role
- [ ] Scan QR code untuk presensi
- [ ] Ubah status kehadiran siswa

## Catatan Tambahan

- Semua fitur existing tetap berfungsi normal
- Tidak ada breaking changes untuk end users
- Performance tetap sama atau lebih baik (mengurangi 1 tabel dan JOIN)
