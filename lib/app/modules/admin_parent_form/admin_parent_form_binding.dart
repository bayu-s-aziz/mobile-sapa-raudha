import 'package:get/get.dart';
import 'admin_parent_form_controller.dart';

class AdminParentFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminParentFormController>(() => AdminParentFormController());
  }
}
