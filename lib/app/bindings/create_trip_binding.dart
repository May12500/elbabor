import 'package:elbabor/modules/driver/create_trip/viewmodels/create_trip_viewmodel.dart';
import 'package:get/get.dart';

class CreateTripBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateTripViewModel>(() => CreateTripViewModel());
  }
}
