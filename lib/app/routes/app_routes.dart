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
  static const adminAnnouncementManagement = _Paths.adminAnnouncementManagement;
  static const adminAnnouncementAdd = _Paths.adminAnnouncementAdd;
  static const adminAnnouncementEdit = _Paths.adminAnnouncementEdit;
  static const adminAnnouncementDetail = _Paths.adminAnnouncementDetail;
  static const adminTeacherForm = _Paths.adminTeacherForm;
  static const adminParentForm = _Paths.adminParentForm;
  static const adminStudentManagement = _Paths.adminStudentManagement;
  static const adminStudentForm = _Paths.adminStudentForm;

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
  static const adminAnnouncementManagement = '/admin/announcements';
  static const adminAnnouncementAdd = '/admin/announcements/add';
  static const adminAnnouncementEdit = '/admin/announcements/edit';
  static const adminAnnouncementDetail = '/admin/announcements/detail';
  static const adminTeacherForm = '/admin/teachers/form';
  static const adminParentForm = '/admin/parents/form';
  static const adminStudentManagement = '/admin/students';
  static const adminStudentForm = '/admin/students/form';
  // Tambahkan path lain sesuai kebutuhan (absensi, dll)
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
