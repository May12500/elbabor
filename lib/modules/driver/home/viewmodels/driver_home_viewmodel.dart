import 'dart:async';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../data/services/firebase_service.dart';
import '../../../../data/models/driver_model.dart';
import '../../../passenger/views/all_trips_screen.dart';
import '../../../../data/models/trip_model.dart';
import '../../views/all_driver_trips_screen.dart';
import '../repository/driver_home_repository.dart';

class DriverHomeViewModel extends GetxController {
  final isLoading = true.obs;
  final activeTrips = <TripModel>[].obs;
  final upcomingTrips = <TripModel>[].obs;
  final completedTrips = <TripModel>[].obs;
  final driverProfile = Rxn<DriverModel>();
  final hasLoaded = false.obs;
  final statsLoading = true.obs;
  final RxString currentGreeting = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    _updateGreeting();
    // Update every minute
    Timer.periodic(const Duration(minutes: 10), (timer) {
      _updateGreeting();
    });
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) currentGreeting.value = 'good_morning'.tr;
    else if (hour < 17) currentGreeting.value = 'good_afternoon'.tr;
    else if (hour < 21) currentGreeting.value = 'good_evening'.tr;
    else currentGreeting.value = 'good_night'.tr;
  }
  void openAllActiveTrips() {
    Get.to(() => AllDriverTripsScreen(
        screenTitle: 'all_active_trips'.tr,
        trips: activeTrips,
        tripType: TripType.active,
      ),
    );
  }

  void openAllUpcomingTrips() {
    Get.to(() => AllDriverTripsScreen(
        screenTitle: 'all_upcoming_trips'.tr,
        trips: upcomingTrips,
        tripType: TripType.upcoming,
      ),
    );
  }
  Future<void> _initializeData() async {
    final driverId = FirebaseService.currentUserId;
    if (driverId == null) return;

    await Future.wait([
      fetchDriverProfile(driverId),
      fetchActiveTrips(driverId),
      fetchUpcomingTrips(driverId),
    ]);

    hasLoaded.value = true;
  }

  Future<void> fetchDriverProfile(String driverId) async {
    try {
      statsLoading.value = true;
      final driver = await DriverHomeRepository.getDriverProfile(driverId);
      if (driver != null) {
        driverProfile.value = driver;
      }
    } catch (e) {
      print('Error fetching driver profile: $e');
    } finally {
      statsLoading.value = false;
    }
  }

  Future<void> fetchActiveTrips(String driverId) async {
    try {
      isLoading.value = true;
      final trips = await DriverHomeRepository.getActiveTrips(driverId);
      activeTrips.assignAll(trips);
    } catch (e) {
      print('Error fetching active trips: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUpcomingTrips(String driverId) async {
    try {
      final trips = await DriverHomeRepository.getUpcomingTrips(driverId);
      upcomingTrips.assignAll(trips);
    } catch (e) {
      print('Error fetching upcoming trips: $e');
    }
  }

  Future<void> refreshData() async {
    final driverId = FirebaseService.currentUserId;
    if (driverId != null) {
      await _initializeData();
    }
  }

  // Stats calculations
  double get completionRate {
    final driver = driverProfile.value;
    if (driver == null || driver.totalTrips == 0) return 0.0;
    return (driver.completedTrips / driver.totalTrips) * 100;
  }

  int get todayTrips {
    final today = DateTime.now();
    return activeTrips.where((trip) {
      return trip.dateTime.year == today.year &&
          trip.dateTime.month == today.month &&
          trip.dateTime.day == today.day;
    }).length;
  }

  double get totalEarnings {
    double earnings = 0.0;
    for (final trip in activeTrips) {
      final bookedSeats = trip.totalSeats - trip.seatsAvailable;
      earnings += bookedSeats * trip.pricePerPassenger;
    }
    return earnings;
  }
}