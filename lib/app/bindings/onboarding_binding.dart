import 'package:get/get.dart';
import '../../modules/onboarding/viewmodels/onboarding_viewmodel.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OnboardingViewModel());
  }
}
