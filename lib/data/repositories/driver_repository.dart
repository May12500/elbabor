import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver_model.dart';
import '../models/trip_model.dart';

class DriverRepository {
  static final _firestore = FirebaseFirestore.instance;

  /// 🔹 Fetch driver profile + trip stats (total/completed/cancelled)
  static Future<DriverModel?> getDriverById(String driverId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(driverId).get();
      if (!userDoc.exists) return null;

      // Fetch trip stats
      final tripsQuery = await _firestore
          .collection('trips')
          .where('driverId', isEqualTo: driverId)
          .get();

      final totalTrips = tripsQuery.docs.length;
      final completedTrips = tripsQuery.docs
          .where((d) => d['status'] == 'completed')
          .length;
      final cancelledTrips = tripsQuery.docs
          .where((d) => d['status'] == 'cancelled')
          .length;

      return DriverModel.fromMap({
        ...userDoc.data()!,
        'uid': driverId,
        'totalTrips': totalTrips,
        'completedTrips': completedTrips,
        'cancelledTrips': cancelledTrips,
      });
    } catch (e) {
      print("❌ getDriverById Error: $e");
      return null;
    }
  }

  /// 🔹 Fetch all trips of a specific driver
  static Future<List<TripModel>> getDriverTrips(String driverId) async {
    try {
      final query = await _firestore
          .collection('trips')
          .where('driverId', isEqualTo: driverId)
          .get();

      return query.docs.map((d) => TripModel.fromJson(d.data())).toList();
    } catch (e) {
      print("❌ getDriverTrips Error: $e");
      return [];
    }
  }

  /// 🔹 Update driver rating (optional helper)
  static Future<void> updateDriverRating(String driverId, double newRating) async {
    try {
      await _firestore.collection('users').doc(driverId).update({
        'rating': newRating,
      });
    } catch (e) {
      print("❌ updateDriverRating Error: $e");
    }
  }
}
