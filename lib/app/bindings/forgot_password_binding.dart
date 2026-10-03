import 'package:get/get.dart';

import '../../modules/auth/viewmodels/forgot_password_viewmodel.dart';

class ForgotPasswordBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotPasswordViewModel>(() => ForgotPasswordViewModel());
  }
}