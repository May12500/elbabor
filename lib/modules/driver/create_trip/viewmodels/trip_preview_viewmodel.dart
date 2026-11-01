import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:elbabor/app/routes/app_routes.dart';
import '../../../../data/models/trip_model.dart';

class TripPreviewViewModel extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final isPublishing = false.obs;
  TripModel? tripModel;

  void setTrip(TripModel trip) {
    tripModel = trip;
  }

  Future<void> publishTrip() async {
    if (tripModel == null) return;

    isPublishing.value = true;

    try {
      final tripRef = _firestore.collection('trips').doc();
      final newTrip = tripModel!.copyWith(
        id: tripRef.id,
        createdAt: Timestamp.now(),
        driverId: _auth.currentUser?.uid ?? '',
        status: 'active',
      );

      await tripRef.set(newTrip.toJson());

      Get.snackbar(
        "success".tr,
        "trip_published_successfully".tr,
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offAllNamed(Routes.DRIVER_HOME);
    } catch (e) {
      Get.snackbar(
        "publish_failed".tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isPublishing.value = false;
    }
  }
}
