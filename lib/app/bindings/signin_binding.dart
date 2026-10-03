import 'package:elbabor/modules/auth/viewmodels/signin_viewmodel.dart';
import 'package:get/get.dart';
import '../../modules/auth/viewmodels/auth_viewmodel.dart';

class SigninBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SigninViewModel>(() => SigninViewModel());
  }
}
