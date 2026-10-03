import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbabor/data/models/passenger_info_model.dart';
import 'package:elbabor/data/models/vehicle_info_model.dart';
import 'package:elbabor/data/models/trip_segment_model.dart';
import 'package:get/get.dart';

import '../services/currency_service.dart';

class TripModel {
  final String id;
  final String driverId;
  final String fromCity; // First segment's fromCity
  final String destinationCity; // Last segment's toCity
  final List<TripSegment> segments; // Multiple segments instead of single trip
  final DateTime dateTime; // Main trip departure time
  final int seatsAvailable;
  final int totalSeats;
  final double totalPrice; // Sum of all segment prices
  final double rating;
  final List<String> acceptedPaymentMethods;
  final String status;
  final Timestamp createdAt;

  final List<int> reservedSeats;
  final List<String> bookedPassengers;
  final List<PassengerInfo> passengerInfo;

  // Payment-related analytics
  final double totalEarnings;
  final int totalBookings;
  final int completedPayments;

  TripModel({
    required this.id,
    required this.driverId,
    required this.fromCity,
    required this.destinationCity,
    required this.segments,
    required this.dateTime,
    required this.seatsAvailable,
    required this.totalSeats,
    required this.totalPrice,
    required this.rating,
    required this.acceptedPaymentMethods,
    required this.status,
    required this.createdAt,
    this.reservedSeats = const [],
    this.bookedPassengers = const [],
    this.passengerInfo = const [],
    this.totalEarnings = 0.0,
    this.totalBookings = 0,
    this.completedPayments = 0,
  });

  // Helper getters for backward compatibility
  String get vehicleType => segments.isNotEmpty ? segments.first.vehicleType : '';
  String get departurePoint => segments.isNotEmpty ? segments.first.fromPoint : '';
  String get arrivalPoint => segments.isNotEmpty ? segments.last.toPoint : '';
  double get pricePerPassenger => totalPrice;

  TripModel copyWith({
    String? id,
    String? driverId,
    String? fromCity,
    String? destinationCity,
    List<TripSegment>? segments,
    DateTime? dateTime,
    int? seatsAvailable,
    int? totalSeats,
    double? totalPrice,
    double? rating,
    List<String>? acceptedPaymentMethods,
    String? status,
    Timestamp? createdAt,
    List<int>? reservedSeats,
    List<String>? bookedPassengers,
    List<PassengerInfo>? passengerInfo,
    double? totalEarnings,
    int? totalBookings,
    int? completedPayments,
  }) {
    return TripModel(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      fromCity: fromCity ?? this.fromCity,
      destinationCity: destinationCity ?? this.destinationCity,
      segments: segments ?? this.segments,
      dateTime: dateTime ?? this.dateTime,
      seatsAvailable: seatsAvailable ?? this.seatsAvailable,
      totalSeats: totalSeats ?? this.totalSeats,
      totalPrice: totalPrice ?? this.totalPrice,
      rating: rating ?? this.rating,
      acceptedPaymentMethods: acceptedPaymentMethods ?? this.acceptedPaymentMethods,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reservedSeats: reservedSeats ?? this.reservedSeats,
      bookedPassengers: bookedPassengers ?? this.bookedPassengers,
      passengerInfo: passengerInfo ?? this.passengerInfo,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalBookings: totalBookings ?? this.totalBookings,
      completedPayments: completedPayments ?? this.completedPayments,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'driverId': driverId,
    'fromCity': fromCity,
    'destinationCity': destinationCity,
    'segments': segments.map((segment) => segment.toJson()).toList(),
    'dateTime': Timestamp.fromDate(dateTime),
    'seatsAvailable': seatsAvailable,
    'totalSeats': totalSeats,
    'totalPrice': totalPrice,
    'rating': rating,
    'acceptedPaymentMethods': acceptedPaymentMethods,
    'status': status,
    'createdAt': createdAt,
    'reservedSeats': reservedSeats,
    'bookedPassengers': bookedPassengers,
    'passengerInfo': passengerInfo.map((p) => p.toJson()).toList(),
    'totalEarnings': totalEarnings,
    'totalBookings': totalBookings,
    'completedPayments': completedPayments,
  };

  factory TripModel.fromJson(Map<String, dynamic> json) {
    List<TripSegment> segments = [];
    if (json['segments'] != null) {
      segments = (json['segments'] as List)
          .map((segmentJson) => TripSegment.fromJson(segmentJson))
          .toList();
    } else {
      // Backward compatibility: convert single trip to single segment
      segments = [
        TripSegment(
          id: 'legacy_${json['id']}',
          vehicleType: json['vehicleType'] ?? '',
          fromPoint: json['departurePoint'] ?? '',
          toPoint: json['arrivalPoint'] ?? '',
          fromCity: json['fromCity'] ?? '',
          toCity: json['destinationCity'] ?? '',
          price: (json['pricePerPassenger'] ?? 0).toDouble(),
          vehicle: json['vehicle'] != null
              ? VehicleInfo.fromJson(json['vehicle'])
              : null,
        )
      ];
    }

    return TripModel(
      id: json['id'] ?? '',
      driverId: json['driverId'] ?? '',
      fromCity: json['fromCity'] ?? '',
      destinationCity: json['destinationCity'] ?? '',
      segments: segments,
      dateTime: (json['dateTime'] is Timestamp)
          ? (json['dateTime'] as Timestamp).toDate()
          : DateTime.tryParse(json['dateTime'] ?? '') ?? DateTime.now(),
      seatsAvailable: json['seatsAvailable'] ?? 0,
      totalSeats: json['totalSeats'] ?? 0,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      acceptedPaymentMethods: json['acceptedPaymentMethods'] != null
          ? List<String>.from(json['acceptedPaymentMethods'])
          : ['stripe_card'],
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] ?? Timestamp.now(),
      reservedSeats: json['reservedSeats'] != null
          ? List<int>.from(json['reservedSeats'])
          : [],
      bookedPassengers: json['bookedPassengers'] != null
          ? List<String>.from(json['bookedPassengers'])
          : [],
      passengerInfo: json['passengerInfo'] != null
          ? (json['passengerInfo'] as List)
          .map((e) => PassengerInfo.fromJson(e))
          .toList()
          : [],
      totalEarnings: (json['totalEarnings'] ?? 0).toDouble(),
      totalBookings: json['totalBookings'] ?? 0,
      completedPayments: json['completedPayments'] ?? 0,
    );
  }

  factory TripModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TripModel.fromJson(data).copyWith(id: doc.id);
  }

  static TripModel empty() => TripModel(
    id: '',
    driverId: '',
    fromCity: '',
    destinationCity: '',
    segments: [],
    dateTime: DateTime.now(),
    seatsAvailable: 0,
    totalSeats: 0,
    totalPrice: 0.0,
    rating: 0.0,
    acceptedPaymentMethods: ['stripe_card'],
    status: 'draft',
    createdAt: Timestamp.now(),
  );

  // Helper methods
  bool get requiresOnlinePayment => true;

  String get paymentMethod => 'stripe_card';

  String get paymentMethodsDisplay => 'credit_card'.tr;

  bool supportsPaymentMethod(String method) {
    return acceptedPaymentMethods.contains(method);
  }

  double get potentialEarnings {
    return totalSeats * totalPrice;
  }

  double get currentEarnings {
    return completedPayments * totalPrice;
  }

  String get displayPrice => CurrencyService().formatPrice(totalPrice);

  double getDisplayPrice() {
    return CurrencyService().convertFromUSD(totalPrice);
  }

  // Multi-segment specific helpers
  bool get hasMultipleSegments => segments.length > 1;

  String get tripSummary {
    if (segments.isEmpty) return '';
    if (segments.length == 1) {
      return '${segments.first.vehicleType}: ${segments.first.fromPoint} → ${segments.first.toPoint}';
    }
    return '${segments.length} segments: ${segments.first.fromPoint} → ${segments.last.toPoint}';
  }

  // Calculate total duration (you can enhance this with actual duration calculation)
  Duration get estimatedDuration {
    // This is a placeholder - you might want to calculate based on segment distances
    return const Duration(hours: 1);
  }

  // Get all unique vehicle types used in the trip
  List<String> get vehicleTypesUsed {
    return segments.map((segment) => segment.vehicleType).toSet().toList();
  }

  // Validate segment continuity
  bool get segmentsAreContinuous {
    for (int i = 1; i < segments.length; i++) {
      if (segments[i].fromCity != segments[i-1].toCity) {
        return false;
      }
    }
    return true;
  }
  bool get canBeCompleted {
    return status == 'active' && dateTime.isBefore(DateTime.now());
  }

  bool get isCompleted {
    return status == 'completed';
  }
}