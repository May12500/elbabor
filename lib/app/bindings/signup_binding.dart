import 'package:get/get.dart';
import '../../modules/auth/viewmodels/signup_viewmodel.dart';

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignupViewModel>(() => SignupViewModel());
  }
}
