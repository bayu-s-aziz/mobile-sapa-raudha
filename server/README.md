# Sapa Raudha - Server API

Backend REST API untuk aplikasi Sapa Raudha menggunakan Node.js, Express, dan MySQL.

## Setup Database

1. Buat database MySQL:
```sql
CREATE DATABASE sapa_raudha CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

2. Import schema:
```bash
mysql -u root -p sapa_raudha < schema.sql
```

3. Import seed data (optional, untuk testing):
```bash
mysql -u root -p sapa_raudha < seed.sql
```

## Setup Server

1. Install dependencies:
```bash
npm install
```

2. Buat file `.env` (optional):
```env
DB_HOST=127.0.0.1
DB_USER=root
DB_PASS=your_password
DB_NAME=sapa_raudha
JWT_SECRET=your_secret_key
PORT=3000
```

3. Jalankan server:
```bash
npm start
```

Server akan berjalan di `http://localhost:3000`

## API Endpoints

### Authentication

#### POST `/auth/login`
Login unified (auto-detect role by NIK/NISN)
```json
{
  "identifier": "1234567890",
  "password": "password123"
}
```

Response:
```json
{
  "token": "jwt_token",
  "profile": {
    "id": 1,
    "role": "guru",
    "name": "Ibu Guru"
  }
}
```

### Students

**Semua endpoint memerlukan authentication header:**
```
Authorization: Bearer <token>
```

#### GET `/students`
List semua siswa (guru only)
- Query params: `class_id` (optional)

#### GET `/students/:id`
Detail siswa by ID

#### GET `/students/nisn/:nisn`
Detail siswa by NISN

#### GET `/classes`
List semua kelas dengan jumlah siswa

### Announcements

#### GET `/announcements`
List pengumuman
- Query params: `limit` (default: 50), `offset` (default: 0)

#### GET `/announcements/:id`
Detail pengumuman dengan attachments

#### POST `/announcements`
Buat pengumuman baru (admin/guru only)
- Body: `title`, `content`, `target_audience`, `target_class_id`
- Form-data: `attachment` (file, optional)

#### DELETE `/announcements/:id`
Hapus pengumuman (author atau admin only)

### Attendance

#### POST `/attendance/scan`
Rekam presensi via QR scan (guru only)
```json
{
  "nisn": "1234567890"
}
```

#### GET `/attendance/student/:nisn`
Riwayat absensi siswa
- Query params: `start_date`, `end_date`, `limit` (default: 30)

#### GET `/attendance/class/:classId/date/:date`
Absensi kelas pada tanggal tertentu

#### GET `/attendance/stats`
Statistik absensi hari ini

### Leave Requests

#### POST `/leave-requests`
Ajukan izin (orang tua)
- Body: `student_nisn`, `request_date`, `reason`
- Form-data: `attachment` (file, optional)

#### GET `/leave-requests`
List pengajuan izin
- Query params: `status` (pending/approved/rejected), `student_nisn`

#### PUT `/leave-requests/:id/approve`
Setujui izin (guru only)
- Body: `review_notes` (optional)

#### PUT `/leave-requests/:id/reject`
Tolak izin (guru only)
- Body: `review_notes` (optional)

### Profile

#### GET `/profile`
Get profil user yang sedang login

## User Demo (Seed Data)

### Admin
- NIK: `1234567890123456`
- Password: `admin123`

### Guru
- NIK: `9876543210987654`
- Password: `guru123`
- Role: Kepala Sekolah

### Orang Tua
- NISN Anak: `1234567890` (Ahmad Budi Santoso)
- Password: `ortu123`

## File Upload

File yang diupload disimpan di folder `uploads/` dan dapat diakses via:
```
http://localhost:3000/uploads/filename.ext
```

## Notes

- Password disimpan dalam plaintext sesuai requirement
- JWT token expire dalam 12 jam
- File upload limit: 10MB
- Support format: PDF, JPG, PNG, dll

## Development

Untuk development dengan auto-reload, install `nodemon`:
```bash
npm install -g nodemon
nodemon index.js
```
