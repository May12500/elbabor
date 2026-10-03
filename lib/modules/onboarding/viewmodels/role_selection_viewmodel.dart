import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import 'package:get_storage/get_storage.dart';

enum UserRole { driver, passenger }

class RoleSelectionViewModel extends GetxController {
  final selectedRole = Rxn<UserRole>();
  final box = GetStorage();

  void selectRole(UserRole role) {
    selectedRole.value = role;
  }

  void continueNext() {
    if (selectedRole.value != null) {
      box.write('userRole', selectedRole.value.toString());
      Get.offAllNamed(Routes.SIGNIN);
    }
  }
}
