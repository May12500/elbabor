import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbabor/data/models/trip_segment_model.dart';
import 'package:elbabor/data/models/vehicle_info_model.dart';
import 'package:get/get.dart';
import 'trip_model.dart';

// Enhanced Booking Status with payment states
enum BookingStatus {
  pending,
  confirmed,
  reserved,
  cancelled,
  completed,
  paymentPending,
  paymentFailed,
  refundPending,
  refunded,
  partiallyRefunded,
}

// Enhanced Payment Method enum
enum PaymentMethod {
  stripeCard,
  googlePay,
  jazzCash,
  easyPaisa,
  cash,
  wallet,
}

// Payment Status enum
enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  partiallyRefunded,
  requiresAction, // For 3D Secure
}

// Refund Reason enum
enum RefundReason {
  passengerCancellation,
  driverCancellation,
  tripCancelled,
  paymentError,
  customerRequest,
  duplicatePayment,
}

class BookingModel {
  final String id;
  final String tripId;
  final String passengerId;
  final String driverId;
  final DateTime createdAt;
  final BookingStatus status;
  final int seatsBooked;
  final List<int> seatNumbers;
  final double price;
  final PaymentMethod paymentMethod;
  final bool paid;

  // Enhanced Payment Fields
  final PaymentStatus paymentStatus;
  final double amountPaid;
  final String? stripePaymentIntentId;
  final String? stripeCustomerId;
  final double refundAmount;
  final DateTime? refundedAt;
  final RefundReason? refundReason;
  final String? failureMessage;

  // Reservation expiry for temporary reservations
  final DateTime? reservationExpiresAt;

  // Trip details (embedded for easy access) - UPDATED FOR MULTI-SEGMENT
  final String fromCity;
  final String destinationCity;
  final List<String> vehicleTypes; // Multiple vehicle types for segments
  final DateTime tripDateTime;
  final String departurePoint; // First segment departure
  final String arrivalPoint; // Last segment arrival
  final List<VehicleInfo?> vehicles; // Vehicles for each segment (nullable for non-vehicle segments)
  final List<TripSegment> segments; // Complete segment information

  BookingModel({
    required this.id,
    required this.tripId,
    required this.passengerId,
    required this.driverId,
    required this.createdAt,
    required this.status,
    required this.seatsBooked,
    required this.seatNumbers,
    required this.price,
    required this.paymentMethod,
    required this.paid,

    // Enhanced Payment Fields
    required this.paymentStatus,
    required this.amountPaid,
    this.stripePaymentIntentId,
    this.stripeCustomerId,
    this.refundAmount = 0.0,
    this.refundedAt,
    this.refundReason,
    this.failureMessage,

    // Reservation expiry
    this.reservationExpiresAt,

    // Trip details - UPDATED FOR MULTI-SEGMENT
    required this.fromCity,
    required this.destinationCity,
    required this.vehicleTypes,
    required this.tripDateTime,
    required this.departurePoint,
    required this.arrivalPoint,
    required this.vehicles,
    required this.segments,
  });

  // Helper getter for backward compatibility (gets first vehicle)
  VehicleInfo get vehicle => vehicles.isNotEmpty ? vehicles.first ?? VehicleInfo.empty() : VehicleInfo.empty();

  // Helper getter for primary vehicle type
  String get vehicleType => vehicleTypes.isNotEmpty ? vehicleTypes.first : '';

  // Multi-segment helpers
  bool get hasMultipleSegments => segments.length > 1;

  // Reservation helpers
  bool get isReservationActive =>
      status == BookingStatus.reserved &&
          reservationExpiresAt != null &&
          reservationExpiresAt!.isAfter(DateTime.now());

  bool get isReservationExpired =>
      status == BookingStatus.reserved &&
          reservationExpiresAt != null &&
          reservationExpiresAt!.isBefore(DateTime.now());

  // FIXED: Use available fields instead of 'trip' variable
  String get tripSummary {
    if (hasMultipleSegments) {
      return '${segments.length} segments: ${segments.first.fromPoint} → ${segments.last.toPoint}';
    } else {
      return '$vehicleType: $departurePoint → $arrivalPoint';
    }
  }

  // Get display name for the trip (e.g., "Multi-segment Trip" or "Car Ride")
  String get displayName {
    if (hasMultipleSegments) {
      return 'Multi-segment Trip';
    } else {
      return vehicleType.isNotEmpty ? '$vehicleType Ride' : 'Trip';
    }
  }

  // Get all vehicle types as a formatted string
  String get vehicleTypesDisplay {
    if (vehicleTypes.isEmpty) return '';
    if (vehicleTypes.length == 1) return vehicleTypes.first;
    return '${vehicleTypes.take(vehicleTypes.length - 1).join(', ')} & ${vehicleTypes.last}';
  }

  factory BookingModel.fromMap(Map<String, dynamic> data, String id) {
    // Parse segments if available
    List<TripSegment> segments = [];
    List<String> vehicleTypes = [];
    List<VehicleInfo?> vehicles = [];

    if (data['segments'] != null) {
      segments = (data['segments'] as List)
          .map((segmentJson) => TripSegment.fromJson(segmentJson))
          .toList();

      // Extract vehicle types and vehicles from segments
      vehicleTypes = segments.map((segment) => segment.vehicleType).toList();
      vehicles = segments.map((segment) => segment.vehicle).toList();
    } else {
      // Backward compatibility: convert single trip to single segment
      final tripData = data['tripDetails'] ?? {};
      segments = [
        TripSegment(
          id: 'legacy_${id}',
          vehicleType: tripData['vehicleType']?.toString() ?? data['vehicleType']?.toString() ?? '',
          fromPoint: tripData['departurePoint']?.toString() ?? data['departurePoint']?.toString() ?? '',
          toPoint: tripData['arrivalPoint']?.toString() ?? data['arrivalPoint']?.toString() ?? '',
          fromCity: tripData['fromCity']?.toString() ?? data['fromCity']?.toString() ?? '',
          toCity: tripData['destinationCity']?.toString() ?? data['destinationCity']?.toString() ?? '',
          price: ((data['price'] ?? 0) as num).toDouble(),
          vehicle: tripData['vehicle'] != null
              ? VehicleInfo.fromJson(Map<String, dynamic>.from(tripData['vehicle']))
              : VehicleInfo.empty(),
        )
      ];
      vehicleTypes = [segments.first.vehicleType];
      vehicles = [segments.first.vehicle];
    }

    return BookingModel(
      id: id,
      tripId: data['tripId']?.toString() ?? '',
      passengerId: data['passengerId']?.toString() ?? '',
      driverId: data['driverId']?.toString() ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      status: _parseBookingStatus(data['status']?.toString() ?? ''),
      seatsBooked: (data['seatsBooked'] ?? 1) as int,
      seatNumbers: data['seatNumbers'] != null
          ? List<int>.from(data['seatNumbers'])
          : [],
      price: ((data['price'] ?? 0) as num).toDouble(),
      paymentMethod: parsePaymentMethod(data['paymentMethod']?.toString() ?? ''),
      paid: (data['paid'] is bool)
          ? data['paid'] as bool
          : (data['paid']?.toString().toLowerCase() == 'true' || data['paid'] == 1),

      // Enhanced Payment Fields
      paymentStatus: parsePaymentStatus(data['paymentStatus']?.toString() ?? ''),
      amountPaid: ((data['amountPaid'] ?? data['price'] ?? 0) as num).toDouble(),
      stripePaymentIntentId: data['stripePaymentIntentId']?.toString(),
      stripeCustomerId: data['stripeCustomerId']?.toString(),
      refundAmount: ((data['refundAmount'] ?? 0) as num).toDouble(),
      refundedAt: data['refundedAt'] != null
          ? (data['refundedAt'] as Timestamp).toDate()
          : null,
      refundReason: _parseRefundReason(data['refundReason']?.toString()),
      failureMessage: data['failureMessage']?.toString(),

      // Reservation expiry
      reservationExpiresAt: data['reservationExpiresAt'] != null
          ? (data['reservationExpiresAt'] as Timestamp).toDate()
          : null,

      // Trip details - UPDATED FOR MULTI-SEGMENT
      fromCity: data['fromCity']?.toString() ?? segments.first.fromCity,
      destinationCity: data['destinationCity']?.toString() ?? segments.last.toCity,
      vehicleTypes: vehicleTypes,
      tripDateTime: data['tripDateTime'] != null
          ? (data['tripDateTime'] as Timestamp).toDate()
          : DateTime.now(),
      departurePoint: data['departurePoint']?.toString() ?? segments.first.fromPoint,
      arrivalPoint: data['arrivalPoint']?.toString() ?? segments.last.toPoint,
      vehicles: vehicles,
      segments: segments,
    );
  }

  factory BookingModel.fromJson(Map<String, dynamic> data) {
    return BookingModel.fromMap(data, data['id'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'passengerId': passengerId,
      'driverId': driverId,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
      'seatsBooked': seatsBooked,
      'seatNumbers': seatNumbers,
      'price': price,
      'paymentMethod': paymentMethod.name,
      'paid': paid,

      // Enhanced Payment Fields
      'paymentStatus': paymentStatus.name,
      'amountPaid': amountPaid,
      'stripePaymentIntentId': stripePaymentIntentId,
      'stripeCustomerId': stripeCustomerId,
      'refundAmount': refundAmount,
      'refundedAt': refundedAt != null ? Timestamp.fromDate(refundedAt!) : null,
      'refundReason': refundReason?.name,
      'failureMessage': failureMessage,

      // Reservation expiry
      'reservationExpiresAt': reservationExpiresAt != null
          ? Timestamp.fromDate(reservationExpiresAt!)
          : null,

      // Include trip details for easy querying
      'fromCity': fromCity,
      'destinationCity': destinationCity,
      'vehicleType': vehicleType, // For backward compatibility
      'tripDateTime': Timestamp.fromDate(tripDateTime),
      'departurePoint': departurePoint,
      'arrivalPoint': arrivalPoint,

      // Store complete segments and trip details
      'segments': segments.map((segment) => segment.toJson()).toList(),
      'vehicleTypes': vehicleTypes,

      // Store complete trip details as embedded object for backward compatibility
      'tripDetails': {
        'fromCity': fromCity,
        'destinationCity': destinationCity,
        'vehicleType': vehicleType,
        'dateTime': Timestamp.fromDate(tripDateTime),
        'departurePoint': departurePoint,
        'arrivalPoint': arrivalPoint,
        'vehicle': vehicle.toJson(), // First vehicle for backward compatibility
        'segments': segments.map((segment) => segment.toJson()).toList(),
      },
    };
  }

  // Helper method to create booking with trip details - UPDATED
  static BookingModel fromTripAndBooking({
    required TripModel trip,
    required BookingModel booking,
  }) {
    return BookingModel(
      id: booking.id,
      tripId: booking.tripId,
      passengerId: booking.passengerId,
      driverId: booking.driverId,
      createdAt: booking.createdAt,
      status: booking.status,
      seatsBooked: booking.seatsBooked,
      seatNumbers: booking.seatNumbers,
      price: booking.price,
      paymentMethod: booking.paymentMethod,
      paid: booking.paid,

      // Enhanced Payment Fields
      paymentStatus: booking.paymentStatus,
      amountPaid: booking.amountPaid,
      stripePaymentIntentId: booking.stripePaymentIntentId,
      stripeCustomerId: booking.stripeCustomerId,
      refundAmount: booking.refundAmount,
      refundedAt: booking.refundedAt,
      refundReason: booking.refundReason,
      failureMessage: booking.failureMessage,

      // Reservation expiry
      reservationExpiresAt: booking.reservationExpiresAt,

      // Trip details from multi-segment trip
      fromCity: trip.fromCity,
      destinationCity: trip.destinationCity,
      vehicleTypes: trip.vehicleTypesUsed,
      tripDateTime: trip.dateTime,
      departurePoint: trip.departurePoint,
      arrivalPoint: trip.arrivalPoint,
      vehicles: trip.segments.map((segment) => segment.vehicle).toList(),
      segments: trip.segments,
    );
  }

  // Helper methods for payment status
  bool get isPaymentCompleted => paymentStatus == PaymentStatus.completed;
  bool get isPaymentPending => paymentStatus == PaymentStatus.pending;
  bool get isPaymentFailed => paymentStatus == PaymentStatus.failed;
  bool get requiresPaymentAction => paymentStatus == PaymentStatus.requiresAction;

  bool get isRefunded => paymentStatus == PaymentStatus.refunded;
  bool get isPartiallyRefunded => paymentStatus == PaymentStatus.partiallyRefunded;
  bool get canBeRefunded => isPaymentCompleted && !isRefunded && !isPartiallyRefunded;

  // Copy with method for updates
  BookingModel copyWith({
    String? id,
    String? tripId,
    String? passengerId,
    String? driverId,
    DateTime? createdAt,
    BookingStatus? status,
    int? seatsBooked,
    List<int>? seatNumbers,
    double? price,
    PaymentMethod? paymentMethod,
    bool? paid,
    PaymentStatus? paymentStatus,
    double? amountPaid,
    String? stripePaymentIntentId,
    String? stripeCustomerId,
    double? refundAmount,
    DateTime? refundedAt,
    RefundReason? refundReason,
    String? failureMessage,
    DateTime? reservationExpiresAt,
    String? fromCity,
    String? destinationCity,
    List<String>? vehicleTypes,
    DateTime? tripDateTime,
    String? departurePoint,
    String? arrivalPoint,
    List<VehicleInfo?>? vehicles,
    List<TripSegment>? segments,
  }) {
    return BookingModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      passengerId: passengerId ?? this.passengerId,
      driverId: driverId ?? this.driverId,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      seatsBooked: seatsBooked ?? this.seatsBooked,
      seatNumbers: seatNumbers ?? this.seatNumbers,
      price: price ?? this.price,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paid: paid ?? this.paid,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      amountPaid: amountPaid ?? this.amountPaid,
      stripePaymentIntentId: stripePaymentIntentId ?? this.stripePaymentIntentId,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      refundAmount: refundAmount ?? this.refundAmount,
      refundedAt: refundedAt ?? this.refundedAt,
      refundReason: refundReason ?? this.refundReason,
      failureMessage: failureMessage ?? this.failureMessage,
      reservationExpiresAt: reservationExpiresAt ?? this.reservationExpiresAt,
      fromCity: fromCity ?? this.fromCity,
      destinationCity: destinationCity ?? this.destinationCity,
      vehicleTypes: vehicleTypes ?? this.vehicleTypes,
      tripDateTime: tripDateTime ?? this.tripDateTime,
      departurePoint: departurePoint ?? this.departurePoint,
      arrivalPoint: arrivalPoint ?? this.arrivalPoint,
      vehicles: vehicles ?? this.vehicles,
      segments: segments ?? this.segments,
    );
  }

  // Parsing helpers (keep the same)
  static BookingStatus _parseBookingStatus(String status) {
    if (status.isEmpty) return BookingStatus.pending;

    switch (status) {
      case 'pending': return BookingStatus.pending;
      case 'confirmed': return BookingStatus.confirmed;
      case 'reserved': return BookingStatus.reserved;
      case 'cancelled': return BookingStatus.cancelled;
      case 'completed': return BookingStatus.completed;
      case 'payment_pending': return BookingStatus.paymentPending;
      case 'payment_failed': return BookingStatus.paymentFailed;
      case 'refund_pending': return BookingStatus.refundPending;
      case 'refunded': return BookingStatus.refunded;
      case 'partially_refunded': return BookingStatus.partiallyRefunded;
      default: return BookingStatus.pending;
    }
  }

  static PaymentMethod parsePaymentMethod(String method) {
    if (method.isEmpty) return PaymentMethod.stripeCard;
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

  static PaymentStatus parsePaymentStatus(String status) {
    if (status.isEmpty) return PaymentStatus.pending;

    switch (status) {
      case 'pending': return PaymentStatus.pending;
      case 'processing': return PaymentStatus.processing;
      case 'completed': return PaymentStatus.completed;
      case 'failed': return PaymentStatus.failed;
      case 'refunded': return PaymentStatus.refunded;
      case 'partially_refunded': return PaymentStatus.partiallyRefunded;
      case 'requires_action': return PaymentStatus.requiresAction;
      default: return PaymentStatus.pending;
    }
  }

  static RefundReason? _parseRefundReason(String? reason) {
    if (reason == null || reason.isEmpty) return null;
    switch (reason) {
      case 'passenger_cancellation': return RefundReason.passengerCancellation;
      case 'driver_cancellation': return RefundReason.driverCancellation;
      case 'trip_cancelled': return RefundReason.tripCancelled;
      case 'payment_error': return RefundReason.paymentError;
      case 'customer_request': return RefundReason.customerRequest;
      case 'duplicate_payment': return RefundReason.duplicatePayment;
      default: return null;
    }
  }
}

class BookingGroup {
  final String tripId;
  final List<BookingModel> bookings;
  final BookingStatus status;

  BookingGroup({
    required this.tripId,
    required this.bookings,
    required this.status,
  });

  int get totalSeats => bookings.fold(0, (sum, booking) => sum + booking.seatsBooked);
  double get totalRefundAmount => bookings.fold(0.0, (sum, booking) => sum + booking.refundAmount);

  // Payment statistics
  int get completedPayments => bookings.where((b) => b.isPaymentCompleted).length;
  int get pendingPayments => bookings.where((b) => b.isPaymentPending).length;
  int get failedPayments => bookings.where((b) => b.isPaymentFailed).length;

  // These now come directly from the booking model
  String get fromCity => bookings.first.fromCity;
  String get destinationCity => bookings.first.destinationCity;
  String get vehicleType => bookings.first.vehicleType; // First vehicle type for display
  DateTime get tripDateTime => bookings.first.tripDateTime;
  String get departurePoint => bookings.first.departurePoint;
  String get arrivalPoint => bookings.first.arrivalPoint;
  VehicleInfo get vehicle => bookings.first.vehicle; // First vehicle for display

  // Multi-segment information
  bool get hasMultipleSegments => bookings.first.hasMultipleSegments;
  List<String> get vehicleTypes => bookings.first.vehicleTypes;
  List<TripSegment> get segments => bookings.first.segments;

  // FIXED: Use available fields for trip summary
  String get tripSummary => bookings.first.tripSummary;

  // Helper to check if all bookings in group have same status
  bool get hasMixedStatus {
    if (bookings.length <= 1) return false;
    final firstStatus = bookings.first.status;
    return bookings.any((booking) => booking.status != firstStatus);
  }
  // NEW: Payment-related getters for multiple payment methods
  double get totalPrice => bookings.fold(0.0, (sum, booking) => sum + booking.price);
  double get totalAmountPaid => bookings.fold(0.0, (sum, booking) => sum + booking.amountPaid);

  // Get unique payment methods used
  Set<PaymentMethod> get paymentMethodsUsed {
    return bookings.map((b) => b.paymentMethod).toSet();
  }

  // Check if all bookings have same payment method
  bool get hasSinglePaymentMethod => paymentMethodsUsed.length == 1;

  // Get the most common payment method (for display when multiple methods used)
  PaymentMethod get primaryPaymentMethod {
    if (hasSinglePaymentMethod) return paymentMethodsUsed.first;

    // Count frequency of each payment method
    final methodCounts = <PaymentMethod, int>{};
    for (final booking in bookings) {
      methodCounts[booking.paymentMethod] = (methodCounts[booking.paymentMethod] ?? 0) + 1;
    }
    // Return the most frequent payment method
    return methodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  // Get payment breakdown by method
  Map<PaymentMethod, double> get paymentBreakdown {
    final breakdown = <PaymentMethod, double>{};
    for (final booking in bookings) {
      breakdown[booking.paymentMethod] = (breakdown[booking.paymentMethod] ?? 0) + booking.price;
    }
    return breakdown;
  }

  // Check if all bookings are paid
  bool get allPaid => bookings.every((b) => b.paid);
  bool get somePaid => bookings.any((b) => b.paid);
  bool get nonePaid => bookings.every((b) => !b.paid);

  // Get mixed payment status text
  String get paymentStatusText {
    if (allPaid) return 'paid'.tr;
    if (somePaid) return 'partially_paid'.tr;
    return 'pending_payment'.tr;
  }
}