import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/passenger_model.dart';
import '../models/booking_model.dart';
import '../models/trip_model.dart';

class PassengerRepository {
  static final _firestore = FirebaseFirestore.instance;

  /// 🔹 Fetch Passenger Profile + Booking Stats (total/completed/cancelled)
  static Future<PassengerModel?> getPassengerById(String passengerId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(passengerId).get();
      if (!userDoc.exists) return null;

      // 🔹 Fetch passenger's bookings to get accurate counts
      final bookingsQuery = await _firestore
          .collection('bookings')
          .where('passengerId', isEqualTo: passengerId)
          .get();

      // Calculate booking statistics
      final totalBookings = bookingsQuery.docs.length;
      final completedBookings = bookingsQuery.docs
          .where((doc) {
        final data = doc.data();
        return data['status'] == 'confirmed' &&
            data['paymentStatus'] == 'completed';
      })
          .length;
      final cancelledBookings = bookingsQuery.docs
          .where((doc) {
        final data = doc.data();
        return data['status'] == 'cancelled' ||
            data['paymentStatus'] == 'failed';
      })
          .length;

      return PassengerModel.fromMap({
        ...userDoc.data()!,
        'uid': passengerId,
        'totalBookings': totalBookings,
        'completedBookings': completedBookings,
        'cancelledBookings': cancelledBookings,
      });
    } catch (e) {
      print("❌ getPassengerById Error: $e");
      return null;
    }
  }

  /// 🔹 Fetch passenger's bookings with filtering options
  static Future<List<BookingModel>> getPassengerBookings(
      String passengerId, {
        BookingStatus? status,
        PaymentStatus? paymentStatus,
      }) async {
    try {
      Query query = _firestore
          .collection('bookings')
          .where('passengerId', isEqualTo: passengerId)
          .orderBy('createdAt', descending: true);

      // Add status filter if provided
      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      // Add payment status filter if provided
      if (paymentStatus != null) {
        query = query.where('paymentStatus', isEqualTo: paymentStatus.name);
      }

      final querySnapshot = await query.limit(50).get();
      return querySnapshot.docs
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>; // CAST HERE
        return BookingModel.fromMap(data, doc.id);
      })
          .toList();
    } catch (e) {
      print("❌ getPassengerBookings Error: $e");
      return [];
    }
  }

  /// 🔹 Get passenger booking statistics
  static Future<Map<String, int>> getPassengerBookingStats(String passengerId) async {
    try {
      final bookingsQuery = await _firestore
          .collection('bookings')
          .where('passengerId', isEqualTo: passengerId)
          .get();

      final totalBookings = bookingsQuery.docs.length;
      final completedBookings = bookingsQuery.docs
          .where((doc) {
        final data = doc.data();
        return data['status'] == 'confirmed' &&
            data['paymentStatus'] == 'completed';
      })
          .length;
      final cancelledBookings = bookingsQuery.docs
          .where((doc) {
        final data = doc.data();
        return data['status'] == 'cancelled' ||
            data['paymentStatus'] == 'failed';
      })
          .length;
      final pendingBookings = bookingsQuery.docs
          .where((doc) {
        final data = doc.data();
        return data['status'] == 'reserved' &&
            data['paymentStatus'] == 'pending';
      })
          .length;

      return {
        'total': totalBookings,
        'completed': completedBookings,
        'cancelled': cancelledBookings,
        'pending': pendingBookings,
      };
    } catch (e) {
      print("❌ getPassengerBookingStats Error: $e");
      return {'total': 0, 'completed': 0, 'cancelled': 0, 'pending': 0};
    }
  }

  /// 🔹 Fetch trips that passenger has booked
  static Future<List<TripModel>> getPassengerTrips(String passengerId) async {
    try {
      final query = await _firestore
          .collection('trips')
          .where('bookedPassengers', arrayContains: passengerId)
          .get();

      return query.docs.map((d) => TripModel.fromJson(d.data())).toList();
    } catch (e) {
      print("❌ getPassengerTrips Error: $e");
      return [];
    }
  }

  /// 🔹 Update passenger profile info
  static Future<void> updatePassengerProfile(String passengerId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(passengerId).update(updates);
    } catch (e) {
      print("❌ updatePassengerProfile Error: $e");
    }
  }
}