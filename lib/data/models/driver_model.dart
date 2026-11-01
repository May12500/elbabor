import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class DriverModel extends UserModel {
  final String? address;
  final String? phoneNumber;
  final String? licenseNumber;
  final String? vehicleType;
  final String? vehicleModel;
  final String? vehiclePlate;
  final String? passportNumber;  // NEW
  final double rating;
  final int totalTrips;
  final int completedTrips;
  final int cancelledTrips;
  final bool profileCompleted;

  DriverModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.role,
    super.photoUrl,
    super.createdAt,
    this.address,
    this.phoneNumber,
    this.licenseNumber,
    this.vehicleType,
    this.vehicleModel,
    this.vehiclePlate,
    this.passportNumber,
    this.rating = 0.0,
    this.totalTrips = 0,
    this.completedTrips = 0,
    this.cancelledTrips = 0,
    this.profileCompleted = false,
  });

  factory DriverModel.fromMap(Map<String, dynamic> data) {
    return DriverModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'Driver',
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      address: data['address'],
      phoneNumber: data['phoneNumber'],
      licenseNumber: data['licenseNumber'],
      vehicleType: data['vehicleType'],
      vehicleModel: data['vehicleModel'],
      vehiclePlate: data['vehiclePlate'],
      passportNumber: data['passportNumber'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalTrips: data['totalTrips'] ?? 0,
      completedTrips: data['completedTrips'] ?? 0,
      cancelledTrips: data['cancelledTrips'] ?? 0,
      profileCompleted: data['profileCompleted'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'address': address,
      'phoneNumber': phoneNumber,
      'licenseNumber': licenseNumber,
      'vehicleType': vehicleType,
      'vehicleModel': vehicleModel,
      'vehiclePlate': vehiclePlate,
      'passportNumber': passportNumber,
      'rating': rating,
      'totalTrips': totalTrips,
      'completedTrips': completedTrips,
      'cancelledTrips': cancelledTrips,
      'profileCompleted': profileCompleted,
    };
  }

  /// ✅ CopyWith for easy field updates
  DriverModel copyWith({
    String? name,
    String? email,
    String? address,
    String? phoneNumber,
    String? licenseNumber,
    String? vehicleType,
    String? vehicleModel,
    String? vehiclePlate,
    String? passportNumber,
    double? rating,
    int? totalTrips,
    int? completedTrips,
    int? cancelledTrips,
    bool? profileCompleted,
    String? photoUrl,
  }) {
    return DriverModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      passportNumber: passportNumber ?? this.passportNumber,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      completedTrips: completedTrips ?? this.completedTrips,
      cancelledTrips: cancelledTrips ?? this.cancelledTrips,
      profileCompleted: profileCompleted ?? this.profileCompleted,
    );
  }
}
