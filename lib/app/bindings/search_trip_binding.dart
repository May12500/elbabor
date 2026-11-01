import 'package:elbabor/modules/passenger/viewmodels/search_trip_viewmodel.dart';
import 'package:get/get.dart';
class SearchTripBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchTripViewModel>(() => SearchTripViewModel());
  }
}
