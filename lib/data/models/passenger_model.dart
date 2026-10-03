import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class PassengerModel extends UserModel {
  final String? phoneNumber;
  final String? address;
  final int totalBookings;
  final int completedBookings;
  final int cancelledBookings;
  final List<String>? favoriteRoutes;
  final bool profileCompleted;

  PassengerModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.role,
    super.photoUrl,
    super.createdAt,
    this.phoneNumber,
    this.address,
    this.totalBookings = 0,
    this.completedBookings = 0,
    this.cancelledBookings = 0,
    this.favoriteRoutes,
    this.profileCompleted = false,
  });

  factory PassengerModel.fromMap(Map<String, dynamic> data) {
    return PassengerModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'Passenger',
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      totalBookings: data['totalBookings'] ?? 0,
      completedBookings: data['completedBookings'] ?? 0,
      cancelledBookings: data['cancelledBookings'] ?? 0,
      favoriteRoutes:
      (data['favoriteRoutes'] as List?)?.map((e) => e.toString()).toList(),
      profileCompleted: data['profileCompleted'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'phoneNumber': phoneNumber,
      'address': address,
      'totalBookings': totalBookings,
      'completedBookings': completedBookings,
      'cancelledBookings': cancelledBookings,
      'favoriteRoutes': favoriteRoutes,
      'profileCompleted': profileCompleted,
    };
  }

  /// ✅ CopyWith for easy field updates
  PassengerModel copyWith({
    String? name,
    String? email,
    String? address,
    String? phoneNumber,
    int? totalBookings,
    int? completedBookings,
    int? cancelledBookings,
    List<String>? favoriteRoutes,
    bool? profileCompleted,
    String? photoUrl,
  }) {
    return PassengerModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      totalBookings: totalBookings ?? this.totalBookings,
      completedBookings: completedBookings ?? this.completedBookings,
      cancelledBookings: cancelledBookings ?? this.cancelledBookings,
      favoriteRoutes: favoriteRoutes ?? this.favoriteRoutes,
      profileCompleted: profileCompleted ?? this.profileCompleted,
    );
  }
}
