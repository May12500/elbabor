import 'package:elbabor/modules/driver/trip_managment/viewmodels/trip_management_viewmodel.dart';
import 'package:get/get.dart';

class TripManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TripManagementViewModel>(() => TripManagementViewModel());
  }
}
