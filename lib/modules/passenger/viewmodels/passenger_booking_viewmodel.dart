import 'dart:async';
import 'package:get/get.dart';
import '../../../app/utils/app_snackbar.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/passenger_repository.dart';
import '../../../data/services/firebase_service.dart';

class PassengerBookingViewModel extends GetxController {
  final bookings = <BookingModel>[].obs;
  final combinedBookings = <BookingGroup>[].obs;
  final selectedFilter = 'All'.obs;
  final isLoading = false.obs;
  final bookingStats = <String, int>{}.obs;

  final filters = ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled'];

  StreamSubscription? _bookingSub;

  // Statistics
  int get totalBookings => bookingStats['total'] ?? 0;
  int get pendingCount => bookingStats['pending'] ?? 0;
  int get confirmedCount => bookingStats['completed'] ?? 0;
  int get completedCount =>
      bookings.where((b) => b.status == BookingStatus.completed).length;
  int get cancelledCount => bookingStats['cancelled'] ?? 0;

  @override
  void onInit() {
    super.onInit();
    _fetchPassengerData();
  }

  @override
  void onClose() {
    _bookingSub?.cancel();
    super.onClose();
  }

  Future<void> _fetchPassengerData() async {
    isLoading.value = true;
    try {
      final passengerId = FirebaseService.currentUserId;
      if (passengerId == null) return;

      await _fetchBookingStats(passengerId);
      await fetchPassengerBookings();
    } catch (e) {
      AppSnackbar.error('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchBookingStats(String passengerId) async {
    try {
      final stats = await PassengerRepository.getPassengerBookingStats(passengerId);
      bookingStats.value = stats;
    } catch (e) {
      print('Error fetching booking stats: $e');
    }
  }

  Future<void> fetchPassengerBookings() async {
    try {
      final passengerId = FirebaseService.currentUserId;
      if (passengerId == null) return;

      final passengerBookings =
          await PassengerRepository.getPassengerBookings(passengerId);

      bookings.assignAll(passengerBookings);
      _combineBookings();
      applyFilter(selectedFilter.value);
    } catch (e) {
      AppSnackbar.error('error'.tr, e.toString());
    }
  }

  Future<void> deleteBookingGroup(BookingGroup group) async {
    try {
      isLoading.value = true;
      for (final booking in group.bookings) {
        await FirebaseService.firestore
            .collection('bookings')
            .doc(booking.id)
            .delete();
      }
      await refreshData();
      Get.snackbar(
        'success'.tr,
        'Réservation supprimée',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      AppSnackbar.error('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _combineBookings() {
    final Map<String, List<BookingModel>> grouped = {};

    for (final booking in bookings) {
      final groupKey = '${booking.tripId}_${booking.status.name}';

      if (!grouped.containsKey(groupKey)) {
        grouped[groupKey] = [];
      }
      grouped[groupKey]!.add(booking);
    }

    combinedBookings.assignAll(
      grouped.entries
          .map((entry) => BookingGroup(
                tripId: entry.value.first.tripId,
                bookings: entry.value,
                status: entry.value.first.status,
              ))
          .toList(),
    );
  }

  void applyFilter(String filter) {
    selectedFilter.value = filter;

    if (filter == 'All') {
      _combineBookings();
    } else {
      final filteredBookings = _getFilteredBookings(filter);
      final Map<String, List<BookingModel>> grouped = {};

      for (final booking in filteredBookings) {
        if (!grouped.containsKey(booking.tripId)) {
          grouped[booking.tripId] = [];
        }
        grouped[booking.tripId]!.add(booking);
      }

      combinedBookings.assignAll(
        grouped.entries
            .map((entry) => BookingGroup(
                  tripId: entry.key,
                  bookings: entry.value,
                  status: entry.value.first.status,
                ))
            .toList(),
      );
    }
  }

  List<BookingModel> _getFilteredBookings(String filter) {
    switch (filter) {
      case 'Pending':
        return bookings
            .where((b) =>
                b.status == BookingStatus.reserved &&
                b.paymentStatus == PaymentStatus.pending)
            .toList();

      case 'Confirmed':
        return bookings
            .where((b) =>
                b.status == BookingStatus.confirmed &&
                b.paymentStatus == PaymentStatus.completed)
            .toList();

      case 'Completed':
        return bookings
            .where((b) => b.status == BookingStatus.completed)
            .toList();

      case 'Cancelled':
        return bookings
            .where((b) =>
                b.status == BookingStatus.cancelled ||
                b.paymentStatus == PaymentStatus.failed)
            .toList();

      default:
        return bookings.toList();
    }
  }

  Future<void> refreshData() async {
    final passengerId = FirebaseService.currentUserId;
    if (passengerId == null) return;

    await _fetchBookingStats(passengerId);
    await fetchPassengerBookings();
  }
}