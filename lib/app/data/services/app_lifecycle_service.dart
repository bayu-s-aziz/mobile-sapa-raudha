import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:sapa_raudha/app/data/services/profile_service.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';
import 'package:sapa_raudha/app/data/services/local_storage_service.dart';
import 'package:sapa_raudha/app/data/services/secure_storage_service.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';

class AppLifecycleService extends GetxService with WidgetsBindingObserver {
  late final ProfileService _profile;
  late final ApiClient _api;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _profile = Get.find<ProfileService>();
    _api = Get.find<ApiClient>();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Validate token — if invalid, handleUnauthorized is called
      _validate();
    }
  }

  Future<void> _validate() async {
    try {
      // Only attempt validation if a token exists in either storage
      String? token;
      if (Get.isRegistered<LocalStorageService>()) {
        try {
          token = Get.find<LocalStorageService>().read<String>('auth_token');
        } catch (_) {
          token = null;
        }
      }

      if (token == null || token.isEmpty) {
        if (Get.isRegistered<SecureStorageService>()) {
          try {
            token = await Get.find<SecureStorageService>().read('auth_token');
          } catch (_) {
            token = null;
          }
        }
      }

      if (token == null || (token.isEmpty)) {
        developer.log(
          '[Lifecycle] No auth token present - skipping validation',
          name: 'AppLifecycleService',
        );
        return;
      }

      await _profile.validateToken();
    } catch (e) {
      // If validation fails with ApiException (401), central handler in ApiClient
      // may not have been triggered (e.g., profile.validateToken throws), so
      // proactively call handleUnauthorized to ensure consistent behavior.
      try {
        await _api.handleUnauthorized(reason: 'lifecycle-validate');
      } catch (_) {}
    }
  }
}
