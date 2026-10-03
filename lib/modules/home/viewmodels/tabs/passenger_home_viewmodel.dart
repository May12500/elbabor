import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../data/models/booking_model.dart';
import '../../../../data/models/passenger_model.dart';
import '../../../../data/models/rating_prompt_model.dart'; // Create this model
import '../../../../data/repositories/booking_repository.dart';
import '../../../../data/repositories/passenger_repository.dart';
import '../../../../data/services/firebase_service.dart';
import '../../../../data/models/trip_model.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../passenger/views/all_trips_screen.dart';

class PassengerHomeViewModel extends GetxController {
  final isLoading = false.obs;
  final recommendedTrips = <TripModel>[].obs;
  final upcomingTrips = <TripModel>[].obs;
  final passengerBookings = <BookingModel>[].obs;
  final passengerStats = Rxn<PassengerModel>();
  final popularRoutes = <Map<String, dynamic>>[].obs;
  final pendingRatingPrompts = <RatingPromptModel>[].obs;
  bool hasLoaded = false;
  final RxString currentGreeting = ''.obs;

  // Stream subscription for rating prompts
  StreamSubscription<QuerySnapshot>? _ratingPromptSubscription;
  final hasPendingRating = false.obs;
  final Rx<RatingPromptModel?> currentRatingPrompt = Rx<RatingPromptModel?>(null);

  // Reactive statistics based on actual data
  int get totalBookings => passengerStats.value?.totalBookings ?? 0;
  int get completedTrips => passengerStats.value?.completedBookings ?? 0;
  int get cancelledTrips => passengerStats.value?.cancelledBookings ?? 0;
  int get activeBookings => passengerBookings.where((booking) =>
  booking.status == BookingStatus.confirmed ||
      booking.status == BookingStatus.pending).length;
  RxString passengerName='Passenger'.obs;

  @override
  void onInit() {
    super.onInit();
    _updateGreeting();
    // Update greeting every 10 minutes
    Timer.periodic(const Duration(minutes: 10), (timer) {
      _updateGreeting();
    });
  }

  @override
  void onClose() {
    _ratingPromptSubscription?.cancel();
    super.onClose();
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) currentGreeting.value = 'good_morning'.tr;
    else if (hour < 17) currentGreeting.value = 'good_afternoon'.tr;
    else if (hour < 21) currentGreeting.value = 'good_evening'.tr;
    else currentGreeting.value = 'good_night'.tr;
  }

  Future<void> fetchHomeData(String userId) async {
    try {
      isLoading.value = true;

      // Fetch passenger profile with statistics
      await _fetchPassengerProfile(userId);

      // Fetch passenger's bookings
      await _fetchPassengerBookings(userId);

      // Fetch recommended trips (active trips not booked by this passenger)
      await _fetchRecommendedTrips(userId);

      // Fetch upcoming trips (passenger's confirmed bookings)
      await _fetchUpcomingTrips();

      // Fetch popular routes from actual booking data
      await _fetchPopularRoutes();

      // Start listening for rating prompts
      _startRatingPromptListener(userId);

      hasLoaded = true;
    } catch (e) {
      print('❌ Error fetching home data: $e');
      Get.snackbar('error'.tr, 'failed_to_load_data'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  // Start listening for pending rating prompts
  void _startRatingPromptListener(String userId) {
    _ratingPromptSubscription = FirebaseService.firestore
        .collection('ratingPrompts')
        .where('passengerId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      _handleRatingPrompts(snapshot);
    }, onError: (error) {
      print('❌ Rating prompt stream error: $error');
    });
  }

  void _handleRatingPrompts(QuerySnapshot snapshot) {
    final prompts = snapshot.docs.map((doc) {
      return RatingPromptModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();

    pendingRatingPrompts.assignAll(prompts);
    hasPendingRating.value = prompts.isNotEmpty;

    // If there are pending ratings, set the current one to show
    if (prompts.isNotEmpty) {
      currentRatingPrompt.value = prompts.first;
      // Automatically show rating dialog after a short delay
      _showRatingPromptIfNeeded();
    }
  }

  void _showRatingPromptIfNeeded() {
    if (hasPendingRating.value && currentRatingPrompt.value != null) {
      // Wait for the UI to load completely
      Future.delayed(const Duration(seconds: 2), () {
        if (hasPendingRating.value) {
          showRatingDialog(currentRatingPrompt.value!);
        }
      });
    }
  }

  void showRatingDialog(RatingPromptModel prompt) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(
              Icons.star_rate_rounded,
              size: 48,
              color: AppColors.warning,
            ),
            const SizedBox(height: 8),
            Text(
              "rate_your_trip".tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "how_was_your_trip_experience".tr,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "your_feedback_helps_improve_service".tr,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _dismissRatingPrompt(prompt),
            child: Text(
              "maybe_later".tr,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => _navigateToRatingScreen(prompt),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text("rate_now".tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _navigateToRatingScreen(RatingPromptModel prompt) {
    Get.back(); // Close the dialog

    // Navigate to rating screen and wait for result
    Get.toNamed(
      Routes.RATING,
      arguments: {
        'bookingId': prompt.bookingId,
        'tripId': prompt.tripId,
        'driverId': prompt.driverId,
      },
    )?.then((result) {
      // This will be called when the rating screen closes
      if (result == true) {
        debugPrint("✅ Rating submitted successfully, refreshing data...");
        // Refresh the pending ratings list
        _refreshPendingRatings();
      }
    });
  }

  void _refreshPendingRatings() {
    final userId = FirebaseService.currentUserId;
    if (userId != null) {
      // Re-fetch pending ratings to update the UI
      _handleRatingPromptsAfterSubmission();
    }
  }
  void _handleRatingPromptsAfterSubmission() {
    // Remove the current rating prompt since it was completed
    if (currentRatingPrompt.value != null) {
      pendingRatingPrompts.removeWhere((prompt) => prompt.id == currentRatingPrompt.value!.id);
      hasPendingRating.value = pendingRatingPrompts.isNotEmpty;

      if (hasPendingRating.value) {
        currentRatingPrompt.value = pendingRatingPrompts.first;
      } else {
        currentRatingPrompt.value = null;
      }
    }
  }
  void _dismissRatingPrompt(RatingPromptModel prompt) {
    // Mark as dismissed in Firestore
    FirebaseService.firestore
        .collection('ratingPrompts')
        .doc(prompt.id)
        .update({
      'status': 'pending',
      'dismissedAt': FieldValue.serverTimestamp(),
    });

    Get.back(); // Close the dialog
    hasPendingRating.value = false;
    currentRatingPrompt.value = null;
  }

  // Check if there are any pending ratings (for badge display)
  bool get hasPendingRatings {
    return pendingRatingPrompts.isNotEmpty;
  }

  // Get the count of pending ratings (for badge)
  int get pendingRatingCount {
    return pendingRatingPrompts.length;
  }

  Future<void> _fetchPassengerProfile(String userId) async {
    try {
      final passenger = await PassengerRepository.getPassengerById(userId);
      if (passenger != null) {
        passengerStats.value = passenger;
        passengerName.value=passenger.name;
      }
    } catch (e) {
      print('❌ Error fetching passenger profile: $e');
    }
  }

  Future<void> _fetchPassengerBookings(String userId) async {
    try {
      final bookings = await BookingRepository.getPassengerBookings(userId);
      passengerBookings.assignAll(bookings);
    } catch (e) {
      print('❌ Error fetching passenger bookings: $e');
    }
  }

  Future<void> _fetchRecommendedTrips(String userId) async {
    try {
      // Get trips that are active and not booked by this passenger
      final tripsSnapshot = await FirebaseService.firestore
          .collection('trips')
          .where('status', isEqualTo: 'active')
          .where('dateTime', isGreaterThanOrEqualTo: DateTime.now())
          .where('seatsAvailable', isGreaterThanOrEqualTo: 1)
          .orderBy('dateTime')
          .limit(10)
          .get();

      final trips = tripsSnapshot.docs
          .map((doc) => TripModel.fromJson(doc.data()))
          .toList();
      recommendedTrips.assignAll(trips);
    } catch (e) {
      print('❌ Error fetching recommended trips: $e');
    }
  }

  Future<void> _fetchUpcomingTrips() async {
    try {
      // Get passenger's confirmed bookings that are in the future
      final upcomingBookings = passengerBookings.where((booking) =>
      booking.status == BookingStatus.confirmed &&
          booking.tripDateTime.isAfter(DateTime.now()))
          .toList();

      // Convert bookings to trip models for display
      final upcomingTripIds = upcomingBookings.map((b) => b.tripId).toSet();

      if (upcomingTripIds.isNotEmpty) {
        final tripsSnapshot = await FirebaseService.firestore
            .collection('trips')
            .where(FieldPath.documentId, whereIn: upcomingTripIds.toList())
            .get();

        final trips = tripsSnapshot.docs
            .map((doc) => TripModel.fromJson(doc.data()))
            .toList();

        upcomingTrips.assignAll(trips);
      }
    } catch (e) {
      print('❌ Error fetching upcoming trips: $e');
    }
  }

  Future<void> _fetchPopularRoutes() async {
    try {
      // Get popular routes from actual booking data
      final bookingsSnapshot = await FirebaseService.firestore
          .collection('bookings')
          .where('status', isEqualTo: BookingStatus.confirmed.name)
          .where('tripDateTime', isGreaterThan: DateTime.now().subtract(const Duration(days: 30)))
          .get();

      // Count routes by fromCity → destinationCity
      final routeCounts = <String, int>{};

      for (final doc in bookingsSnapshot.docs) {
        try {
          final booking = BookingModel.fromMap(doc.data(), doc.id);

          // Skip if cities are empty
          if (booking.fromCity.isEmpty || booking.destinationCity.isEmpty) {
            continue;
          }

          final routeKey = '${booking.fromCity} → ${booking.destinationCity}';
          routeCounts[routeKey] = (routeCounts[routeKey] ?? 0) + 1;
        } catch (e) {
          print('❌ Error parsing booking ${doc.id}: $e');
          continue; // Skip this booking if there's an error
        }
      }

      // Convert to list and sort by popularity
      final popularRoutesList = routeCounts.entries
          .map((entry) => {'route': entry.key, 'trips': entry.value})
          .toList()
        ..sort((a, b) => (b['trips'] as int).compareTo(a['trips'] as int));

      popularRoutes.assignAll(popularRoutesList.take(4));
    } catch (e) {
      print('❌ Error fetching popular routes: $e');

      // Fallback to mock data if real data fails
      popularRoutes.assignAll([
        {'route': 'Karachi → Lahore', 'trips': 24},
        {'route': 'Islamabad → Peshawar', 'trips': 18},
        {'route': 'Lahore → Islamabad', 'trips': 22},
        {'route': 'Karachi → Islamabad', 'trips': 15},
      ]);
    }
  }

  // Get today's bookings for quick access
  List<BookingModel> get todaysBookings {
    final today = DateTime.now();
    return passengerBookings.where((booking) =>
    booking.tripDateTime.year == today.year &&
        booking.tripDateTime.month == today.month &&
        booking.tripDateTime.day == today.day).toList();
  }

  // Refresh all data
  Future<void> refreshData(String userId) async {
    await fetchHomeData(userId);
  }

  // Navigation methods
  void onSearchTap() => Get.toNamed(Routes.SEARCH_TRIP);
  void onFindTrip() => Get.toNamed(Routes.SEARCH_TRIP);
  void openTripDetails(TripModel trip) =>
      Get.toNamed(Routes.PASSENGER_TRIP_DETAIL, arguments: trip);

  void openBookingDetails(BookingModel booking) {
    // Navigate to booking details page
    Get.toNamed(Routes.PASSENGER_TRIP_DETAIL, arguments: booking);
  }

  void openAllRecommendedTrips() {
    Get.to(
          () => AllTripsScreen(
        screenTitle: 'all_recommended_trips'.tr,
        trips: recommendedTrips,
        tripType: TripType.recommended,
      ),
    );
  }

  void openAllUpcomingTrips() {
    Get.to(
          () => AllTripsScreen(
        screenTitle: 'my_upcoming_trips'.tr,
        trips: upcomingTrips,
        tripType: TripType.upcoming,
      ),
    );
  }
}