import 'package:elbabor/modules/common/profile/viewmodel/profile_viewmodel.dart';
import 'package:get/get.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileViewModel>(() => ProfileViewModel());
  }
}
