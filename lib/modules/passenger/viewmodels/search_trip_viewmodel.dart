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
    showFilters.value = true;
    searchTrips();
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
      final from = fromController.text.trim().toLowerCase();
      final to = toController.text.trim().toLowerCase();
      final date = selectedDate.value;

      // Requête simple : aucun index composite Firebase requis
      final snapshot = await FirebaseService.firestore
          .collection('trips')
          .where('status', isEqualTo: 'active')
          .get();

      var results = snapshot.docs
          .map((e) => TripModel.fromJson(e.data()))
          .toList();

      // 🔹 Filtre Ville de départ (insensible aux majuscules / recherche partielle)
      if (from.isNotEmpty) {
        results = results
            .where((t) => t.fromCity.toLowerCase().contains(from))
            .toList();
      }

      // 🔹 Filtre Ville de destination
      if (to.isNotEmpty) {
        results = results
            .where((t) => t.destinationCity.toLowerCase().contains(to))
            .toList();
      }

      // 🔹 Filtre Date (même jour)
      if (date != null) {
        results = results.where((t) =>
            t.dateTime.year == date.year &&
            t.dateTime.month == date.month &&
            t.dateTime.day == date.day).toList();
      }

      // 🔹 Filtre Type de véhicule
      if (selectedVehicleType.value.isNotEmpty) {
        results = results
            .where((t) =>
                t.vehicleType.toLowerCase() ==
                selectedVehicleType.value.toLowerCase())
            .toList();
      }

      // 🔹 Filtre Sièges
      results = results
          .where((t) => t.seatsAvailable >= selectedSeats.value)
          .toList();

      // 🔹 Filtre Plage horaire
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
            !t.dateTime.isBefore(startDateTime) &&
            !t.dateTime.isAfter(endDateTime)).toList();
      }

      // 🔹 Filtres Prix et Note
      results = results
          .where((t) =>
              t.pricePerPassenger >= minPrice.value &&
              t.pricePerPassenger <= maxPrice.value &&
              t.rating >= minRating.value)
          .toList();

      // 🔹 Tri
      if (selectedSort.value == 'price') {
        results.sort((a, b) => a.pricePerPassenger.compareTo(b.pricePerPassenger));
      } else if (selectedSort.value == 'rating') {
        results.sort((a, b) => b.rating.compareTo(a.rating));
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
