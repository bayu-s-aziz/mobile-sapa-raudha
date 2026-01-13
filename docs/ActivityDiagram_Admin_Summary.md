# Activity Diagram - Admin (Sapa Raudha)

Dokumen ini berisi penjelasan tentang activity diagram untuk fitur-fitur admin pada aplikasi Sapa Raudha.

## Daftar Activity Diagram Admin

### 1. Activity Diagram - Admin Login
**File:** `activity_admin_login.mdj`

**Deskripsi:**
Activity diagram untuk proses login admin pada aplikasi Sapa Raudha (Web Admin).

**Alur Proses:**
1. Admin membuka halaman web admin
2. Admin memasukkan NIK dan password
3. Admin klik tombol login
4. Sistem melakukan validasi kredensial (cek NIK dan password hash)
5. **Decision:** Kredensial valid?
   - **Ya:** 
     - Sistem membuat sesi login
     - Redirect ke dashboard admin
     - Selesai
   - **Tidak:**
     - Tampilkan pesan error
     - Kembali ke halaman login (admin dapat mencoba lagi)

---

### 2. Activity Diagram - Admin Kelola Data Guru
**File:** `activity_admin_kelola_guru.mdj`

**Deskripsi:**
Activity diagram untuk proses kelola data guru (tambah, edit, hapus) oleh admin.

**Alur Proses:**
1. Admin membuka menu "Kelola Guru"
2. Sistem menampilkan daftar guru
3. **Decision:** Admin pilih aksi?
   - **Tambah:**
     - Klik tombol "Tambah Guru"
     - Input data guru baru:
       - NIK (unique)
       - Nama
       - Email
       - Phone
       - Role (guru/kepsek/admin)
       - Subject (mata pelajaran)
       - Password
     - Sistem validasi data
   - **Edit:**
     - Pilih guru dari daftar
     - Ubah data guru
     - Sistem validasi data
   - **Hapus:**
     - Pilih guru dari daftar
     - Konfirmasi hapus guru
     - Sistem validasi (tidak bisa hapus jika masih jadi wali kelas)
4. **Decision:** Data valid?
   - **Ya:**
     - Simpan perubahan ke database (tabel `gurus`)
     - Tampilkan notifikasi sukses
     - Refresh daftar guru
   - **Tidak:**
     - Tampilkan pesan error
     - Kembali ke form input
5. Selesai

**Field Database:**
- Table: `gurus`
- Columns: id, nik, name, email, phone, role, subject, password_hash, photo_url, created_at, updated_at

---

### 3. Activity Diagram - Admin Kelola Data Siswa
**File:** `activity_admin_kelola_siswa.mdj`

**Deskripsi:**
Activity diagram untuk proses kelola data siswa (tambah, edit, hapus) oleh admin.

**Alur Proses:**
1. Admin membuka menu "Kelola Siswa"
2. Sistem menampilkan daftar siswa
3. **Decision:** Admin pilih aksi?
   - **Tambah:**
     - Klik tombol "Tambah Siswa"
     - Input data siswa:
       - NISN (unique)
       - NIS
       - Nama
       - Kelas
       - Gender (L/P)
       - Tempat Lahir
       - Tanggal Lahir
       - Agama
       - Alamat
     - Input data orang tua/wali:
       - Nama Ayah, Pekerjaan, No. HP
       - Nama Ibu, Pekerjaan, No. HP
       - Nama Wali (jika ada), Pekerjaan, No. HP
       - Password untuk login orang tua
     - **Sistem generate QR Code NISN**
     - Sistem validasi data
   - **Edit:**
     - Pilih siswa dari daftar
     - Ubah data siswa dan/atau orang tua
     - Sistem validasi data
   - **Hapus:**
     - Pilih siswa dari daftar
     - Konfirmasi hapus siswa (data orang tua juga akan terhapus - CASCADE)
4. **Decision:** Data valid?
   - **Ya:**
     - Simpan perubahan ke database (tabel `students` dan `parents`)
     - Tampilkan notifikasi sukses
     - Refresh daftar siswa
   - **Tidak:**
     - Tampilkan pesan error
     - Kembali ke form input
5. Selesai

**Field Database:**
- Table: `students` - id, nisn, nis, name, class_id, gender, birth_place, birth_date, religion, address, photo_url, qr_code_path
- Table: `parents` - id, student_id, father_name, father_job, father_phone, mother_name, mother_job, mother_phone, guardian_name, guardian_job, guardian_phone, photo_url, password_hash

---

### 4. Activity Diagram - Admin Kelola Data Kelas
**File:** `activity_admin_kelola_kelas.mdj`

**Deskripsi:**
Activity diagram untuk proses kelola data kelas (tambah, edit, hapus) oleh admin.

**Alur Proses:**
1. Admin membuka menu "Kelola Kelas"
2. Sistem menampilkan daftar kelas
3. **Decision:** Admin pilih aksi?
   - **Tambah:**
     - Klik tombol "Tambah Kelas"
     - Input data kelas:
       - Nama Kelas (e.g., "Kelas 1A")
       - Tingkat/Grade (1-6)
       - Wali Kelas (pilih dari daftar guru)
       - Tahun Ajaran (default: 2025/2026)
     - Sistem validasi data
   - **Edit:**
     - Pilih kelas dari daftar
     - Ubah data kelas (termasuk ganti wali kelas)
     - Sistem validasi data
   - **Hapus:**
     - Pilih kelas dari daftar
     - Konfirmasi hapus kelas
4. **Decision:** Data valid?
   - **Ya:**
     - Simpan perubahan ke database (tabel `classes`)
     - Tampilkan notifikasi sukses
     - Refresh daftar kelas
   - **Tidak:**
     - Tampilkan pesan error
     - Kembali ke form input
5. Selesai

**Field Database:**
- Table: `classes` - id, name, grade, homeroom_teacher_id, academic_year, created_at

---

### 5. Activity Diagram - Admin Kelola Pengumuman
**File:** `activity_admin_kelola_pengumuman.mdj`

**Deskripsi:**
Activity diagram untuk proses kelola pengumuman (tambah, edit, hapus) oleh admin.

**Alur Proses:**
1. Admin membuka menu "Kelola Pengumuman"
2. Sistem menampilkan daftar pengumuman
3. **Decision:** Admin pilih aksi?
   - **Tambah:**
     - Klik tombol "Buat Pengumuman"
     - Input judul dan konten pengumuman
     - Pilih target audience:
       - All (semua)
       - Parents (orang tua)
       - Teachers (guru)
       - Class (kelas tertentu)
     - **Decision:** Ada lampiran?
       - **Ya:** Upload lampiran (PDF/Image)
       - **Tidak:** Lanjut
     - Sistem validasi data
   - **Edit:**
     - Pilih pengumuman dari daftar
     - Ubah data pengumuman
     - Sistem validasi data
   - **Hapus:**
     - Pilih pengumuman dari daftar
     - Konfirmasi hapus pengumuman (lampiran juga akan terhapus - CASCADE)
4. **Decision:** Data valid?
   - **Ya:**
     - Simpan pengumuman ke database (tabel `announcements` dan `attachments`)
     - **Kirim notifikasi ke target audience**
     - Tampilkan notifikasi sukses
     - Refresh daftar pengumuman
   - **Tidak:**
     - Tampilkan pesan error
     - Kembali ke form input
5. Selesai

**Field Database:**
- Table: `announcements` - id, title, content, author_id, author_type, target_audience, target_class_id, created_at, updated_at
- Table: `attachments` - id, announcement_id, filename, file_path, file_type, file_size, uploaded_at

---

### 6. Activity Diagram - Admin Proses Reset Password
**File:** `activity_admin_proses_reset_password.mdj`

**Deskripsi:**
Activity diagram untuk proses reset password yang diajukan oleh guru atau orang tua.

**Alur Proses:**
1. Admin membuka menu "Permintaan Reset Password"
2. Sistem menampilkan daftar permintaan dengan status "pending"
3. Admin pilih permintaan yang akan diproses
4. Sistem menampilkan detail permintaan:
   - Identifier (NIK untuk guru, NISN untuk orang tua)
   - Nama pemohon
   - Tipe user (guru/parent)
   - No. telepon
   - Tanggal pengajuan
5. Admin melakukan verifikasi data dan identitas pemohon
6. **Decision:** Approve atau Reject?
   - **Approve:**
     - Sistem generate password baru (random)
     - Update password di database (tabel `gurus` atau `parents`)
     - Kirim password baru via WhatsApp/SMS ke nomor telepon terdaftar
     - Update status permintaan menjadi "completed"
   - **Reject:**
     - Admin input alasan penolakan
     - Update status permintaan menjadi "rejected"
7. Sistem simpan catatan admin (processed_by, processed_at, notes) ke database
8. Tampilkan notifikasi sukses
9. Refresh daftar permintaan
10. Selesai

**Field Database:**
- Table: `password_reset_requests` - id, identifier, name, user_type, phone_number, status, created_at, processed_at, processed_by, notes

---

### 7. Activity Diagram - Admin Pantau Dashboard
**File:** `activity_admin_pantau_dashboard.mdj`

**Deskripsi:**
Activity diagram untuk pantau dashboard admin yang menampilkan statistik dan ringkasan data aplikasi.

**Alur Proses:**
1. Admin login ke sistem
2. Sistem load data dashboard
3. Sistem menampilkan statistik utama:
   - Total Guru (dari tabel `gurus`)
   - Total Siswa (dari tabel `students`)
   - Total Kelas (dari tabel `classes`)
4. Sistem menampilkan statistik presensi hari ini:
   - Jumlah hadir
   - Jumlah izin
   - Jumlah sakit
   - Jumlah alpa
5. Sistem menampilkan grafik presensi (mingguan/bulanan)
6. Sistem menampilkan pengumuman terbaru (5 terakhir)
7. Sistem menampilkan permintaan pending:
   - Permintaan izin yang belum direview
   - Permintaan reset password yang belum diproses
8. **Decision:** Admin pilih aksi?
   - **Filter Data:**
     - Pilih periode (harian/mingguan/bulanan)
     - Pilih kelas tertentu (optional)
     - Refresh dashboard dengan filter
     - Kembali ke decision
   - **Export Laporan:**
     - Pilih format (PDF/Excel)
     - Generate laporan
     - Download file laporan
     - Kembali ke decision
   - **Lihat Detail:**
     - Klik pada statistik tertentu
     - Redirect ke menu terkait (misal: klik "Permintaan Izin Pending" → ke menu "Review Izin")
     - Selesai
   - **Selesai:** Exit

**Komponen Dashboard:**
- **Statistik Cards:** Total guru, siswa, kelas
- **Presensi Hari Ini:** Widget dengan breakdown status presensi
- **Grafik Presensi:** Chart line/bar untuk tren presensi
- **Pengumuman Terbaru:** List 5 pengumuman terakhir
- **Permintaan Pending:** Badge notifikasi untuk izin dan reset password

---

## Ringkasan Fitur Admin

| No | Fitur | File Activity Diagram | Tabel Database Terkait |
|----|-------|----------------------|------------------------|
| 1  | Login Admin | activity_admin_login.mdj | gurus |
| 2  | Kelola Data Guru | activity_admin_kelola_guru.mdj | gurus |
| 3  | Kelola Data Siswa | activity_admin_kelola_siswa.mdj | students, parents |
| 4  | Kelola Data Kelas | activity_admin_kelola_kelas.mdj | classes |
| 5  | Kelola Pengumuman | activity_admin_kelola_pengumuman.mdj | announcements, attachments |
| 6  | Proses Reset Password | activity_admin_proses_reset_password.mdj | password_reset_requests, gurus, parents |
| 7  | Pantau Dashboard | activity_admin_pantau_dashboard.mdj | Semua tabel (untuk statistik) |

## Role Admin dalam Database

Admin adalah user dengan role `'admin'` dalam tabel `gurus`. Field role menggunakan ENUM:
```sql
role ENUM('guru','kepsek','admin') DEFAULT 'guru'
```

Admin memiliki akses penuh ke semua fitur manajemen:
- CRUD guru, siswa, kelas, pengumuman
- Proses permintaan reset password
- Monitoring dan pelaporan
- Konfigurasi sistem

## Catatan Implementasi

1. **Autentikasi:** Admin login menggunakan NIK dan password (sama seperti guru)
2. **Authorization:** Hanya user dengan role='admin' yang dapat mengakses halaman web admin
3. **QR Code:** Saat menambah siswa baru, sistem otomatis generate QR Code dari NISN untuk keperluan scan presensi
4. **Cascade Delete:** 
   - Hapus siswa → data orang tua ikut terhapus
   - Hapus pengumuman → lampiran ikut terhapus
5. **Notifikasi:** Pengumuman baru akan trigger notifikasi push ke target audience yang sesuai
6. **Password Reset:** Password baru yang di-generate harus secure (minimal 8 karakter, kombinasi huruf dan angka)

---

**Dibuat untuk:** Aplikasi Sapa Raudha  
**Platform:** Web Admin (untuk Admin)  
**Tanggal:** 11 Januari 2026
