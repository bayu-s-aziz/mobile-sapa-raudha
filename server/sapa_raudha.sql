-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jan 16, 2026 at 04:33 PM
-- Server version: 11.4.9-MariaDB-ubu2404
-- PHP Version: 8.3.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `alislam_sapa_raudha`
--

-- --------------------------------------------------------

--
-- Table structure for table `announcements`
--

CREATE TABLE `announcements` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `author_id` int(11) NOT NULL,
  `author_type` enum('guru') NOT NULL DEFAULT 'guru',
  `target_audience` enum('all','parents','teachers','class') DEFAULT 'all',
  `target_class_id` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `announcements`
--

INSERT INTO `announcements` (`id`, `title`, `content`, `author_id`, `author_type`, `target_audience`, `target_class_id`, `created_at`, `updated_at`) VALUES
(1, 'KBM Semester Genap', 'Kegiatan belajar mengajar semester genap mulai kembali pada tanggal 5 Januari 2026.', 1, 'guru', 'all', NULL, '2026-01-09 15:39:50', '2026-01-09 15:39:50'),
(2, 'MBG Dilanjutkan', 'Untuk Semester genap MBG akan diberikan pada minggu ke-2 tepatnya tanggal 12 Januari 2026.', 1, 'guru', 'all', NULL, '2026-01-09 15:41:58', '2026-01-09 15:41:58');

-- --------------------------------------------------------

--
-- Table structure for table `attachments`
--

CREATE TABLE `attachments` (
  `id` int(11) NOT NULL,
  `announcement_id` int(11) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `file_type` varchar(50) DEFAULT NULL,
  `file_size` int(11) DEFAULT NULL,
  `uploaded_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `attendance`
--

CREATE TABLE `attendance` (
  `id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `status` enum('hadir','sakit','izin','alpa') DEFAULT 'hadir',
  `check_in` time DEFAULT NULL,
  `check_out` time DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `scanned_by` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `attendance`
--

INSERT INTO `attendance` (`id`, `student_id`, `date`, `status`, `check_in`, `check_out`, `notes`, `scanned_by`, `created_at`) VALUES
(1, 1, '2026-01-05', 'izin', NULL, NULL, 'Sakit, Izn Liburan', NULL, '2026-01-10 03:38:03'),
(2, 1, '2026-01-11', 'hadir', NULL, NULL, NULL, 2, '2026-01-11 16:00:31'),
(3, 2, '2026-01-11', 'hadir', NULL, NULL, NULL, 2, '2026-01-11 16:00:45'),
(4, 18, '2026-01-11', 'hadir', NULL, NULL, NULL, 2, '2026-01-11 16:00:57'),
(5, 3, '2026-01-11', 'hadir', NULL, NULL, NULL, 2, '2026-01-11 16:01:09'),
(6, 10, '2026-01-11', 'hadir', NULL, NULL, NULL, 2, '2026-01-11 16:01:23'),
(7, 4, '2026-01-11', 'hadir', NULL, NULL, NULL, 2, '2026-01-11 16:01:39'),
(8, 27, '2026-01-11', 'hadir', NULL, NULL, NULL, 2, '2026-01-11 16:01:53'),
(9, 5, '2026-01-11', 'hadir', NULL, NULL, NULL, 2, '2026-01-11 16:02:04'),
(10, 11, '2026-01-11', 'hadir', NULL, NULL, NULL, 2, '2026-01-11 16:02:19'),
(11, 6, '2026-01-11', 'hadir', NULL, NULL, NULL, 2, '2026-01-11 16:02:33'),
(12, 7, '2026-01-11', 'hadir', NULL, NULL, NULL, 2, '2026-01-11 16:02:44'),
(13, 8, '2026-01-11', 'hadir', NULL, NULL, NULL, 2, '2026-01-11 16:02:55'),
(14, 1, '2026-01-07', 'izin', NULL, NULL, 'izizniznzinzinz', NULL, '2026-01-13 02:14:32');

-- --------------------------------------------------------

--
-- Table structure for table `classes`
--

CREATE TABLE `classes` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `grade` int(11) NOT NULL,
  `homeroom_teacher_id` int(11) DEFAULT NULL,
  `academic_year` varchar(20) DEFAULT '2025/2026',
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `classes`
--

INSERT INTO `classes` (`id`, `name`, `grade`, `homeroom_teacher_id`, `academic_year`, `created_at`) VALUES
(1, 'Kelompok A', 1, 3, '2025/2026', '2026-01-09 12:06:47'),
(2, 'Kelompok B', 1, 2, '2025/2026', '2026-01-09 12:06:47');

-- --------------------------------------------------------

--
-- Table structure for table `gurus`
--

CREATE TABLE `gurus` (
  `id` int(11) NOT NULL,
  `nik` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `role` enum('guru','kepsek','admin') DEFAULT 'guru',
  `subject` varchar(100) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `photo_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `gurus`
--

INSERT INTO `gurus` (`id`, `nik`, `name`, `email`, `phone`, `role`, `subject`, `password_hash`, `photo_url`, `created_at`, `updated_at`) VALUES
(1, '1234567890', 'Administrator', 'admin@ra-alislam.sch.id', NULL, 'admin', NULL, 'admin123', NULL, '2026-01-09 11:42:43', '2026-01-09 11:48:09'),
(2, '1234567891', 'Eulis Sukmayati', '', '081234567890', 'guru', '', '123456', NULL, '2026-01-09 11:53:27', '2026-01-09 11:53:27'),
(3, '1234567892', 'Elis Nurjanah', '', '082123123123', 'guru', '', '123456', NULL, '2026-01-09 11:54:01', '2026-01-09 11:54:01'),
(4, '1234567893', 'Ecin Nurbayanti', '', '083073084000', 'guru', '', '123456', NULL, '2026-01-09 11:55:03', '2026-01-09 11:55:03'),
(5, '1234567894', 'Lilis Farida', '', '082134395867', 'guru', '', '123456', NULL, '2026-01-09 11:55:47', '2026-01-09 11:55:47');

-- --------------------------------------------------------

--
-- Table structure for table `leave_requests`
--

CREATE TABLE `leave_requests` (
  `id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `request_date` date NOT NULL,
  `reason` text NOT NULL,
  `attachment_path` varchar(255) DEFAULT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `submitted_at` timestamp NULL DEFAULT current_timestamp(),
  `reviewed_by` int(11) DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `review_notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `leave_requests`
--

INSERT INTO `leave_requests` (`id`, `student_id`, `request_date`, `reason`, `attachment_path`, `status`, `submitted_at`, `reviewed_by`, `reviewed_at`, `review_notes`) VALUES
(1, 1, '2026-01-05', 'Sakit, Izn Liburan', NULL, 'approved', '2026-01-10 03:38:03', 2, '2026-01-10 03:39:05', 'Disetujui'),
(2, 1, '2026-01-07', 'izizniznzinzinz', '/uploads/1768270472584-23028734.png', 'approved', '2026-01-13 02:14:32', 2, '2026-01-13 02:14:47', 'Disetujui');

-- --------------------------------------------------------

--
-- Table structure for table `parents`
--

CREATE TABLE `parents` (
  `id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `father_name` varchar(100) DEFAULT NULL,
  `father_job` varchar(100) DEFAULT NULL,
  `father_phone` varchar(20) DEFAULT NULL,
  `mother_name` varchar(100) DEFAULT NULL,
  `mother_job` varchar(100) DEFAULT NULL,
  `mother_phone` varchar(20) DEFAULT NULL,
  `guardian_name` varchar(100) DEFAULT NULL,
  `guardian_job` varchar(100) DEFAULT NULL,
  `guardian_phone` varchar(20) DEFAULT NULL,
  `photo_url` varchar(255) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `parents`
--

INSERT INTO `parents` (`id`, `student_id`, `father_name`, `father_job`, `father_phone`, `mother_name`, `mother_job`, `mother_phone`, `guardian_name`, `guardian_job`, `guardian_phone`, `photo_url`, `password_hash`, `created_at`, `updated_at`) VALUES
(1, 1, 'AAS BENI HIDAYAT', NULL, '', 'AAH SOLIHAH', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:38:10'),
(2, 2, 'WARDIMAN', NULL, '', 'LILIS LISNAWATI', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:38:41'),
(3, 3, 'DIDI JUMADI', NULL, '', 'Devi Sintiawati', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:39:47'),
(4, 4, 'HERI PERMANA', NULL, '', 'Fidiyawati', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:40:53'),
(5, 5, 'AJIS', NULL, '', 'Fuji Fauziah', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:41:47'),
(6, 6, 'SAEPULOH', NULL, '', 'Lilis Lisnawati', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:42:06'),
(7, 7, 'SUPRIATNA', NULL, '', 'Sri Wahyuningsih', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:42:17'),
(8, 8, 'AGIS ROHIMAT', NULL, '', 'Resti Firdayanti', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:42:32'),
(9, 9, 'AHMAD SUJAI', NULL, '', 'IIS RODIAH', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:42:40'),
(10, 10, 'AAS AGIS KUSWAYA', NULL, '', 'CICI PARLINA', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:39:55'),
(11, 11, 'AGUS HERYANA', NULL, '', 'NUR NURJANAH', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:41:56'),
(12, 12, 'JEJEN JENAL ARIPIN', NULL, '', 'ELIN HERLINA', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:42:48'),
(13, 13, 'SYARIF HIDAYAT', NULL, '', 'ELY YULIA', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:43:02'),
(14, 14, 'NANANG FRIATNA', NULL, '', 'ENOK HERLINA', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:37:50'),
(15, 15, 'DALI PERMADI', NULL, '', 'YATI SURYATI', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:38:19'),
(16, 16, 'DEDE MULYADI', NULL, '', 'ANTI ROSTIANTI', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:38:27'),
(17, 17, 'SANUSI', NULL, '', 'RAHMAWATI', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:38:51'),
(18, 18, 'HENDI', NULL, '', 'SITI AISAH', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:39:05'),
(19, 19, 'CECEP SAHARA', NULL, '', 'SITI MARDIANAH', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:39:15'),
(20, 20, 'DODO HENDRA', NULL, '', 'ATIN SUPRIATIN', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:40:26'),
(21, 21, 'EDI SUPRIADI', NULL, '', 'ENTIK TATI', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:40:34'),
(22, 22, 'JAJANG SURYANA', NULL, '', 'IMAS RAHMAWATI', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:40:43'),
(23, 23, 'ASEP DODO', NULL, '', 'WARI', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:41:02'),
(24, 24, 'AZIS MUSLIM', NULL, '', 'RINI YANTI RAHAYU', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:41:10'),
(25, 25, 'ASEP SAEPULLOH', NULL, '', 'SITI KHOERIAH', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:41:18'),
(26, 26, 'AEP SAEPULLOH', NULL, '', 'SITI KHOERIAH', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:41:26'),
(27, 27, 'NANANG FARIDUDIN', NULL, '', 'Enung Nurhayati', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:41:34'),
(28, 28, 'MUHAMAD TOHA', NULL, '', 'IIF SARIPAH S.PD', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:42:55'),
(29, 29, 'DENI HERDIANA', NULL, '', 'ATIK IRAWATI', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:43:09'),
(30, 30, 'AGUS SANJAYA', NULL, '', 'MAYASARI MAHARANI', NULL, '', NULL, NULL, NULL, NULL, 'ortu123', '2026-01-09 12:24:19', '2026-01-09 12:43:17');

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_requests`
--

CREATE TABLE `password_reset_requests` (
  `id` int(11) NOT NULL,
  `identifier` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `user_type` enum('guru','parent') NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `status` enum('pending','completed','rejected') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `processed_at` timestamp NULL DEFAULT NULL,
  `processed_by` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `password_reset_requests`
--

INSERT INTO `password_reset_requests` (`id`, `identifier`, `name`, `user_type`, `phone_number`, `status`, `created_at`, `processed_at`, `processed_by`, `notes`) VALUES
(1, '3200194909', 'Akhsan', 'parent', NULL, 'rejected', '2026-01-13 00:53:26', '2026-01-13 00:53:46', 1, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

CREATE TABLE `students` (
  `id` int(11) NOT NULL,
  `nisn` varchar(20) NOT NULL,
  `nis` varchar(20) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `class_id` int(11) DEFAULT NULL,
  `gender` enum('L','P') DEFAULT NULL,
  `birth_place` varchar(100) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `religion` varchar(50) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `photo_url` varchar(255) DEFAULT NULL,
  `qr_code_path` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `students`
--

INSERT INTO `students` (`id`, `nisn`, `nis`, `name`, `class_id`, `gender`, `birth_place`, `birth_date`, `religion`, `address`, `photo_url`, `qr_code_path`, `created_at`, `updated_at`) VALUES
(1, '3200194909', '250001', 'AKHSAN RAMADHAN', 1, 'L', 'CIAMIS', '2020-05-12', '1', 'DUSUN TUGU, Kel. SUKASENANG, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:38:10'),
(2, '3208188033', '250002', 'ALINNA TRI WULANDARY', 1, 'P', 'CIAMIS', '2020-08-30', '1', 'DUSUN SUBANG, Kel. GUNUNGCUPU, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:38:41'),
(3, '3201873261', '250003', 'DANU GHILMAN HADIYAN', 1, 'L', 'CIAMIS', '2020-04-18', '1', 'SIRNAGALIH, Kel. GUNUNGCUPU, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:39:47'),
(4, '3207734540', '250005', 'MUHAMMAD KENZIE PUTRA PERMANA', 1, 'L', 'BOYOLALI', '2020-06-17', '1', 'SIRNAGALIH, Kel. GUNUNGCUPU, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:40:53'),
(5, '3202043565', '250006', 'NISA NURAFIFAH AZ-ZAHRA', 1, 'P', 'CIAMIS', '2020-05-10', '1', 'DUSUN SIRNAGALIH, Kel. GUNUNGCUPU, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:41:44'),
(6, '3204694103', '250008', 'RAFA AL TAUFIQ', 1, 'L', 'CIAMIS', '2020-02-24', '1', 'DUSUN SIRNAGALIH, Kel. GUNUNGCUPU, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:42:06'),
(7, '3201208113', '250009', 'RAZKA WILIAM SAPUTRA', 1, 'L', 'CIAMIS', '2020-08-08', '1', 'DUSUN SIRNAGALIH, Kel. GUNUNGCUPU, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:42:17'),
(8, '3203334373', '250010', 'RIENTAMMY NAZIA PUTRIE', 1, 'P', 'CIAMIS', '2020-09-26', '1', 'DUSUN SIRNAGALIH, Kel. GUNUNGCUPU, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:42:32'),
(9, '3204587629', '250011', 'RIRIN SOPIYAH', 1, 'P', 'CIAMIS', '2020-12-11', '1', 'DUSUN TUGU, Kel. SUKASENANG, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:42:40'),
(10, '3202885958', '250004', 'FAHMI KAMAL ALGHANI', 1, 'L', 'CIAMIS', '2020-11-09', '1', 'DUSUN SIRNAGALIH, Kel. GUNUNGCUPU, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:39:55'),
(11, '3194033181', '250007', 'NOVIAN MAHARDIKA', 1, 'L', 'CIAMIS', '2019-11-24', '1', 'DUSUN SIRNAGALIH, Kel. GUNUNGCUPU, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:41:56'),
(12, '3209312801', '250012', 'SHAQILA NURHASANAH', 1, 'P', 'CIAMIS', '2020-04-18', '1', 'DUSUN TUGU, Kel. SUKASENANG, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:42:48'),
(13, '3206684539', '250013', 'SYAKILA ALMAIRA', 1, 'P', 'CIAMIS', '2020-09-18', '1', 'DUSUN TUGU, Kel. SUKASENANG, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:43:02'),
(14, '3185384514', '240001', 'ABIDZARD HILMI FAUZIANSYAH', 2, 'L', 'CIAMIS', '2018-09-27', '1', 'DUSUN SIRNAGALIH', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:37:50'),
(15, '3191564790', '240002', 'AL AYYUBY FAIZ', 2, 'L', 'CIAMIS', '2019-09-04', '1', 'DUSUN SUBANG, Kel. GUNUNGCUPU, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:38:19'),
(16, '3186404777', '240003', 'ALESHA MAULIDA', 2, 'P', 'CIAMIS', '2018-11-11', '1', 'DUSUN RANJI RATA, Kel. CIMARI, Kec. CIKONENG, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:38:27'),
(17, '3196018725', '240004', 'AMELIA RAHMA JULIANTI', 2, 'P', 'CIAMIS', '2019-07-01', '1', 'DUSUN SUBANG, Kel. GUNUNGCUPU, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:38:51'),
(18, '3186781982', '250014', 'ANNISA NURRUL QOLBY', 1, 'P', 'CIAMIS', '2018-12-27', '1', 'DUSUN TUGU, Kel. SUKASENANG, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:39:05'),
(19, '3205309254', '240005', 'AZKIA ZAHRA NURSIFA', 2, 'P', 'CIAMIS', '2020-04-05', '1', 'SIRNAGALIH, Kel. GUNUNGCUPU, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:39:15'),
(20, '3198820898', '240006', 'HAFIZ NAJWAN', 2, 'L', 'CIAMIS', '2019-10-25', '1', 'DUSUN SUBANG, Kel. GUNUNGCUPU, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:40:26'),
(21, '3199037426', '240007', 'HANIF HUSNI RAMADHAN', 2, 'L', 'CIAMIS', '2019-05-28', '1', 'DUSUN SUBANG, Kel. GUNUNGCUPU, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:40:34'),
(22, '3196993818', '240008', 'HILYA DWI ANNAURI', 2, 'P', 'CIAMIS', '2019-05-02', '1', 'DUSUN TUGU, Kel. SUKASENANG, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:40:43'),
(23, '3196285378', '240009', 'MUHAMMAD LUTHFI IBNU HAFIDZ', 2, 'L', 'CIAMIS', '2019-07-11', '1', 'DUSUN TUGU, Kel. SUKASENANG, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:41:02'),
(24, '3195329264', '240010', 'MUHAMMAD RAFI HAFIZ ALFATIH', 2, 'L', 'CIAMIS', '2019-05-04', '1', 'DUSUN TUGU, Kel. SUKASENANG, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:41:10'),
(25, '3196449784', '240011', 'NABILA NUR AZIZAH', 2, 'P', 'CIAMIS', '2019-02-27', '1', 'DUSUN SIRNAGALIH, Kel. GUNUNGCUPU, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:41:18'),
(26, '3192889481', '240012', 'NADIFA NURUL JANNAH', 2, 'P', 'CIAMIS', '2019-02-27', '1', 'SIRNAGALIH, Kel. GUNUNGCUPU, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:41:26'),
(27, '3195070489', '250015', 'NADZIFAH JAUHAR NAFISAH', 1, 'P', 'CIAMIS', '2019-02-06', '1', 'SIRNAGALIH, Kel. GUNUNGCUPU, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:41:34'),
(28, '3206313252', '250016', 'SHOFA NURSYIFA HASANAH', 1, 'P', 'CIAMIS', '2020-02-02', '1', 'DUSUN SIRNAGALIH, Kel. GUNUNGCUPU, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:42:55'),
(29, '3194469072', '250017', 'SYASHA SHIDQIA', 1, 'P', 'CIAMIS', '2019-09-12', '1', 'DUSUN TUGU, Kel. SUKASENANG, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:43:09'),
(30, '3190130709', '240013', 'YOLLA OLIVIA', 2, 'P', 'CIAMIS', '2019-02-07', '1', 'DUSUN TUGU, Kel. SUKASENANG, Kec. SINDANGKASIH, JAWA BARAT, 46268', NULL, NULL, '2026-01-09 12:24:19', '2026-01-09 12:43:17');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `announcements`
--
ALTER TABLE `announcements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `target_class_id` (`target_class_id`),
  ADD KEY `idx_announcements_date` (`created_at`);

--
-- Indexes for table `attachments`
--
ALTER TABLE `attachments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `announcement_id` (`announcement_id`);

--
-- Indexes for table `attendance`
--
ALTER TABLE `attendance`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_attendance` (`student_id`,`date`),
  ADD KEY `scanned_by` (`scanned_by`),
  ADD KEY `idx_attendance_date` (`date`),
  ADD KEY `idx_attendance_student` (`student_id`,`date`);

--
-- Indexes for table `classes`
--
ALTER TABLE `classes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `homeroom_teacher_id` (`homeroom_teacher_id`);

--
-- Indexes for table `gurus`
--
ALTER TABLE `gurus`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nik` (`nik`);

--
-- Indexes for table `leave_requests`
--
ALTER TABLE `leave_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `student_id` (`student_id`),
  ADD KEY `reviewed_by` (`reviewed_by`),
  ADD KEY `idx_leave_status` (`status`);

--
-- Indexes for table `parents`
--
ALTER TABLE `parents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `student_id` (`student_id`);

--
-- Indexes for table `password_reset_requests`
--
ALTER TABLE `password_reset_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `processed_by` (`processed_by`),
  ADD KEY `idx_password_reset_status` (`status`),
  ADD KEY `idx_password_reset_identifier` (`identifier`);

--
-- Indexes for table `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nisn` (`nisn`),
  ADD KEY `idx_students_nisn` (`nisn`),
  ADD KEY `idx_students_class` (`class_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `announcements`
--
ALTER TABLE `announcements`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `attachments`
--
ALTER TABLE `attachments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `attendance`
--
ALTER TABLE `attendance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `classes`
--
ALTER TABLE `classes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `gurus`
--
ALTER TABLE `gurus`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `leave_requests`
--
ALTER TABLE `leave_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `parents`
--
ALTER TABLE `parents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `password_reset_requests`
--
ALTER TABLE `password_reset_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `students`
--
ALTER TABLE `students`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `announcements`
--
ALTER TABLE `announcements`
  ADD CONSTRAINT `announcements_ibfk_1` FOREIGN KEY (`target_class_id`) REFERENCES `classes` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `attachments`
--
ALTER TABLE `attachments`
  ADD CONSTRAINT `attachments_ibfk_1` FOREIGN KEY (`announcement_id`) REFERENCES `announcements` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `attendance`
--
ALTER TABLE `attendance`
  ADD CONSTRAINT `attendance_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `attendance_ibfk_2` FOREIGN KEY (`scanned_by`) REFERENCES `gurus` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `classes`
--
ALTER TABLE `classes`
  ADD CONSTRAINT `classes_ibfk_1` FOREIGN KEY (`homeroom_teacher_id`) REFERENCES `gurus` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `leave_requests`
--
ALTER TABLE `leave_requests`
  ADD CONSTRAINT `leave_requests_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `leave_requests_ibfk_2` FOREIGN KEY (`reviewed_by`) REFERENCES `gurus` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `parents`
--
ALTER TABLE `parents`
  ADD CONSTRAINT `parents_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `password_reset_requests`
--
ALTER TABLE `password_reset_requests`
  ADD CONSTRAINT `password_reset_requests_ibfk_1` FOREIGN KEY (`processed_by`) REFERENCES `gurus` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `students`
--
ALTER TABLE `students`
  ADD CONSTRAINT `students_ibfk_1` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
