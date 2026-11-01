import 'package:cloud_firestore/cloud_firestore.dart';

class RatingPromptModel {
  final String id;
  final String bookingId;
  final String tripId;
  final String passengerId;
  final String driverId;
  final String passengerName;
  final String status; // pending, completed, dismissed
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? dismissedAt;
  final bool reminderSent;

  RatingPromptModel({
    required this.id,
    required this.bookingId,
    required this.tripId,
    required this.passengerId,
    required this.driverId,
    required this.passengerName,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.dismissedAt,
    this.reminderSent = false,
  });

  factory RatingPromptModel.fromMap(Map<String, dynamic> data, String id) {
    return RatingPromptModel(
      id: id,
      bookingId: data['bookingId'] ?? '',
      tripId: data['tripId'] ?? '',
      passengerId: data['passengerId'] ?? '',
      driverId: data['driverId'] ?? '',
      passengerName: data['passengerName'] ?? 'Passenger',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      dismissedAt: data['dismissedAt'] != null
          ? (data['dismissedAt'] as Timestamp).toDate()
          : null,
      reminderSent: data['reminderSent'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'tripId': tripId,
      'passengerId': passengerId,
      'driverId': driverId,
      'passengerName': passengerName,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'dismissedAt': dismissedAt != null ? Timestamp.fromDate(dismissedAt!) : null,
      'reminderSent': reminderSent,
    };
  }

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isDismissed => status == 'dismissed';
}