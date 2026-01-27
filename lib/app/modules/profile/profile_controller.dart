// lib/app/modules/profile/profile_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/routes/app_pages.dart';
import 'package:sapa_raudha/app/data/services/profile_service.dart';
import 'package:sapa_raudha/app/modules/home/home_controller.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';

class ProfileController extends GetxController {
  final RxMap<String, dynamic> profile = <String, dynamic>{}.obs;
  final RxBool isLoading = true.obs;

  late final ProfileService _profileService = Get.find<ProfileService>();
  late final HomeController _homeController = Get.find<HomeController>();

  @override
  void onInit() {
    super.onInit();
    // Try to sync from HomeController first (already fetched during login)
    if (_homeController.userName.value.isNotEmpty) {
      _syncFromHome();
    }
    loadProfile();
  }

  void _syncFromHome() {
    // If HomeController already has profile data, use it
    final homeProfile = _profileService.getStoredProfile();
    if (homeProfile != null && homeProfile.isNotEmpty) {
      profile.value = homeProfile;
    }
  }

  Future<void> loadProfile() async {
    isLoading(true);
    try {
      final cached = _profileService.getStoredProfile();
      if (cached != null && cached.isNotEmpty) {
        profile.assignAll(cached);
        profile.refresh(); // Force reactive update
      }

      final fresh = await _profileService.fetchProfile();
      if (fresh.isNotEmpty) {
        profile.assignAll(fresh);
        profile.refresh(); // Force reactive update
      }
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat profil: $e');
    } finally {
      isLoading(false);
    }
  }

  String get userName {
    // For parents, derive name from father/mother/guardian fields
    final role = (profile['role'] as String?)?.toLowerCase() ?? '';

    if (role == 'orangtua') {
      final father = profile['father_name'] as String?;
      final mother = profile['mother_name'] as String?;
      final guardian = profile['guardian_name'] as String?;

      return father?.isNotEmpty == true
          ? father!
          : (mother?.isNotEmpty == true
                ? mother!
                : (guardian?.isNotEmpty == true ? guardian! : 'Orang Tua'));
    }
    return (profile['name'] as String?) ?? 'Pengguna';
  }

  String get userRole => (profile['role'] as String?) ?? '-';
  String get userEmail => (profile['email'] as String?) ?? '-';
  String? get userPhotoUrl =>
      Get.find<ProfileService>().getNormalizedUserPhotoUrl() ??
      profile['photo_url'] as String?;
  String? get userPhone => profile['phone'] as String?;

  // Additional getters for parents
  String get studentName {
    // Try several possible locations for student name to support parents and students
    final nameTop = (profile['student_name'] as String?)?.trim();
    if (nameTop != null && nameTop.isNotEmpty) return nameTop;

    // Check nested student in profile (common for parent userable)
    final userable = profile['userable'] as Map<String, dynamic>?;
    final nestedStudent = userable != null
        ? (userable['student'] as Map<String, dynamic>?)
        : null;
    final nestedName = nestedStudent != null
        ? (nestedStudent['name'] as String?)
        : null;
    if (nestedName != null && nestedName.isNotEmpty) return nestedName;

    // Check alternative keys
    final alt = (profile['anak'] != null && profile['anak'] is Map)
        ? (profile['anak']['name'] as String?)
        : null;
    if (alt != null && alt.isNotEmpty) return alt;

    // Fallback to empty placeholder
    return '-';
  }

  String get studentClass {
    final kls = (profile['class_name'] as String?) ?? '-';

    return kls;
  }

  void goToEditProfile() {
    Get.toNamed(Routes.editProfile);
  }

  void goToChangePassword() {
    Get.toNamed(Routes.changePassword);
  }

  void logout() {
    _homeController.confirmLogout();
  }
}
