// lib/app/routes/app_routes.dart
part of 'app_pages.dart'; // Tetap terhubung

abstract class Routes {
  Routes._();
  static const home = _Paths.home;
  static const login = _Paths.login;
  static const scanPresence = _Paths.scanPresence;

  // --- TAMBAHKAN INI UNTUK ADMIN ---
  static const adminMain = _Paths.adminMain;
  static const adminDashboard = _Paths.adminDashboard;
  static const adminUserManagement = _Paths.adminUserManagement;
  // static const ADMIN_ATTENDANCE = _Paths.ADMIN_ATTENDANCE;
  // static const ADMIN_ANNOUNCEMENTS = _Paths.ADMIN_ANNOUNCEMENTS;

  // Pengumuman
  static const announcementList = _Paths.announcementList;
  static const announcementDetail = _Paths.announcementDetail;
  static const createAnnouncement = _Paths.createAnnouncement;
  // Fitur Ortu
  static const requestLeave = _Paths.requestLeave;
  static const attendanceHistory = _Paths.attendanceHistory;
  // Profil
  static const profile = _Paths.profile;
  static const editProfile = _Paths.editProfile;
  static const changePassword = _Paths.changePassword;
  // Fitur Guru
  static const confirmLeave = _Paths.confirmLeave;
  static const studentList = _Paths.studentList;
  static const studentDetail = _Paths.studentDetail;
  static const leaveList = _Paths.leaveList;

  // --- TAMBAHKAN INI ---
  static const studentProfile = _Paths.studentProfile; // Untuk Ortu
  // --- AKHIR TAMBAHAN ---
}

abstract class _Paths {
  static const home = '/home';
  static const login = '/login';
  static const scanPresence = '/scan-presence';

  // --- TAMBAHKAN INI UNTUK ADMIN ---
  static const adminMain = '/admin';
  static const adminDashboard = '/admin/dashboard';
  static const adminUserManagement = '/admin/users';
  // Tambahkan path lain sesuai kebutuhan (absensi, pengumuman, dll)
  // static const ADMIN_ATTENDANCE = '/admin/attendance';
  // static const ADMIN_ANNOUNCEMENTS = '/admin/announcements';
  // Path pengumuman
  static const announcementList = '/announcements';
  static const announcementDetail = '/announcements/detail';
  static const createAnnouncement = '/announcements/create';
  // Path Ortu
  static const requestLeave = '/request-leave';
  static const attendanceHistory = '/attendance-history';
  // Path Profil
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
  static const changePassword = '/change-password';
  // Path Guru
  static const confirmLeave = '/confirm-leave';
  static const studentList = '/students';
  static const studentDetail = '/students/detail';
  static const leaveList = '/leave-list';

  // --- TAMBAHKAN INI ---
  static const studentProfile = '/student-profile';
  // --- AKHIR TAMBAHAN ---
}
