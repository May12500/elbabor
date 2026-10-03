import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/models/driver_model.dart';
import '../../../../data/models/trip_model.dart';

class DriverHomeRepository {
  static final _firestore = FirebaseFirestore.instance;

  // Existing methods
  static Future<DriverModel?> getDriverProfile(String driverId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(driverId).get();
      if (!userDoc.exists) return null;

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
      print("❌ getDriverProfile Error: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>> getDriverRealTimeStats(String driverId) async {
    try {
      final allTrips = await getAllDriverTrips(driverId);
      final now = DateTime.now();

      int totalTrips = allTrips.length;
      int completedTrips = allTrips.where((trip) => trip.status == 'completed').length;
      int cancelledTrips = allTrips.where((trip) => trip.status == 'cancelled').length;
      int activeTrips = allTrips.where((trip) =>
      (trip.status == 'draft' || trip.status == 'active' || trip.status == 'scheduled') &&
          trip.dateTime.isAfter(now)
      ).length;
      int expiredTrips = allTrips.where((trip) =>
      trip.dateTime.isBefore(now) &&
          (trip.status == 'draft' || trip.status == 'active' || trip.status == 'scheduled')
      ).length;

      double successRate = totalTrips > 0 ? (completedTrips / totalTrips * 100) : 0;

      return {
        'totalTrips': totalTrips,
        'completedTrips': completedTrips,
        'cancelledTrips': cancelledTrips,
        'activeTrips': activeTrips,
        'expiredTrips': expiredTrips,
        'successRate': successRate,
      };
    } catch (e) {
      print("❌ getDriverRealTimeStats Error: $e");
      return {
        'totalTrips': 0,
        'completedTrips': 0,
        'cancelledTrips': 0,
        'activeTrips': 0,
        'expiredTrips': 0,
        'successRate': 0,
      };
    }
  }

  static Future<List<TripModel>> getActiveTrips(String driverId) async {
    try {
      final query = await _firestore
          .collection('trips')
          .where('driverId', isEqualTo: driverId)
          .where('status', whereIn: ['active', 'scheduled'])
          .orderBy('dateTime', descending: false)
          .get();

      return query.docs.map((doc) => TripModel.fromDoc(doc)).toList();
    } catch (e) {
      print("❌ getActiveTrips Error: $e");
      return [];
    }
  }

  static Future<List<TripModel>> getUpcomingTrips(String driverId) async {
    try {
      final now = Timestamp.now();
      final query = await _firestore
          .collection('trips')
          .where('driverId', isEqualTo: driverId)
          .where('dateTime', isGreaterThan: now)
          .where('status', isEqualTo: 'scheduled')
          .orderBy('dateTime', descending: false)
          .limit(5)
          .get();

      return query.docs.map((doc) => TripModel.fromDoc(doc)).toList();
    } catch (e) {
      print("❌ getUpcomingTrips Error: $e");
      return [];
    }
  }

  // NEW: Comprehensive method for trip management
  static Future<Map<String, List<TripModel>>> getCategorizedTrips(String driverId) async {
    try {
      final allTrips = await getAllDriverTrips(driverId);
      final now = DateTime.now();

      final activeList = <TripModel>[];
      final pastList = <TripModel>[];
      final tripsToUpdate = <String>[];

      for (final trip in allTrips) {
        final isExpired = trip.dateTime.isBefore(now);

        // Handle expired trips (auto-update to completed)
        if (isExpired && (trip.status == 'draft' || trip.status == 'active' || trip.status == 'scheduled')) {
          tripsToUpdate.add(trip.id);
          pastList.add(trip.copyWith(status: 'completed'));
        }
        // Categorize as past trips
        else if (trip.status == 'completed' || trip.status == 'cancelled' || isExpired) {
          pastList.add(trip);
        }
        // Categorize as active trips
        else {
          activeList.add(trip);
        }
      }

      // Auto-update expired trips in Firestore
      if (tripsToUpdate.isNotEmpty) {
        await _updateExpiredTripsBatch(tripsToUpdate);
        print('✅ Auto-updated ${tripsToUpdate.length} expired trips');
      }

      return {
        'active': activeList,
        'past': pastList,
      };
    } catch (e) {
      print("❌ getCategorizedTrips Error: $e");
      return {'active': [], 'past': []};
    }
  }

  // Helper method to get all driver trips
  static Future<List<TripModel>> getAllDriverTrips(String driverId) async {
    try {
      final query = await _firestore
          .collection('trips')
          .where('driverId', isEqualTo: driverId)
          .orderBy('dateTime', descending: true)
          .get();

      return query.docs.map((doc) => TripModel.fromDoc(doc)).toList();
    } catch (e) {
      print("❌ getAllDriverTrips Error: $e");
      return [];
    }
  }

  // Batch update expired trips
  static Future<void> _updateExpiredTripsBatch(List<String> tripIds) async {
    try {
      final batch = _firestore.batch();

      for (final tripId in tripIds) {
        final tripRef = _firestore.collection('trips').doc(tripId);
        batch.update(tripRef, {
          'status': 'completed',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      print("❌ _updateExpiredTripsBatch Error: $e");
      rethrow;
    }
  }

  // Individual trip operations
  static Future<void> updateTripStatus(String tripId, String status) async {
    try {
      await _firestore.collection('trips').doc(tripId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("❌ updateTripStatus Error: $e");
      rethrow;
    }
  }

  static Future<void> deleteTrip(String tripId) async {
    try {
      await _firestore.collection('trips').doc(tripId).delete();
    } catch (e) {
      print("❌ deleteTrip Error: $e");
      rethrow;
    }
  }

  // Stream for real-time updates
  static Stream<List<TripModel>> getDriverTripsStream(String driverId) {
    return _firestore
        .collection('trips')
        .where('driverId', isEqualTo: driverId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => TripModel.fromDoc(doc)).toList());
  }

  static Stream<List<TripModel>> getActiveTripsStream(String driverId) {
    return _firestore
        .collection('trips')
        .where('driverId', isEqualTo: driverId)
        .where('status', whereIn: ['active', 'scheduled'])
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => TripModel.fromDoc(doc)).toList());
  }
}