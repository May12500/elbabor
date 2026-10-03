import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbabor/app/routes/app_routes.dart';
import 'package:elbabor/app/utils/app_snackbar.dart';
import 'package:get/get.dart';

import '../../../data/models/booking_model.dart';
import '../../../data/models/driver_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/driver_repository.dart';
import '../../../data/services/firebase_service.dart';
import '../../booking/view/booking_view.dart';
import '../../booking/viewmodel/booking_viewmodel.dart';
import '../../../data/models/trip_model.dart';


class PassengerTripDetailViewModel extends GetxController {
  final isLoading = false.obs;
  final driver = Rxn<DriverModel>();
  final bookings = <BookingModel>[].obs;

  late TripModel trip;

  // Computed getters
  int get totalSeats => trip.totalSeats;
  int get bookedSeats =>
      bookings.where((b) => b.status == BookingStatus.confirmed).fold(0, (sum, b) => sum + b.seatsBooked);
  int get availableSeats => totalSeats - bookedSeats;

  void setTrip(TripModel t) {
    trip = t;
    fetchDriverInfo(trip.driverId);
    listenToBookings();
  }

  Future<void> fetchDriverInfo(String driverId) async {
    isLoading.value = true;
    try {
      final fetchedDriver = await DriverRepository.getDriverById(driverId);
      if (fetchedDriver != null) {
        driver.value = fetchedDriver;
      } else {
        AppSnackbar.error("Error", "Driver not found");
      }
    } finally {
      isLoading.value = false;
    }
  }

  // 🔁 Real-time listener for bookings
  void listenToBookings() {
    FirebaseFirestore.instance
        .collection('bookings')
        .where('tripId', isEqualTo: trip.id)
        .snapshots()
        .listen((snapshot) {
      bookings.value = snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  void onViewDriverProfile() {
    if (driver.value != null) {
      Get.toNamed(Routes.DRIVER_INFO, arguments: driver.value);
    } else {
      AppSnackbar.info("Info", "Driver details not available yet.");
    }
  }

  final passengerId = FirebaseService.currentUserId;

  Future<void> onBookNow() async {
    try {
      if (availableSeats <= 0) {
        AppSnackbar.error("no_seats".tr, "This trip is fully booked.");
        return;
      }
      Get.to(() => BookingView(), arguments: trip);
    } catch (e) {
      AppSnackbar.error("Error", "Failed to book trip: $e");
    }
  }
}
