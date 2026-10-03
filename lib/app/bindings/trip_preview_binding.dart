import 'package:elbabor/modules/driver/create_trip/viewmodels/create_trip_viewmodel.dart';
import 'package:elbabor/modules/driver/create_trip/viewmodels/trip_preview_viewmodel.dart';
import 'package:get/get.dart';

class TripPreviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TripPreviewViewModel>(() => TripPreviewViewModel());
  }
}
