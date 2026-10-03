import 'package:elbabor/modules/auth/viewmodels/driver_details_viewmodel.dart';
import 'package:get/get.dart';

class DriverDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverDetailsViewModel>(() => DriverDetailsViewModel());
  }
}
