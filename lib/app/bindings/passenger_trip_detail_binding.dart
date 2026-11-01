import 'package:elbabor/modules/passenger/viewmodels/passenger_trip_detail_viewmodel.dart';
import 'package:get/get.dart';

class PassengerTripDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PassengerTripDetailViewModel());
  }
}
