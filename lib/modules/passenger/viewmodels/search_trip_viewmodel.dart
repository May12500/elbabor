import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../data/services/firebase_service.dart';
import '../../../data/models/trip_model.dart';

class SearchTripViewModel extends GetxController {
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final showFilters = true.obs;
  final selectedDate = Rxn<DateTime>();
  final selectedSeats = 1.obs;
  final selectedSort = 'price'.obs;

  final isLoading = false.obs;
  final searchResults = <TripModel>[].obs;

  final minPrice = 0.0.obs;
  final maxPrice = 5000.0.obs;
  final minRating = 0.0.obs;

  final startTime = Rxn<TimeOfDay>();
  final endTime = Rxn<TimeOfDay>();
  final selectedVehicleType = ''.obs;


  @override
  void onInit() {
    super.onInit();
    // Initialize with filters shown
    showFilters.value = true;
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) selectedDate.value = picked;
  }

  String formatDate(DateTime date) =>
      "${date.day}/${date.month}/${date.year}";

  void toggleFilters() {
    showFilters.value = !showFilters.value;
  }

  Future<void> searchTrips() async {
    try {
      isLoading.value = true;
      final from = fromController.text.trim();
      final to = toController.text.trim();
      final date = selectedDate.value;

      var query = FirebaseService.firestore
          .collection('trips')
          .where('status', isEqualTo: 'active');

      if (from.isNotEmpty) query = query.where('fromCity', isEqualTo: from);
      if (to.isNotEmpty) query = query.where('destinationCity', isEqualTo: to);
      if (date != null) {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay =
        DateTime(date.year, date.month, date.day, 23, 59, 59);
        query = query
            .where('dateTime', isGreaterThanOrEqualTo: startOfDay)
            .where('dateTime', isLessThanOrEqualTo: endOfDay);
      }
      if (selectedVehicleType.value.isNotEmpty) {
        query = query.where('vehicleType', isEqualTo: selectedVehicleType.value);
      }

      final snapshot = await query.get();
      var results = snapshot.docs.map((e) => TripModel.fromJson(e.data())).toList();

      // 🔹 Seats filter
      results = results
          .where((t) => t.seatsAvailable >= selectedSeats.value)
          .toList();

      // 🔹 Time range filter (client side)
      if (startTime.value != null && endTime.value != null && date != null) {
        final startDateTime = DateTime(
          date.year, date.month, date.day,
          startTime.value!.hour, startTime.value!.minute,
        );
        final endDateTime = DateTime(
          date.year, date.month, date.day,
          endTime.value!.hour, endTime.value!.minute,
        );
        results = results.where((t) =>
        t.dateTime.isAfter(startDateTime) &&
            t.dateTime.isBefore(endDateTime)
        ).toList();
      }

      // 🔹 Price / Rating / Date sorting
      if (selectedSort.value == 'price') {
        results = results
            .where((t) =>
        t.pricePerPassenger >= minPrice.value &&
            t.pricePerPassenger <= maxPrice.value)
            .toList();
      } else if (selectedSort.value == 'rating') {
        results = results.where((t) => (t.rating) >= minRating.value).toList();
      } else if (selectedSort.value == 'date') {
        results.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      }

      searchResults.assignAll(results);
      final isSmallScreen = Get.height < 1900;
      if (isSmallScreen && searchResults.isNotEmpty) {
        showFilters.value = false;
      }
    } catch (e) {
      print("❌ Error searching trips: $e");
      Get.snackbar("Error", "error_searching_trips".tr);
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters({
    required double minP,
    required double maxP,
    required int seats,
    required double rating,
  }) {
    minPrice.value = minP;
    maxPrice.value = maxP;
    selectedSeats.value = seats;
    minRating.value = rating;

    searchTrips();
  }

  Future<void> pickStartTime() async {
    final picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) startTime.value = picked;
  }

  Future<void> pickEndTime() async {
    final picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) endTime.value = picked;
  }

  String formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return "$hour:$minute $ampm";
  }

  void openTripDetails(TripModel trip) {
    Get.toNamed(Routes.PASSENGER_TRIP_DETAIL, arguments: trip);
  }

}
