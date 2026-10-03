import 'package:get/get.dart';
import '../../modules/driver/trip_details/viewmodels/trip_detail_viewmodel.dart';

class TripDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TripDetailViewModel());
  }
}
