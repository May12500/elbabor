import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../data/models/passenger_model.dart';
import '../../../../../data/repositories/booking_repository.dart';
import '../../../../../data/repositories/passenger_repository.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../data/models/rating_model.dart';
import '../../../../data/models/trip_model.dart';
import '../../../../../data/models/booking_model.dart';

class TripDetailViewModel extends GetxController {
  final isLoading = false.obs;
  final passengers = <PassengerModel>[].obs;
  final bookings = <BookingModel>[].obs;
  final passengerBookings = <String, List<BookingModel>>{}.obs; // Group bookings by passenger
  late TripModel trip;
  final isCompleting = false.obs;

  final tripRatings = <RatingModel>[].obs;
  final isLoadingRatings = false.obs;
  final averageTripRating = 0.0.obs;
  final totalTripRatings = 0.obs;

  // Check if trip can be completed
  bool get canCompleteTrip {
    return trip.status == 'active' && trip.dateTime.isBefore(DateTime.now());
  }

  Future<void> fetchTripRatings() async {
    isLoadingRatings.value = true;

    try {
      debugPrint("📊 Fetching ratings for trip: ${trip.id}");

      final ratingsSnapshot = await FirebaseFirestore.instance
          .collection('ratings')
          .where('tripId', isEqualTo: trip.id)
          .orderBy('createdAt', descending: true)
          .get();

      final ratings = ratingsSnapshot.docs.map((doc) {
        return RatingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      tripRatings.assignAll(ratings);
      totalTripRatings.value = ratings.length;

      // Calculate average rating
      if (ratings.isNotEmpty) {
        final total = ratings.fold(0.0, (sum, rating) => sum + rating.rating);
        averageTripRating.value = double.parse((total / ratings.length).toStringAsFixed(1));
      } else {
        averageTripRating.value = 0.0;
      }

      debugPrint("✅ Found ${ratings.length} ratings for trip ${trip.id}");
      debugPrint("⭐ Average rating: ${averageTripRating.value}");

    } catch (e) {
      debugPrint("❌ Error fetching trip ratings: $e");
      Get.snackbar(
        "error".tr,
        "failed_to_load_ratings".tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingRatings.value = false;
    }
  }

  // Get rating distribution (how many of each star)
  Map<int, int> get ratingDistribution {
    final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (final rating in tripRatings) {
      final star = rating.rating.toInt();
      distribution[star] = (distribution[star] ?? 0) + 1;
    }

    return distribution;
  }

  // Get percentage for each star rating
  double getRatingPercentage(int stars) {
    if (totalTripRatings.value == 0) return 0.0;
    final count = ratingDistribution[stars] ?? 0;
    return (count / totalTripRatings.value) * 100;
  }

  // Check if trip has ratings
  bool get hasRatings => tripRatings.isNotEmpty;

  // Initialize ratings when trip is set
  void setTrip(TripModel t) {
    trip = t;
    fetchBookings();
    fetchTripRatings(); // Fetch ratings when trip is set
  }

  // Fetch all bookings for this trip using BookingRepository
  Future<void> fetchBookings() async {
    isLoading.value = true;
    try {
      // Use the existing BookingRepository to get trip bookings
      final bookingList = await BookingRepository.getTripBookings(trip.id);

      // Filter only confirmed and active bookings
      final confirmedBookings = bookingList.where((booking) =>
      booking.status == BookingStatus.confirmed ||
          booking.status == BookingStatus.completed
      ).toList();
      print("Fetched ${bookingList.length} bookings:");
      for (var b in bookingList) {
        print("Booking ${b.id} → paid=${b.paid}, createdAt=${b.createdAt}, status=${b.status}");
      }
      bookings.assignAll(confirmedBookings);

      // Group bookings by passenger
      _groupBookingsByPassenger(confirmedBookings);

      // Fetch passenger details for each unique passenger
      await _fetchPassengersForBookings(confirmedBookings);

    } catch (e) {
      print("Error loading bookings: $e");
      Get.snackbar(
        "error".tr,
        "failed_to_load_bookings".tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Group bookings by passenger ID
  void _groupBookingsByPassenger(List<BookingModel> bookingList) {
    passengerBookings.clear();
    for (final booking in bookingList) {
      if (!passengerBookings.containsKey(booking.passengerId)) {
        passengerBookings[booking.passengerId] = [];
      }
      passengerBookings[booking.passengerId]!.add(booking);
    }
  }

  // Fetch passenger details for bookings
  Future<void> _fetchPassengersForBookings(List<BookingModel> bookingList) async {
    final List<PassengerModel> passengerList = [];
    final Set<String> processedPassengers = {};

    for (final booking in bookingList) {
      // Skip if we already processed this passenger
      if (processedPassengers.contains(booking.passengerId)) continue;

      try {
        // Use PassengerRepository to get actual passenger data
        final passenger = await PassengerRepository.getPassengerById(booking.passengerId);

        if (passenger != null) {
          // Get passenger stats
          final bookingStats = await _getPassengerBookingStats(booking.passengerId);

          final updatedPassenger = passenger.copyWith(
            totalBookings: bookingStats['totalBookings'] ?? 0,
            completedBookings: bookingStats['completedBookings'] ?? 0,
            cancelledBookings: bookingStats['cancelledBookings'] ?? 0,
          );

          passengerList.add(updatedPassenger);
          processedPassengers.add(booking.passengerId);
        } else {
          // Fallback: Create passenger from booking data
          final fallbackPassenger = PassengerModel(
            uid: booking.passengerId,
            name: "Passenger", // Will be updated with actual name if available
            email: "No email",
            role: 'Passenger',
            phoneNumber: null,
            totalBookings: 0,
            completedBookings: 0,
            cancelledBookings: 0,
            profileCompleted: false,
          );
          passengerList.add(fallbackPassenger);
          processedPassengers.add(booking.passengerId);
        }
      } catch (e) {
        print("Error fetching passenger for booking ${booking.id}: $e");
      }
    }

    passengers.assignAll(passengerList);
  }

  // Get all bookings for a specific passenger
  List<BookingModel> getBookingsForPassenger(String passengerId) {
    return passengerBookings[passengerId] ?? [];
  }

  // Get combined seat numbers for a passenger (across all their bookings)
  List<int> getSeatNumbers(String passengerId) {
    final bookings = getBookingsForPassenger(passengerId);
    final allSeats = <int>[];
    for (final booking in bookings) {
      allSeats.addAll(booking.seatNumbers);
    }
    return allSeats;
  }

  // Get total seats booked by passenger (across all their bookings)
  int getTotalSeatsBooked(String passengerId) {
    final bookings = getBookingsForPassenger(passengerId);
    return bookings.fold<int>(0, (sum, booking) => sum + booking.seatsBooked);
  }

  // Get total amount paid by passenger (across all their bookings)
  double getTotalAmount(String passengerId) {
    final bookings = getBookingsForPassenger(passengerId);
    return bookings.fold<double>(0, (sum, booking) => sum + booking.price);
  }

  // Get earliest booking date for passenger
  DateTime? getBookingDate(String passengerId) {
    final bookings = getBookingsForPassenger(passengerId);
    if (bookings.isEmpty) return null;

    DateTime? earliestDate;
    for (final booking in bookings) {
      if (earliestDate == null || booking.createdAt.isBefore(earliestDate)) {
        earliestDate = booking.createdAt;
      }
    }
    return earliestDate;
  }

  // Get payment methods used by passenger
  List<String> getPaymentMethods(String passengerId) {
    final bookings = getBookingsForPassenger(passengerId);
    final methods = <String>{};
    for (final booking in bookings) {
      methods.add(booking.paymentMethod.name);
    }
    return methods.toList();
  }

  // Get booking status for passenger (most recent booking)
  String getBookingStatus(String passengerId) {
    final bookings = getBookingsForPassenger(passengerId);
    if (bookings.isEmpty) return 'unknown';

    // Return the status of the most recent booking
    bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bookings.first.status.name;
  }

  // Check if passenger has paid for all bookings
  bool hasPassengerPaid(String passengerId) {
    final bookings = getBookingsForPassenger(passengerId);
    if (bookings.isEmpty) return false;
    return bookings.every((booking) => booking.paid);
  }

  Future<Map<String, int>> _getPassengerBookingStats(String passengerId) async {
    try {
      final passengerBookings = await BookingRepository.getPassengerBookings(passengerId);

      final totalBookings = passengerBookings.length;
      final completedBookings = passengerBookings
          .where((booking) => booking.status == BookingStatus.completed)
          .length;
      final cancelledBookings = passengerBookings
          .where((booking) => booking.status == BookingStatus.cancelled)
          .length;

      return {
        'totalBookings': totalBookings,
        'completedBookings': completedBookings,
        'cancelledBookings': cancelledBookings,
      };
    } catch (e) {
      print("Error fetching booking stats: $e");
      return {
        'totalBookings': 0,
        'completedBookings': 0,
        'cancelledBookings': 0,
      };
    }
  }

  // Calculate total booked seats across all passengers
  int get totalBookedSeats {
    return bookings.fold<int>(0, (sum, booking) => sum + booking.seatsBooked);
  }

  // Calculate total revenue from all bookings
  double get totalRevenue {
    return bookings.fold<double>(0, (sum, booking) => sum + booking.price);
  }

  Future<void> refreshPassengers() async {
    await fetchBookings();
  }

  // Complete trip method
  Future<void> completeTrip() async {
    if (!canCompleteTrip) {
      Get.snackbar(
        "cannot_complete".tr,
        "trip_cannot_be_completed_yet".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    isCompleting.value = true;

    try {
      final firestore = FirebaseFirestore.instance;

      // Update trip status to completed
      await firestore.collection('trips').doc(trip.id).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

      // Update all bookings for this trip to completed status
      final bookingsSnapshot = await firestore
          .collection('bookings')
          .where('tripId', isEqualTo: trip.id)
          .where('status', whereIn: ['confirmed', 'active'])
          .get();

      final batch = firestore.batch();

      for (final bookingDoc in bookingsSnapshot.docs) {
        batch.update(bookingDoc.reference, {
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
        });

        // Create rating prompts for each passenger
        final bookingData = bookingDoc.data();
        await _createRatingPrompt(
          bookingId: bookingDoc.id,
          tripId: trip.id,
          passengerId: bookingData['passengerId'],
          driverId: trip.driverId,
          passengerName: bookingData['passengerName'] ?? 'Passenger',
        );
      }

      await batch.commit();

      // Update driver stats
      await _updateDriverStats();

      // Show success message
      Get.snackbar(
        "trip_completed".tr,
        "trip_marked_completed_success".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withOpacity(0.9),
        colorText: Colors.white,
      );

      // Refresh the trip data
      await fetchBookings();

      // Update local trip status
      trip = trip.copyWith(status: 'completed');

    } catch (e) {
      Get.snackbar(
        "error".tr,
        "failed_to_complete_trip".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
      debugPrint("Complete trip error: $e");
    } finally {
      isCompleting.value = false;
    }
  }

  // Create rating prompt for passenger
  Future<void> _createRatingPrompt({
    required String bookingId,
    required String tripId,
    required String passengerId,
    required String driverId,
    required String passengerName,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      await firestore.collection('ratingPrompts').doc(bookingId).set({
        'bookingId': bookingId,
        'tripId': tripId,
        'passengerId': passengerId,
        'driverId': driverId,
        'passengerName': passengerName,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending', // pending, completed, dismissed
        'reminderSent': false,
      });
    } catch (e) {
      debugPrint("Error creating rating prompt: $e");
    }
  }

  // Update driver statistics
  Future<void> _updateDriverStats() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final driverRef = firestore.collection('users').doc(trip.driverId);

      // Get current driver stats
      final driverDoc = await driverRef.get();
      final driverData = driverDoc.data() ?? {};

      final currentCompletedTrips = driverData['completedTrips'] ?? 0;
      final currentTotalTrips = driverData['totalTrips'] ?? 0;

      // Update driver stats
      await driverRef.update({
        'completedTrips': currentCompletedTrips + 1,
        'totalTrips': currentTotalTrips + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      debugPrint("Error updating driver stats: $e");
    }
  }

  // Get completion status text
  String get completionStatusText {
    if (trip.isCompleted) {
      return "trip_completed".tr;
    } else if (canCompleteTrip) {
      return "ready_to_complete".tr;
    } else {
      return "trip_in_progress".tr;
    }
  }

  // Get completion status color
  Color get completionStatusColor {
    if (trip.isCompleted) {
      return AppColors.success;
    } else if (canCompleteTrip) {
      return AppColors.warning;
    } else {
      return AppColors.info;
    }
  }
}