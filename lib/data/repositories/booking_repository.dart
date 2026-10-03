import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingRepository {
  static final _firestore = FirebaseFirestore.instance;

  /// 🔹 Create booking with reservation status (not confirmed until payment)
  static Future<void> createBooking(BookingModel booking) async {
    final batch = _firestore.batch();
    final bookingRef = _firestore.collection('bookings').doc(booking.id);
    final userBookingRef = _firestore
        .collection('users')
        .doc(booking.passengerId)
        .collection('bookings')
        .doc(booking.id);
    final tripBookingRef = _firestore
        .collection('trips')
        .doc(booking.tripId)
        .collection('bookings')
        .doc(booking.id);

    // 🔸 Write to all three paths with the complete booking data
    final bookingData = booking.toMap();
    batch.set(bookingRef, bookingData);
    batch.set(userBookingRef, bookingData);
    batch.set(tripBookingRef, bookingData);

    // 🔸 Update trip with reserved seats (not confirmed yet)
    final tripRef = _firestore.collection('trips').doc(booking.tripId);
    batch.update(tripRef, {
      'seatsAvailable': FieldValue.increment(-booking.seatsBooked),
      'reservedSeats': FieldValue.arrayUnion(booking.seatNumbers),
      'totalReservations': FieldValue.increment(1),
      // Don't update earnings or completed payments until payment is successful
    });

    await batch.commit();
  }

  /// 🔹 Update booking status with proper seat management
  static Future<void> updateBookingStatus(
      String bookingId,
      BookingStatus newStatus, {
        PaymentStatus? paymentStatus,
        String? stripePaymentIntentId,
        double? amountPaid,
        String? failureMessage,
      }) async {
    final batch = _firestore.batch();
    final bookingRef = _firestore.collection('bookings').doc(bookingId);

    final bookingSnap = await bookingRef.get();
    if (!bookingSnap.exists) return;
    final data = bookingSnap.data()!;

    final tripId = data['tripId'];
    final passengerId = data['passengerId'];
    final seatsBooked = data['seatsBooked'] ?? 1;
    final seatNumbers = List<int>.from(data['seatNumbers'] ?? []);

    final userBookingRef = _firestore
        .collection('users')
        .doc(passengerId)
        .collection('bookings')
        .doc(bookingId);
    final tripBookingRef = _firestore
        .collection('trips')
        .doc(tripId)
        .collection('bookings')
        .doc(bookingId);

    final updateData = <String, dynamic>{
      'status': newStatus.name,
    };

    // Add payment status if provided
    if (paymentStatus != null) {
      updateData['paymentStatus'] = paymentStatus.name;
      updateData['paid'] = paymentStatus == PaymentStatus.completed;
    }

    // Add optional fields if provided
    if (stripePaymentIntentId != null) {
      updateData['stripePaymentIntentId'] = stripePaymentIntentId;
    }
    if (amountPaid != null) {
      updateData['amountPaid'] = amountPaid;
    }
    if (failureMessage != null) {
      updateData['failureMessage'] = failureMessage;
    }

    batch.update(bookingRef, updateData);
    batch.update(userBookingRef, updateData);
    batch.update(tripBookingRef, updateData);

    // Handle seat management based on status change
    final tripRef = _firestore.collection('trips').doc(tripId);

    switch (newStatus) {
      case BookingStatus.confirmed:
      // Payment successful - mark seats as confirmed
        batch.update(tripRef, {
          'confirmedSeats': FieldValue.arrayUnion(seatNumbers),
          'totalBookings': FieldValue.increment(1),
          'completedPayments': FieldValue.increment(1),
          'totalEarnings': FieldValue.increment(amountPaid ?? (data['price'] ?? 0).toDouble()),
        });
        break;

      case BookingStatus.cancelled:
      // Booking cancelled - free up seats
        batch.update(tripRef, {
          'seatsAvailable': FieldValue.increment(seatsBooked),
          'reservedSeats': FieldValue.arrayRemove(seatNumbers),
          'confirmedSeats': FieldValue.arrayRemove(seatNumbers),
          'bookedPassengers': FieldValue.arrayRemove([passengerId]),
        });
        break;

      case BookingStatus.reserved:
      // Initial reservation - seats are already reserved in createBooking
        break;

      default:
      // No special handling for other statuses
        break;
    }

    await batch.commit();
  }

  /// 🔹 Update payment status with proper seat confirmation
  static Future<void> updatePaymentStatus(
      String bookingId,
      PaymentStatus paymentStatus, {
        String? stripePaymentIntentId,
        String? failureMessage,
        double? amountPaid,
      }) async {
    final batch = _firestore.batch();
    final bookingRef = _firestore.collection('bookings').doc(bookingId);

    final bookingSnap = await bookingRef.get();
    if (!bookingSnap.exists) return;
    final data = bookingSnap.data()!;

    final tripId = data['tripId'];
    final passengerId = data['passengerId'];
    final seatNumbers = List<int>.from(data['seatNumbers'] ?? []);

    final userBookingRef = _firestore
        .collection('users')
        .doc(passengerId)
        .collection('bookings')
        .doc(bookingId);
    final tripBookingRef = _firestore
        .collection('trips')
        .doc(tripId)
        .collection('bookings')
        .doc(bookingId);

    final updateData = <String, dynamic>{
      'paymentStatus': paymentStatus.name,
      'paid': paymentStatus == PaymentStatus.completed,
    };

    // Add optional fields if provided
    if (stripePaymentIntentId != null) {
      updateData['stripePaymentIntentId'] = stripePaymentIntentId;
    }
    if (failureMessage != null) {
      updateData['failureMessage'] = failureMessage;
    }
    if (amountPaid != null) {
      updateData['amountPaid'] = amountPaid;
    }

    // If payment completed, also update booking status to confirmed
    BookingStatus? newBookingStatus;
    if (paymentStatus == PaymentStatus.completed) {
      newBookingStatus = BookingStatus.confirmed;
      updateData['status'] = BookingStatus.confirmed.name;
    } else if (paymentStatus == PaymentStatus.failed) {
      newBookingStatus = BookingStatus.cancelled;
      updateData['status'] = BookingStatus.cancelled.name;
    }

    batch.update(bookingRef, updateData);
    batch.update(userBookingRef, updateData);
    batch.update(tripBookingRef, updateData);

    // Handle seat and earnings updates based on payment status
    final tripRef = _firestore.collection('trips').doc(tripId);

    if (paymentStatus == PaymentStatus.completed) {
      // Payment successful - confirm seats and update earnings
      final currentAmountPaid = amountPaid ?? (data['amountPaid'] ?? data['price'] ?? 0).toDouble();

      batch.update(tripRef, {
        'confirmedSeats': FieldValue.arrayUnion(seatNumbers),
        'completedPayments': FieldValue.increment(1),
        'totalEarnings': FieldValue.increment(currentAmountPaid),
        'totalBookings': FieldValue.increment(1),
      });
    } else if (paymentStatus == PaymentStatus.failed) {
      // Payment failed - free up reserved seats
      batch.update(tripRef, {
        'seatsAvailable': FieldValue.increment(data['seatsBooked'] ?? 1),
        'reservedSeats': FieldValue.arrayRemove(seatNumbers),
      });
    }

    await batch.commit();
  }

  /// 🔹 Clean up expired reservations (called periodically)
  static Future<void> cleanupExpiredReservations(String tripId) async {
    final now = DateTime.now();
    final fifteenMinutesAgo = now.subtract(const Duration(minutes: 15));

    final expiredReservations = await _firestore
        .collection('trips')
        .doc(tripId)
        .collection('bookings')
        .where('status', isEqualTo: BookingStatus.reserved.name)
        .where('paymentStatus', isEqualTo: PaymentStatus.pending.name)
        .where('createdAt', isLessThan: Timestamp.fromDate(fifteenMinutesAgo))
        .get();

    final batch = _firestore.batch();

    for (final doc in expiredReservations.docs) {
      final data = doc.data();
      final bookingId = doc.id;
      final seatNumbers = List<int>.from(data['seatNumbers'] ?? []);
      final seatsBooked = data['seatsBooked'] ?? 1;

      // Update booking status to cancelled
      final bookingRef = _firestore.collection('bookings').doc(bookingId);
      final userBookingRef = _firestore
          .collection('users')
          .doc(data['passengerId'])
          .collection('bookings')
          .doc(bookingId);
      final tripBookingRef = _firestore
          .collection('trips')
          .doc(tripId)
          .collection('bookings')
          .doc(bookingId);

      batch.update(bookingRef, {
        'status': BookingStatus.cancelled.name,
        'paymentStatus': PaymentStatus.failed.name,
        'failureMessage': 'Reservation expired - payment not completed in time',
      });
      batch.update(userBookingRef, {
        'status': BookingStatus.cancelled.name,
        'paymentStatus': PaymentStatus.failed.name,
        'failureMessage': 'Reservation expired - payment not completed in time',
      });
      batch.update(tripBookingRef, {
        'status': BookingStatus.cancelled.name,
        'paymentStatus': PaymentStatus.failed.name,
        'failureMessage': 'Reservation expired - payment not completed in time',
      });

      // Free up seats
      final tripRef = _firestore.collection('trips').doc(tripId);
      batch.update(tripRef, {
        'seatsAvailable': FieldValue.increment(seatsBooked),
        'reservedSeats': FieldValue.arrayRemove(seatNumbers),
      });
    }

    if (expiredReservations.docs.isNotEmpty) {
      await batch.commit();
      print('Cleaned up ${expiredReservations.docs.length} expired reservations for trip $tripId');
    }
  }

  /// 🔹 Get active reservations for a trip (pending payment)
  static Future<List<BookingModel>> getActiveReservations(String tripId) async {
    final query = await _firestore
        .collection('trips')
        .doc(tripId)
        .collection('bookings')
        .where('status', isEqualTo: BookingStatus.reserved.name)
        .where('paymentStatus', whereIn: [PaymentStatus.pending.name, PaymentStatus.processing.name])
        .get();

    return query.docs
        .map((d) => BookingModel.fromMap(d.data(), d.id))
        .toList();
  }

  /// 🔹 Get confirmed bookings for a trip (successful payments)
  static Future<List<BookingModel>> getConfirmedBookings(String tripId) async {
    final query = await _firestore
        .collection('trips')
        .doc(tripId)
        .collection('bookings')
        .where('status', isEqualTo: BookingStatus.confirmed.name)
        .where('paymentStatus', isEqualTo: PaymentStatus.completed.name)
        .get();

    return query.docs
        .map((d) => BookingModel.fromMap(d.data(), d.id))
        .toList();
  }

  /// 🔹 Process refund for booking
  static Future<void> processRefund(
      String bookingId,
      double refundAmount,
      RefundReason refundReason,
      ) async {
    final batch = _firestore.batch();
    final bookingRef = _firestore.collection('bookings').doc(bookingId);

    final bookingSnap = await bookingRef.get();
    if (!bookingSnap.exists) return;
    final data = bookingSnap.data()!;

    final tripId = data['tripId'];
    final passengerId = data['passengerId'];

    final userBookingRef = _firestore
        .collection('users')
        .doc(passengerId)
        .collection('bookings')
        .doc(bookingId);
    final tripBookingRef = _firestore
        .collection('trips')
        .doc(tripId)
        .collection('bookings')
        .doc(bookingId);

    final isFullRefund = refundAmount == (data['amountPaid'] ?? 0).toDouble();

    final updateData = {
      'refundAmount': refundAmount,
      'refundedAt': FieldValue.serverTimestamp(),
      'refundReason': refundReason.name,
      'paymentStatus': isFullRefund ? PaymentStatus.refunded.name : PaymentStatus.partiallyRefunded.name,
    };

    batch.update(bookingRef, updateData);
    batch.update(userBookingRef, updateData);
    batch.update(tripBookingRef, updateData);

    // Update trip earnings (deduct refunded amount)
    final tripRef = _firestore.collection('trips').doc(tripId);
    batch.update(tripRef, {
      'totalEarnings': FieldValue.increment(-refundAmount),
    });

    await batch.commit();
  }

  /// 🔹 Fetch bookings by passenger
  static Future<List<BookingModel>> getPassengerBookings(String passengerId) async {
    final query = await _firestore
        .collection('users')
        .doc(passengerId)
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs
        .map((d) => BookingModel.fromMap(d.data(), d.id))
        .toList();
  }

  /// 🔹 Fetch bookings by trip
  static Future<List<BookingModel>> getTripBookings(String tripId) async {
    final query = await _firestore
        .collection('trips')
        .doc(tripId)
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs
        .map((d) => BookingModel.fromMap(d.data(), d.id))
        .toList();
  }

  /// 🔹 Get booking by ID
  static Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (doc.exists) {
        return BookingModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting booking: $e');
      return null;
    }
  }

  /// 🔹 Cancel booking and free up seats
  static Future<void> cancelBooking(String bookingId) async {
    final batch = _firestore.batch();
    final bookingRef = _firestore.collection('bookings').doc(bookingId);

    final bookingSnap = await bookingRef.get();
    if (!bookingSnap.exists) return;
    final data = bookingSnap.data()!;

    final tripId = data['tripId'];
    final passengerId = data['passengerId'];
    final seatsBooked = data['seatsBooked'] ?? 1;
    final seatNumbers = List<int>.from(data['seatNumbers'] ?? []);

    final userBookingRef = _firestore
        .collection('users')
        .doc(passengerId)
        .collection('bookings')
        .doc(bookingId);
    final tripBookingRef = _firestore
        .collection('trips')
        .doc(tripId)
        .collection('bookings')
        .doc(bookingId);

    // Update booking status
    batch.update(bookingRef, {
      'status': BookingStatus.cancelled.name,
      'paymentStatus': PaymentStatus.failed.name,
    });
    batch.update(userBookingRef, {
      'status': BookingStatus.cancelled.name,
      'paymentStatus': PaymentStatus.failed.name,
    });
    batch.update(tripBookingRef, {
      'status': BookingStatus.cancelled.name,
      'paymentStatus': PaymentStatus.failed.name,
    });

    // Free up seats on the trip
    final tripRef = _firestore.collection('trips').doc(tripId);
    batch.update(tripRef, {
      'seatsAvailable': FieldValue.increment(seatsBooked),
      'reservedSeats': FieldValue.arrayRemove(seatNumbers),
      'confirmedSeats': FieldValue.arrayRemove(seatNumbers),
      'bookedPassengers': FieldValue.arrayRemove([passengerId]),
    });

    await batch.commit();
  }

  /// 🔹 Get seat availability for a trip
  static Future<Map<String, dynamic>> getSeatAvailability(String tripId) async {
    final tripDoc = await _firestore.collection('trips').doc(tripId).get();
    if (!tripDoc.exists) {
      return {
        'totalSeats': 0,
        'availableSeats': 0,
        'reservedSeats': [],
        'confirmedSeats': [],
      };
    }

    final data = tripDoc.data()!;
    final totalSeats = data['totalSeats'] ?? data['seatsAvailable'] ?? 0;
    final reservedSeats = List<int>.from(data['reservedSeats'] ?? []);
    final confirmedSeats = List<int>.from(data['confirmedSeats'] ?? []);

    final allOccupiedSeats = {...reservedSeats, ...confirmedSeats};
    final availableSeats = totalSeats - allOccupiedSeats.length;

    return {
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'reservedSeats': reservedSeats,
      'confirmedSeats': confirmedSeats,
      'allOccupiedSeats': allOccupiedSeats.toList(),
    };
  }
}