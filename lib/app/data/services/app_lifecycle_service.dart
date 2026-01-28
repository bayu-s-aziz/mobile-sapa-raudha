import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/services/profile_service.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';
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
      await _profile.validateToken();
    } catch (e) {
      // If validation fails with ApiException (401), central handler in ApiClient
      // may not have been triggered (e.g., profile.validateToken throws), so
      // proactively call handleUnauthorized to ensure consistent behavior.
      try {
        await _api.handleUnauthorized();
      } catch (_) {}
    }
  }
}
