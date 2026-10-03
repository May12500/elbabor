import 'package:elbabor/modules/home/viewmodels/driver_dashboard_viewmodel.dart';
import 'package:get/get.dart';

class DriverDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverDashboardViewModel>(() => DriverDashboardViewModel());
  }
}
