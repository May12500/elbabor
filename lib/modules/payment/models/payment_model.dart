import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentMethod {
  stripeCard,
  googlePay,
  cash,
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  partiallyRefunded,
}

class PaymentInfo {
  final String id;
  final String bookingId;
  final String passengerId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final String? stripePaymentIntentId;
  final String? failureReason;

  PaymentInfo({
    required this.id,
    required this.bookingId,
    required this.passengerId,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
    this.stripePaymentIntentId,
    this.failureReason,
  });

  factory PaymentInfo.fromMap(Map<String, dynamic> data) {
    return PaymentInfo(
      id: data['id'] ?? '',
      bookingId: data['bookingId'] ?? '',
      passengerId: data['passengerId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      method: _parsePaymentMethod(data['method']),
      status: _parsePaymentStatus(data['status']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      stripePaymentIntentId: data['stripePaymentIntentId'],
      failureReason: data['failureReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingId': bookingId,
      'passengerId': passengerId,
      'amount': amount,
      'method': method.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'stripePaymentIntentId': stripePaymentIntentId,
      'failureReason': failureReason,
    };
  }

  static PaymentMethod _parsePaymentMethod(String method) {
    switch (method) {
      case 'stripe_card': return PaymentMethod.stripeCard;
      case 'google_pay': return PaymentMethod.googlePay;
      case 'cash': return PaymentMethod.cash;
      default: return PaymentMethod.stripeCard;
    }
  }

  static PaymentStatus _parsePaymentStatus(String status) {
    switch (status) {
      case 'pending': return PaymentStatus.pending;
      case 'processing': return PaymentStatus.processing;
      case 'completed': return PaymentStatus.completed;
      case 'failed': return PaymentStatus.failed;
      case 'refunded': return PaymentStatus.refunded;
      case 'partially_refunded': return PaymentStatus.partiallyRefunded;
      default: return PaymentStatus.pending;
    }
  }
}