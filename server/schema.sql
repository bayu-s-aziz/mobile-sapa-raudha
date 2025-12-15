-- Schema Database Sapa Raudha
-- Database: sapa_raudha

-- Drop tables if exist (untuk development)
DROP TABLE IF EXISTS password_reset_requests;
DROP TABLE IF EXISTS attachments;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS leave_requests;
DROP TABLE IF EXISTS announcements;
DROP TABLE IF EXISTS parents;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS classes;
DROP TABLE IF EXISTS gurus;

-- Table: gurus (teachers/staff/admin)
CREATE TABLE gurus (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nik VARCHAR(20) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100),
  phone VARCHAR(20),
  role ENUM('guru','kepsek','admin') DEFAULT 'guru',
  subject VARCHAR(100), -- Mata pelajaran yang diampu
  password_hash VARCHAR(255) NOT NULL,
  photo_url VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: classes
CREATE TABLE classes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL, -- e.g., "Kelas 1A", "Kelas 2B"
  grade INT NOT NULL, -- Tingkat: 1, 2, 3, dst
  homeroom_teacher_id INT, -- Wali kelas
  academic_year VARCHAR(20) DEFAULT '2025/2026',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (homeroom_teacher_id) REFERENCES gurus(id) ON DELETE SET NULL
);

-- Table: students
CREATE TABLE students (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nisn VARCHAR(20) UNIQUE NOT NULL,
  nis VARCHAR(20),
  name VARCHAR(100) NOT NULL,
  class_id INT,
  gender ENUM('L','P'),
  birth_place VARCHAR(100),
  birth_date DATE,
  religion VARCHAR(50),
  address TEXT,
  photo_url VARCHAR(255),
  qr_code_path VARCHAR(255), -- Path ke file QR code NISN
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE SET NULL
);

-- Table: parents (orang tua)
CREATE TABLE parents (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  father_name VARCHAR(100),
  father_job VARCHAR(100),
  father_phone VARCHAR(20),
  mother_name VARCHAR(100),
  mother_job VARCHAR(100),
  mother_phone VARCHAR(20),
  guardian_name VARCHAR(100), -- Wali jika bukan ortu kandung
  guardian_job VARCHAR(100),
  guardian_phone VARCHAR(20),
  photo_url VARCHAR(255), -- Foto profil orang tua
  password_hash VARCHAR(255) NOT NULL, -- Login dengan NISN anak
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
);

-- Table: announcements
CREATE TABLE announcements (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  author_id INT NOT NULL, -- ID dari gurus (termasuk admin)
  author_type ENUM('guru') NOT NULL DEFAULT 'guru', -- Semua dari tabel gurus
  target_audience ENUM('all','parents','teachers','class') DEFAULT 'all',
  target_class_id INT, -- Jika khusus untuk kelas tertentu
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (target_class_id) REFERENCES classes(id) ON DELETE SET NULL
);

-- Table: attachments (lampiran pengumuman)
CREATE TABLE attachments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  announcement_id INT NOT NULL,
  filename VARCHAR(255) NOT NULL,
  file_path VARCHAR(255) NOT NULL,
  file_type VARCHAR(50), -- pdf, jpg, png, etc
  file_size INT, -- dalam bytes
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (announcement_id) REFERENCES announcements(id) ON DELETE CASCADE
);

-- Table: attendance (presensi)
CREATE TABLE attendance (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  date DATE NOT NULL,
  status ENUM('hadir','sakit','izin','alpa') DEFAULT 'hadir',
  check_in TIME,
  check_out TIME,
  notes TEXT,
  scanned_by INT, -- Guru yang scan
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (scanned_by) REFERENCES gurus(id) ON DELETE SET NULL,
  UNIQUE KEY unique_attendance (student_id, date) -- Satu siswa satu presensi per hari
);

-- Table: leave_requests (pengajuan izin)
CREATE TABLE leave_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  request_date DATE NOT NULL, -- Tanggal izin
  reason TEXT NOT NULL,
  attachment_path VARCHAR(255), -- Surat dokter, dll
  status ENUM('pending','approved','rejected') DEFAULT 'pending',
  submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  reviewed_by INT, -- Guru yang mereview
  reviewed_at TIMESTAMP NULL,
  review_notes TEXT,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (reviewed_by) REFERENCES gurus(id) ON DELETE SET NULL
);

-- Table: password_reset_requests (permintaan reset password)
CREATE TABLE password_reset_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  identifier VARCHAR(20) NOT NULL, -- NISN atau NIK
  name VARCHAR(100) NOT NULL,
  user_type ENUM('guru','parent') NOT NULL, -- Tipe user
  phone_number VARCHAR(20), -- Nomor telepon untuk kontak
  status ENUM('pending','completed','rejected') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  processed_at TIMESTAMP NULL,
  processed_by INT, -- Admin yang memproses
  notes TEXT, -- Catatan admin
  FOREIGN KEY (processed_by) REFERENCES gurus(id) ON DELETE SET NULL
);

-- Indexes untuk performa
CREATE INDEX idx_students_nisn ON students(nisn);
CREATE INDEX idx_students_class ON students(class_id);
CREATE INDEX idx_attendance_date ON attendance(date);
CREATE INDEX idx_attendance_student ON attendance(student_id, date);
CREATE INDEX idx_leave_status ON leave_requests(status);
CREATE INDEX idx_announcements_date ON announcements(created_at);
CREATE INDEX idx_password_reset_status ON password_reset_requests(status);
CREATE INDEX idx_password_reset_identifier ON password_reset_requests(identifier);
