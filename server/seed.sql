-- Seed Data untuk Testing
-- Jalankan setelah schema.sql

-- Insert Guru (termasuk Admin dan Kepala Sekolah)
INSERT INTO gurus (nik, name, email, phone, role, subject, password_hash) VALUES
('1234567890123456', 'Admin Sekolah', 'admin@raudha.sch.id', '081234567890', 'admin', 'Administrator', 'admin123'),
('1234567890123457', 'Admin Sistem', 'admin2@raudha.sch.id', '081234567891', 'admin', 'Administrator', 'admin123'),
('9876543210987654', 'Ibu Siti Nurhaliza', 'siti@raudha.sch.id', '081298765432', 'kepsek', 'Kepala Sekolah', 'guru123'),
('9876543210987655', 'Bapak Ahmad Dahlan', 'ahmad@raudha.sch.id', '081298765433', 'guru', 'Matematika', 'guru123'),
('9876543210987656', 'Ibu Kartini', 'kartini@raudha.sch.id', '081298765434', 'guru', 'Bahasa Indonesia', 'guru123'),
('9876543210987657', 'Bapak Habibie', 'habibie@raudha.sch.id', '081298765435', 'guru', 'IPA', 'guru123');

-- Insert Classes
INSERT INTO classes (name, grade, homeroom_teacher_id, academic_year) VALUES
('Kelas 1A', 1, 4, '2025/2026'),
('Kelas 1B', 1, 5, '2025/2026'),
('Kelas 2A', 2, 6, '2025/2026'),
('Kelas 2B', 2, 4, '2025/2026'),
('Kelas 3A', 3, 5, '2025/2026');

-- Insert Students
INSERT INTO students (nisn, nis, name, class_id, gender, birth_place, birth_date, religion, address) VALUES
('1234567890', '2025001', 'Ahmad Budi Santoso', 1, 'L', 'Jakarta', '2018-05-15', 'Islam', 'Jl. Mawar No. 10, Jakarta'),
('1234567891', '2025002', 'Siti Aisyah', 1, 'P', 'Jakarta', '2018-06-20', 'Islam', 'Jl. Melati No. 5, Jakarta'),
('1234567892', '2025003', 'Budi Doremi', 1, 'L', 'Bogor', '2018-07-10', 'Islam', 'Jl. Anggrek No. 8, Bogor'),
('1234567893', '2025004', 'Putri Wulandari', 2, 'P', 'Jakarta', '2018-08-25', 'Islam', 'Jl. Dahlia No. 12, Jakarta'),
('1234567894', '2025005', 'Andi Pratama', 2, 'L', 'Depok', '2018-03-30', 'Islam', 'Jl. Kenanga No. 15, Depok'),
('1234567895', '2025006', 'Rina Permata Sari', 3, 'P', 'Tangerang', '2017-09-05', 'Islam', 'Jl. Mawar No. 20, Tangerang'),
('1234567896', '2025007', 'Doni Setiawan', 3, 'L', 'Jakarta', '2017-10-12', 'Islam', 'Jl. Flamboyan No. 7, Jakarta'),
('1234567897', '2025008', 'Lina Marlina', 4, 'P', 'Bekasi', '2017-11-18', 'Islam', 'Jl. Cempaka No. 9, Bekasi'),
('1234567898', '2025009', 'Yoga Pratama', 4, 'L', 'Jakarta', '2017-12-22', 'Islam', 'Jl. Seruni No. 11, Jakarta'),
('1234567899', '2025010', 'Dewi Anggraini', 5, 'P', 'Bogor', '2016-01-08', 'Islam', 'Jl. Tulip No. 14, Bogor');

-- Insert Parents (untuk setiap siswa)
INSERT INTO parents (student_id, father_name, father_job, father_phone, mother_name, mother_job, mother_phone, password_hash) VALUES
(1, 'Bapak Santoso', 'Wiraswasta', '081234560001', 'Ibu Siti', 'Ibu Rumah Tangga', '081234560002', 'ortu123'),
(2, 'Bapak Abdullah', 'PNS', '081234560003', 'Ibu Fatimah', 'Guru', '081234560004', 'ortu123'),
(3, 'Bapak Darmawan', 'Karyawan Swasta', '081234560005', 'Ibu Suci', 'Ibu Rumah Tangga', '081234560006', 'ortu123'),
(4, 'Bapak Wulan', 'Dokter', '081234560007', 'Ibu Dewi', 'Perawat', '081234560008', 'ortu123'),
(5, 'Bapak Pratama', 'Pengusaha', '081234560009', 'Ibu Ani', 'Ibu Rumah Tangga', '081234560010', 'ortu123'),
(6, 'Bapak Permana', 'Arsitek', '081234560011', 'Ibu Rita', 'Designer', '081234560012', 'ortu123'),
(7, 'Bapak Setia', 'Polisi', '081234560013', 'Ibu Dona', 'Ibu Rumah Tangga', '081234560014', 'ortu123'),
(8, 'Bapak Marlin', 'Pilot', '081234560015', 'Ibu Linda', 'Pramugari', '081234560016', 'ortu123'),
(9, 'Bapak Pramana', 'Engineer', '081234560017', 'Ibu Yuli', 'HR Manager', '081234560018', 'ortu123'),
(10, 'Bapak Anggara', 'Lawyer', '081234560019', 'Ibu Diana', 'Notaris', '081234560020', 'ortu123');

-- Insert Announcements
INSERT INTO announcements (title, content, author_id, author_type, target_audience) VALUES
('Rapat Wali Murid Kelas 1', 'Diberitahukan kepada seluruh wali murid kelas 1 bahwa akan diadakan rapat pada hari Sabtu, 14 Desember 2025 pukul 09:00 WIB di Aula Sekolah. Kehadiran sangat diharapkan. Terima kasih.', 1, 'guru', 'parents'),
('Informasi Kegiatan Outing Class', 'Anak-anak kelas 2 akan mengikuti kegiatan outing class ke Taman Mini Indonesia Indah pada hari Rabu, 18 Desember 2025. Mohon mempersiapkan bekal dan pakaian ganti. Biaya partisipasi sebesar Rp 50.000.', 4, 'guru', 'parents'),
('Libur Semester Ganjil', 'Kegiatan belajar mengajar semester ganjil akan berakhir pada tanggal 20 Desember 2025. Libur semester akan dimulai tanggal 23 Desember 2025 sampai dengan 5 Januari 2026. Pembelajaran semester genap dimulai 6 Januari 2026.', 1, 'guru', 'all'),
('Pengumuman Ujian Akhir Semester', 'Ujian Akhir Semester akan dilaksanakan pada tanggal 16-19 Desember 2025. Mohon siswa mempersiapkan diri dengan baik. Jadwal lengkap akan dibagikan melalui wali kelas masing-masing.', 3, 'guru', 'all');

-- Insert Sample Attendance (beberapa hari terakhir)
INSERT INTO attendance (student_id, date, status, check_in, scanned_by) VALUES
-- 11 Desember 2025
(1, '2025-12-11', 'hadir', '07:15:00', 4),
(2, '2025-12-11', 'hadir', '07:20:00', 4),
(3, '2025-12-11', 'hadir', '07:18:00', 4),
(4, '2025-12-11', 'hadir', '07:25:00', 5),
(5, '2025-12-11', 'sakit', NULL, NULL),
-- 12 Desember 2025
(1, '2025-12-12', 'hadir', '07:10:00', 4),
(2, '2025-12-12', 'hadir', '07:22:00', 4),
(3, '2025-12-12', 'izin', NULL, NULL),
(4, '2025-12-12', 'hadir', '07:30:00', 5),
(5, '2025-12-12', 'hadir', '07:28:00', 5),
-- 13 Desember 2025 (hari ini)
(1, '2025-12-13', 'hadir', '07:12:00', 4),
(2, '2025-12-13', 'hadir', '07:19:00', 4);

-- Insert Sample Leave Requests
INSERT INTO leave_requests (student_id, request_date, reason, status, submitted_at) VALUES
(5, '2025-12-11', 'Sakit demam tinggi', 'approved', '2025-12-10 20:00:00'),
(3, '2025-12-12', 'Ada keperluan keluarga', 'approved', '2025-12-11 19:30:00'),
(6, '2025-12-14', 'Kontrol ke dokter gigi', 'pending', '2025-12-13 08:00:00'),
(7, '2025-12-15', 'Acara keluarga di luar kota', 'pending', '2025-12-13 09:15:00');

-- Update approved leave requests
UPDATE leave_requests SET reviewed_by = 4, reviewed_at = '2025-12-11 07:00:00', review_notes = 'Disetujui. Semoga lekas sembuh.' WHERE id = 1;
UPDATE leave_requests SET reviewed_by = 4, reviewed_at = '2025-12-12 07:05:00', review_notes = 'Disetujui.' WHERE id = 2;
