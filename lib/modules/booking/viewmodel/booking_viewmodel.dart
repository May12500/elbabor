import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../app/config/stripe_config.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/utils/app_snackbar.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/services/currency_service.dart';
import '../../../data/services/firebase_service.dart';
import '../../../data/services/payment_service.dart';
import '../../../data/models/trip_model.dart';

class BookingViewModel extends GetxController {
  final TripModel trip;
  BookingViewModel(this.trip);
  static const double serviceFeeRate = 0.15;
  final isLoading = false.obs;
  final isProcessingPayment = false.obs;
  final reservedSeats = <int>[].obs;
  final confirmedSeats = <int>[].obs;
  final selectedSeats = <int>[].obs;
  final selectedPayment = "cash".obs;
  List<String> get availablePaymentMethods => ['cash', 'stripe_card'];
  final temporarilyReservedSeats = <String, List<int>>{}.obs;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    selectedPayment.value = "cash";
    _loadPassengerInfo();
    _setupSeatListener();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void _setupSeatListener() {
    ever(reservedSeats, (_) => update());
    ever(confirmedSeats, (_) => update());
  }

  Stream<Map<String, List<int>>> getSeatStream() {
    return FirebaseFirestore.instance.collection('trips').doc(trip.id).collection('bookings').snapshots().map((snapshot) {
      final confirmedSeatsList = <int>[];
      final reservedSeatsList = <int>[];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final seatNumbers = List<int>.from(data['seatNumbers'] ?? []);
        final bookingStatus = data['status'] ?? 'reserved';
        final paymentStatus = data['paymentStatus'] ?? 'pending';
        if (bookingStatus == 'confirmed' && paymentStatus == 'completed') {
          confirmedSeatsList.addAll(seatNumbers);
        } else if (bookingStatus == 'reserved' && (paymentStatus == 'pending' || paymentStatus == 'processing')) {
          reservedSeatsList.addAll(seatNumbers);
        }
      }
      confirmedSeats.value = confirmedSeatsList;
      reservedSeats.value = reservedSeatsList;
      return {'confirmed': confirmedSeatsList, 'reserved': reservedSeatsList};
    });
  }

  Future<void> _loadPassengerInfo() async {
    final passengerId = FirebaseService.currentUserId;
    if (passengerId == null) return;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(passengerId).get();
    if (userDoc.exists) {
      final data = userDoc.data()!;
      nameController.text = data['name'] ?? '';
      emailController.text = data['email'] ?? '';
      phoneController.text = data['phone'] ?? '';
    }
  }

  void toggleSeat(int seatNumber) {
    if (confirmedSeats.contains(seatNumber) || reservedSeats.contains(seatNumber)) return;
    if (selectedSeats.contains(seatNumber)) {
      selectedSeats.remove(seatNumber);
    } else {
      selectedSeats.add(seatNumber);
    }
  }

  void selectPayment(String method) => selectedPayment.value = method;

  Future<void> confirmBooking() async {
    if (selectedSeats.isEmpty) { AppSnackbar.error("select_seat".tr, "select_seat_msg".tr); return; }
    if (nameController.text.isEmpty || phoneController.text.isEmpty) { AppSnackbar.error("missing_info".tr, "fill_required_fields".tr); return; }
    final validationError = validateSeatSelection();
    if (validationError != null) { AppSnackbar.error("seat_unavailable".tr, validationError); return; }
    await _reserveSeatsAndProcessPayment();
  }

  Future<void> _reserveSeatsAndProcessPayment() async {
    isProcessingPayment.value = true;
    try {
      final bookingId = const Uuid().v4();
      final booking = _createBookingModel(bookingId: bookingId);
      await BookingRepository.createBooking(booking);
      AppSnackbar.info("seats_reserved".tr, "proceeding_to_payment".tr);
      await _processPayment(bookingId);
    } catch (e) {
      AppSnackbar.error("reservation_failed".tr, e.toString());
      isProcessingPayment.value = false;
    }
  }

  Future<void> _processPayment(String bookingId) async {
    try {
      final totalPrice = this.totalPrice;
      PaymentResult paymentResult;
      if (true) {
        paymentResult = await _processMockPayment(bookingId, totalPrice);
      } else {
        switch (selectedPayment.value) {
          case 'stripe_card':
            paymentResult = await PaymentService().processCardPayment(bookingId: bookingId, amount: CurrencyService.instance.convertFromUSD(totalPrice), currency: CurrencyService.instance.selectedCurrency.value);
            break;
          case 'google_pay':
            paymentResult = await PaymentService().processGooglePay(bookingId: bookingId, amount: totalPrice, currency: CurrencyService.instance.selectedCurrency.value);
            break;
          case 'cash':
          case 'cash_on_board':
            paymentResult = PaymentResult(success: true, bookingId: bookingId, paymentIntentId: 'cash_$bookingId');
            break;
          default:
            paymentResult = PaymentResult(success: false, errorMessage: 'Unsupported payment method', bookingId: bookingId);
        }
      }
      if (paymentResult.success) { await _handleSuccessfulPayment(bookingId, totalPrice, paymentResult); } else { await _handleFailedPayment(bookingId, paymentResult); }
    } catch (e) { await _handlePaymentError(bookingId, e.toString()); }
  }

  Future<void> _handleSuccessfulPayment(String bookingId, double totalPrice, PaymentResult paymentResult) async {
    try {
      await BookingRepository.updateBookingStatus(bookingId, BookingStatus.confirmed, paymentStatus: PaymentStatus.completed, stripePaymentIntentId: paymentResult.paymentIntentId, amountPaid: totalPrice);
      AppSnackbar.success("payment_success".tr, "booking_confirmed".tr);
      Get.offAllNamed(Routes.PASSENGER_HOME, arguments: {'bookingId': bookingId, 'seats': selectedSeats.toList(), 'totalPrice': totalPrice});
    } catch (e) { AppSnackbar.error("confirmation_failed".tr, e.toString()); } finally { isProcessingPayment.value = false; }
  }

  Future<void> _handleFailedPayment(String bookingId, PaymentResult paymentResult) async {
    try {
      await BookingRepository.updateBookingStatus(bookingId, BookingStatus.cancelled, paymentStatus: PaymentStatus.failed, failureMessage: paymentResult.errorMessage);
      AppSnackbar.error("payment_failed".tr, paymentResult.errorMessage ?? 'Unknown error');
      _showPaymentRetryDialog(bookingId);
    } catch (e) { AppSnackbar.error("update_failed".tr, e.toString()); isProcessingPayment.value = false; }
  }

  Future<void> _handlePaymentError(String bookingId, String error) async {
    try { await BookingRepository.updateBookingStatus(bookingId, BookingStatus.cancelled, paymentStatus: PaymentStatus.failed, failureMessage: error); } catch (e) { debugPrint('Cleanup failed: $e'); }
    AppSnackbar.error("payment_error".tr, error);
    isProcessingPayment.value = false;
  }

  void _showPaymentRetryDialog(String bookingId) {
    Get.dialog(AlertDialog(title: Text("payment_failed".tr), content: Text("would_you_like_to_retry_payment".tr), actions: [TextButton(onPressed: () { Get.back(); isProcessingPayment.value = false; }, child: Text("cancel".tr)), TextButton(onPressed: () { Get.back(); _retryPayment(bookingId); }, child: Text("retry".tr))]), barrierDismissible: false);
  }

  Future<void> _retryPayment(String bookingId) async {
    isProcessingPayment.value = true;
    try {
      final totalPrice = this.totalPrice;
      PaymentResult paymentResult;
      switch (selectedPayment.value) {
        case 'stripe_card':
          paymentResult = await PaymentService().processCardPayment(bookingId: bookingId, amount: CurrencyService.instance.convertFromUSD(totalPrice), currency: CurrencyService.instance.selectedCurrency.value);
          break;
        default:
          paymentResult = PaymentResult(success: false, errorMessage: 'Unsupported payment method', bookingId: bookingId);
      }
      if (paymentResult.success) {
        await BookingRepository.updateBookingStatus(bookingId, BookingStatus.confirmed, paymentStatus: PaymentStatus.completed, stripePaymentIntentId: paymentResult.paymentIntentId, amountPaid: totalPrice);
        AppSnackbar.success("payment_success".tr, "booking_confirmed".tr);
        Get.offAllNamed(Routes.PASSENGER_HOME);
      } else { AppSnackbar.error("payment_failed".tr, paymentResult.errorMessage ?? 'Unknown error'); }
    } catch (e) { AppSnackbar.error("error".tr, e.toString()); } finally { isProcessingPayment.value = false; }
  }

  BookingModel _createBookingModel({String? bookingId}) {
    final id = bookingId ?? const Uuid().v4();
    final totalPrice = this.totalPrice;
    final vehicleTypes = trip.vehicleTypesUsed;
    final vehicles = trip.segments.map((segment) => segment.vehicle).toList();
    return BookingModel(id: id, tripId: trip.id, passengerId: FirebaseService.currentUserId ?? '', driverId: trip.driverId, createdAt: DateTime.now(), status: BookingStatus.reserved, seatsBooked: selectedSeats.length, seatNumbers: selectedSeats.toList(), price: totalPrice, paid: false, paymentMethod: _parsePaymentMethod('card'), paymentStatus: PaymentStatus.pending, amountPaid: 0.0, stripePaymentIntentId: null, stripeCustomerId: null, refundAmount: 0.0, refundedAt: null, refundReason: null, failureMessage: null, fromCity: trip.fromCity, destinationCity: trip.destinationCity, vehicleTypes: vehicleTypes, tripDateTime: trip.dateTime, departurePoint: trip.departurePoint, arrivalPoint: trip.arrivalPoint, vehicles: vehicles, segments: trip.segments, reservationExpiresAt: DateTime.now().add(const Duration(minutes: 15)));
  }

  PaymentMethod _parsePaymentMethod(String method) => getPaymentMethodFromString(method);
  PaymentMethod getPaymentMethodFromString(String method) {
    switch (method) {
      case 'stripe_card': return PaymentMethod.stripeCard;
      case 'google_pay': return PaymentMethod.googlePay;
      case 'jazz_cash': return PaymentMethod.jazzCash;
      case 'easy_paisa': return PaymentMethod.easyPaisa;
      case 'cash': return PaymentMethod.cash;
      case 'wallet': return PaymentMethod.wallet;
      default: return PaymentMethod.stripeCard;
    }
  }

  String getPaymentMethodDisplayName(String method) {
    switch (method) {
      case 'stripe_card': return 'credit_card'.tr;
      case 'google_pay': return 'google_pay'.tr;
      case 'jazz_cash': return 'jazz_cash'.tr;
      case 'easy_paisa': return 'easy_paisa'.tr;
      case 'cash': return 'cash'.tr;
      case 'wallet': return 'wallet'.tr;
      default: return method;
    }
  }

  double get basePrice => trip.totalPrice * selectedSeats.length;
  double get serviceFee => basePrice * serviceFeeRate;
  double get totalPrice => basePrice + serviceFee;
  bool get requiresPayment => selectedPayment.value != 'cash';

  Future<PaymentResult> _processMockPayment(String bookingId, double amount) async {
    await Future.delayed(const Duration(seconds: 2));
    final isSuccess = Random().nextDouble() > 0.2;
    if (isSuccess) {
      return PaymentResult(success: true, paymentIntentId: 'mock_pi_${DateTime.now().millisecondsSinceEpoch}', bookingId: bookingId);
    } else {
      return PaymentResult(success: false, errorMessage: 'Mock payment failure - card declined', bookingId: bookingId);
    }
  }

  bool get isBookingValid => selectedSeats.isNotEmpty && nameController.text.isNotEmpty && phoneController.text.isNotEmpty && selectedPayment.value.isNotEmpty;

  Map<String, dynamic> get bookingSummary => {'seats': selectedSeats.length, 'basePrice': basePrice, 'serviceFee': serviceFee, 'serviceFeeRate': serviceFeeRate, 'totalPrice': totalPrice, 'passengerName': nameController.text, 'paymentMethod': getPaymentMethodDisplayName(selectedPayment.value), 'tripSummary': trip.tripSummary};

  String? validateSeatSelection() {
    if (selectedSeats.isEmpty) return "select_seat_msg".tr;
    final totalOccupiedSeats = confirmedSeats.length + reservedSeats.length;
    final availableSeats = (trip.seatsAvailable ?? 0) - totalOccupiedSeats;
    if (selectedSeats.length > availableSeats) return "not_enough_seats_available".tr;
    final conflictingConfirmedSeats = selectedSeats.where((seat) => confirmedSeats.contains(seat)).toList();
    final conflictingReservedSeats = selectedSeats.where((seat) => reservedSeats.contains(seat)).toList();
    final allConflictingSeats = [...conflictingConfirmedSeats, ...conflictingReservedSeats];
    if (allConflictingSeats.isNotEmpty) return "seats_already_taken".tr + " ${allConflictingSeats.join(', ')}";
    return null;
  }

  void clearSelection() { selectedSeats.clear(); }
  int get availableSeatsCount { final totalOccupiedSeats = confirmedSeats.length + reservedSeats.length; return (trip.seatsAvailable ?? 0) - totalOccupiedSeats; }
  bool isSeatAvailable(int seatNumber) => !confirmedSeats.contains(seatNumber) && !reservedSeats.contains(seatNumber);
  SeatStatus getSeatStatus(int seatNumber) {
    if (confirmedSeats.contains(seatNumber)) return SeatStatus.unavailable;
    else if (reservedSeats.contains(seatNumber)) return SeatStatus.reserved;
    else if (selectedSeats.contains(seatNumber)) return SeatStatus.selected;
    else return SeatStatus.available;
  }
  Future<void> cleanupExpiredReservations() async { await BookingRepository.cleanupExpiredReservations(trip.id); }
}

enum SeatStatus { available, reserved, selected, unavailable }

extension SeatStatusExtension on SeatStatus {
  String get displayName {
    switch (this) {
      case SeatStatus.available: return "available".tr;
      case SeatStatus.reserved: return "reserved".tr;
      case SeatStatus.selected: return "selected".tr;
      case SeatStatus.unavailable: return "unavailable".tr;
    }
  }
  Color get color {
    switch (this) {
      case SeatStatus.available: return AppColors.success.withValues(alpha: 0.1);
      case SeatStatus.reserved: return AppColors.warning.withValues(alpha: 0.1);
      case SeatStatus.selected: return AppColors.primary;
      case SeatStatus.unavailable: return AppColors.grey.withValues(alpha: 0.3);
    }
  }
  Color get borderColor {
    switch (this) {
      case SeatStatus.available: return AppColors.success;
      case SeatStatus.reserved: return AppColors.warning;
      case SeatStatus.selected: return AppColors.primary;
      case SeatStatus.unavailable: return AppColors.grey;
    }
  }
  Color get textColor {
    switch (this) {
      case SeatStatus.available: return AppColors.success;
      case SeatStatus.reserved: return AppColors.warning;
      case SeatStatus.selected:
      case SeatStatus.unavailable: return AppColors.textWhite;
    }
  }
  Widget get statusIcon {
    switch (this) {
      case SeatStatus.available: return Icon(Icons.event_seat, color: AppColors.success, size: 16);
      case SeatStatus.reserved: return Icon(Icons.access_time, color: AppColors.warning, size: 16);
      case SeatStatus.selected: return Icon(Icons.check, color: AppColors.textWhite, size: 16);
      case SeatStatus.unavailable: return Icon(Icons.block, color: AppColors.grey, size: 16);
    }
  }
}
