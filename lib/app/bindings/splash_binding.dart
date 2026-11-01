import 'package:get/get.dart';
import '../../modules/onboarding/viewmodels/splash_viewmodel.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashViewModel>(() => SplashViewModel());
  }
}
