import 'package:elbabor/modules/home/viewmodels/driver_dashboard_viewmodel.dart';
import 'package:get/get.dart';

import '../../modules/home/viewmodels/passenger_dashboard_viewmodel.dart';

class PassengerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerDashboardViewModel>(() => PassengerDashboardViewModel());
  }
}
