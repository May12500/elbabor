import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String id;
  final String tripId;
  final String bookingId;
  final String passengerId;
  final String driverId;
  final double rating; // 1-5 stars
  final String? comment;
  final DateTime createdAt;
  final String passengerName;
  final String? passengerPhotoUrl;

  RatingModel({
    required this.id,
    required this.tripId,
    required this.bookingId,
    required this.passengerId,
    required this.driverId,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.passengerName,
    this.passengerPhotoUrl,
  });

  factory RatingModel.fromMap(Map<String, dynamic> data, String id) {
    return RatingModel(
      id: id,
      tripId: data['tripId'] ?? '',
      bookingId: data['bookingId'] ?? '',
      passengerId: data['passengerId'] ?? '',
      driverId: data['driverId'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      passengerName: data['passengerName'] ?? 'Passenger',
      passengerPhotoUrl: data['passengerPhotoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'bookingId': bookingId,
      'passengerId': passengerId,
      'driverId': driverId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'passengerName': passengerName,
      'passengerPhotoUrl': passengerPhotoUrl,
    };
  }
}