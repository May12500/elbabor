import 'package:elbabor/data/models/vehicle_info_model.dart';

class TripSegment {
  final String id;
  final String vehicleType;
  final String fromPoint;
  final String toPoint;
  final String fromCity;
  final String toCity;
  final double price;
  final DateTime? segmentDateTime; // Optional override for main trip datetime
  final VehicleInfo? vehicle; // Only for vehicle segments
  final String? operatorName; // For ferry/train/bus operators
  final Duration? estimatedDuration; // Estimated duration for this segment
  final double? distance; // Distance in km

  TripSegment({
    required this.id,
    required this.vehicleType,
    required this.fromPoint,
    required this.toPoint,
    required this.fromCity,
    required this.toCity,
    required this.price,
    this.segmentDateTime,
    this.vehicle,
    this.operatorName,
    this.estimatedDuration,
    this.distance,
  });

  TripSegment copyWith({
    String? id,
    String? vehicleType,
    String? fromPoint,
    String? toPoint,
    String? fromCity,
    String? toCity,
    double? price,
    DateTime? segmentDateTime,
    VehicleInfo? vehicle,
    String? operatorName,
    Duration? estimatedDuration,
    double? distance,
  }) {
    return TripSegment(
      id: id ?? this.id,
      vehicleType: vehicleType ?? this.vehicleType,
      fromPoint: fromPoint ?? this.fromPoint,
      toPoint: toPoint ?? this.toPoint,
      fromCity: fromCity ?? this.fromCity,
      toCity: toCity ?? this.toCity,
      price: price ?? this.price,
      segmentDateTime: segmentDateTime ?? this.segmentDateTime,
      vehicle: vehicle ?? this.vehicle,
      operatorName: operatorName ?? this.operatorName,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      distance: distance ?? this.distance,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicleType': vehicleType,
    'fromPoint': fromPoint,
    'toPoint': toPoint,
    'fromCity': fromCity,
    'toCity': toCity,
    'price': price,
    'segmentDateTime': segmentDateTime?.millisecondsSinceEpoch,
    'vehicle': vehicle?.toJson(),
    'operatorName': operatorName,
    'estimatedDuration': estimatedDuration?.inMinutes,
    'distance': distance,
  };

  factory TripSegment.fromJson(Map<String, dynamic> json) {
    return TripSegment(
      id: json['id'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      fromPoint: json['fromPoint'] ?? '',
      toPoint: json['toPoint'] ?? '',
      fromCity: json['fromCity'] ?? '',
      toCity: json['toCity'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      segmentDateTime: json['segmentDateTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['segmentDateTime'])
          : null,
      vehicle: json['vehicle'] != null
          ? VehicleInfo.fromJson(json['vehicle'])
          : null,
      operatorName: json['operatorName'],
      estimatedDuration: json['estimatedDuration'] != null
          ? Duration(minutes: json['estimatedDuration'])
          : null,
      distance: (json['distance'] ?? 0).toDouble(),
    );
  }

  // Helper methods
  bool get requiresVehicle => vehicleType == 'Car' || vehicleType == 'Van' || vehicleType == 'SUV';

  String get segmentDisplayName {
    switch (vehicleType) {
      case 'Car':
      case 'Van':
      case 'SUV':
        return 'Car Ride';
      case 'Bus':
        return 'Bus Journey';
      case 'Ferry':
        return 'Ferry Crossing';
      default:
        return vehicleType;
    }
  }

  String get displayPrice {
    return '\$${price.toStringAsFixed(2)}';
  }

  // For creating empty segments
  static TripSegment empty() => TripSegment(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    vehicleType: '',
    fromPoint: '',
    toPoint: '',
    fromCity: '',
    toCity: '',
    price: 0.0,
  );
}