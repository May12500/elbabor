import 'package:get/get.dart';
import '../../../../data/models/trip_model.dart';
import '../../../../data/services/firebase_service.dart';
import '../../home/repository/driver_home_repository.dart';

class TripManagementViewModel extends GetxController {
  final RxList<TripModel> activeTrips = <TripModel>[].obs;
  final RxList<TripModel> pastTrips = <TripModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentTabIndex = 0.obs;

  bool hasLoaded = false;

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  Future<void> refreshTrips() async {
    final driverId = FirebaseService.currentUserId;
    if (driverId != null) {
      hasLoaded = false;
      await fetchDriverTrips(driverId);
    }
  }

  Future<void> fetchDriverTrips(String driverId) async {
    if (hasLoaded) return;

    try {
      isLoading.value = true;

      final categorizedTrips = await DriverHomeRepository.getCategorizedTrips(driverId);

      activeTrips.assignAll(categorizedTrips['active'] ?? []);
      pastTrips.assignAll(categorizedTrips['past'] ?? []);

      hasLoaded = true;
    } catch (e) {
      print("❌ Error fetching categorized trips: $e");
      Get.snackbar("error".tr, "failed_to_load_trips".tr);
    } finally {
      isLoading.value = false;
    }
  }

  // Alternative approach using separate repository methods
  Future<void> fetchActiveTrips(String driverId) async {
    try {
      final now = DateTime.now();
      final activeTripsList = await DriverHomeRepository.getActiveTrips(driverId);

      // Filter only future trips
      final futureTrips = activeTripsList.where((trip) => trip.dateTime.isAfter(now)).toList();

      activeTrips.assignAll(futureTrips);
    } catch (e) {
      print("❌ Error fetching active trips: $e");
    }
  }

  Future<void> fetchPastTrips(String driverId) async {
    try {
      final pastTripsList = await _getPastTripsFromRepository(driverId);
      pastTrips.assignAll(pastTripsList);
    } catch (e) {
      print("❌ Error fetching past trips: $e");
    }
  }

  // Helper method until we extend the repository
  Future<List<TripModel>> _getPastTripsFromRepository(String driverId) async {
    // This would be better as a repository method
    final activeTrips = await DriverHomeRepository.getActiveTrips(driverId);
    final now = DateTime.now();

    return activeTrips.where((trip) =>
    trip.dateTime.isBefore(now) ||
        trip.status == 'completed' ||
        trip.status == 'cancelled'
    ).toList();
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      await DriverHomeRepository.deleteTrip(tripId);

      // Remove from both lists
      activeTrips.removeWhere((t) => t.id == tripId);
      pastTrips.removeWhere((t) => t.id == tripId);

      Get.snackbar(
        "success".tr,
        "trip_deleted_successfully".tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print("❌ Error deleting trip: $e");
      Get.snackbar(
        "error".tr,
        "failed_to_delete_trip".tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Helper method to check if a trip is active
  bool isTripActive(TripModel trip) {
    final now = DateTime.now();
    return (trip.status == 'draft' || trip.status == 'active' || trip.status == 'scheduled') &&
        trip.dateTime.isAfter(now);
  }

  // Helper method to check if a trip is expired
  bool isTripExpired(TripModel trip) {
    final now = DateTime.now();
    return trip.dateTime.isBefore(now) &&
        (trip.status == 'draft' || trip.status == 'active' || trip.status == 'scheduled');
  }
}