import 'package:get/get.dart';
import '../../modules/onboarding/viewmodels/role_selection_viewmodel.dart';

class RoleSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoleSelectionViewModel>(() => RoleSelectionViewModel());
  }
}
