import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';

class RatingViewModel extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final isLoading = false.obs;
  final rating = 0.0.obs;
  final commentController = TextEditingController();
  final selectedRating = 0.obs;

  late String bookingId;
  late String tripId;
  late String driverId;

  @override
  void onInit() {
    super.onInit();
    _getArguments();
  }

  void _getArguments() {
    try {
      final arguments = Get.arguments;
      if (arguments != null && arguments is Map<String, dynamic>) {
        bookingId = arguments['bookingId']?.toString() ?? '';
        tripId = arguments['tripId']?.toString() ?? '';
        driverId = arguments['driverId']?.toString() ?? '';

        // Debug print to verify arguments
        debugPrint("🎯 RatingView arguments received:");
        debugPrint("📋 bookingId: $bookingId");
        debugPrint("🚗 tripId: $tripId");
        debugPrint("👨‍💼 driverId: $driverId");

        // Validate required parameters
        if (bookingId.isEmpty || tripId.isEmpty || driverId.isEmpty) {
          debugPrint("❌ Missing required parameters");
          throw Exception("Missing required parameters");
        } else {
          debugPrint("✅ All parameters are valid");
        }
      } else {
        debugPrint("❌ No arguments provided");
        throw Exception("No arguments provided");
      }
    } catch (e) {
      debugPrint("❌ Error getting arguments: $e");
      Get.snackbar(
        "error".tr,
        "failed_to_load_rating".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
      // Navigate back if arguments are invalid
      Future.delayed(const Duration(seconds: 2), () => Get.back());
    }
  }

  void setRating(int stars) {
    selectedRating.value = stars;
    rating.value = stars.toDouble();
    debugPrint("⭐ Rating set to: $stars stars");
  }

  Future<void> submitRating() async {
    debugPrint("🚀 Starting rating submission process...");

    if (selectedRating.value == 0) {
      debugPrint("❌ No rating selected - submission cancelled");
      Get.snackbar(
        "rating_required".tr,
        "please_select_rating".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    // Validate parameters again before submission
    if (bookingId.isEmpty || tripId.isEmpty || driverId.isEmpty) {
      debugPrint("❌ Invalid parameters - submission cancelled");
      Get.snackbar(
        "error".tr,
        "invalid_rating_parameters".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    debugPrint("✅ Parameters validated, starting submission...");
    isLoading.value = true;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint("❌ User not logged in");
        throw Exception("User not logged in");
      }

      debugPrint("👤 User authenticated: ${user.uid}");

      // Get passenger details with error handling
      DocumentSnapshot passengerDoc;
      try {
        debugPrint("📖 Fetching passenger details from users/${user.uid}");
        passengerDoc = await _firestore.collection('users').doc(user.uid).get();
        debugPrint("✅ Passenger document exists: ${passengerDoc.exists}");

        if (passengerDoc.exists) {
          debugPrint("📊 Passenger data: ${passengerDoc.data()}");
        } else {
          debugPrint("⚠️ Passenger document does not exist");
        }
      } catch (e) {
        debugPrint("❌ Error fetching passenger details: $e");
        throw Exception("Failed to load passenger information");
      }

      final passengerData = passengerDoc.data() as Map<String, dynamic>? ?? {};
      debugPrint("👤 Passenger name: ${passengerData['name'] ?? 'Not found'}");

      // Create rating document
      final ratingId = _firestore.collection('ratings').doc().id;
      debugPrint("🆕 Generated rating ID: $ratingId");

      // Create rating data
      final ratingData = {
        'id': ratingId,
        'tripId': tripId,
        'bookingId': bookingId,
        'passengerId': user.uid,
        'driverId': driverId,
        'rating': rating.value,
        'createdAt': FieldValue.serverTimestamp(),
        'passengerName': passengerData['name']?.toString() ?? 'Passenger',
        'passengerPhotoUrl': passengerData['photoUrl']?.toString(),
      };

      // Add comment if provided
      final comment = commentController.text.trim();
      if (comment.isNotEmpty) {
        ratingData['comment'] = comment;
        debugPrint("💬 Comment added: $comment");
      }

      debugPrint("📊 Rating data to be saved:");
      debugPrint("  - ID: $ratingId");
      debugPrint("  - Trip ID: $tripId");
      debugPrint("  - Booking ID: $bookingId");
      debugPrint("  - Driver ID: $driverId");
      debugPrint("  - Rating: ${rating.value}");
      debugPrint("  - Passenger: ${ratingData['passengerName']}");

      // Save rating to Firestore
      try {
        debugPrint("💾 Attempting to save rating to ratings/$ratingId");
        await _firestore.collection('ratings').doc(ratingId).set(ratingData);
        debugPrint("✅ Rating successfully saved to Firestore!");

        // Verify the rating was saved
        final savedRating = await _firestore.collection('ratings').doc(ratingId).get();
        debugPrint("🔍 Rating verification - exists: ${savedRating.exists}");
        if (savedRating.exists) {
          debugPrint("🎉 Rating confirmed saved in database!");
        } else {
          debugPrint("❌ Rating not found after save operation!");
        }
      } catch (e) {
        debugPrint("❌ Error saving rating to Firestore: $e");
        rethrow;
      }

      // Update rating prompt status with error handling
      try {
        debugPrint("🔄 Updating rating prompt status for booking: $bookingId");
        await _firestore.collection('ratingPrompts').doc(bookingId).update({
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
        });
        debugPrint("✅ Rating prompt updated to completed status");
      } catch (e) {
        debugPrint("⚠️ Warning: Could not update rating prompt: $e");
        // Continue even if prompt update fails
      }

      // Update driver's average rating
      debugPrint("📈 Starting driver rating update process...");
      await _updateDriverRating();

      debugPrint("🎊 Rating submission completed successfully!");

      // Show success message FIRST
      Get.snackbar(
        "thank_you".tr,
        "rating_submitted_success".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3), // Ensure it shows for 3 seconds
      );

      // Wait a bit for the snackbar to show, then navigate back
      await Future.delayed(const Duration(milliseconds: 1500));

      debugPrint("🔙 Navigating back to previous screen");
      Get.back(result: true);

    } on FirebaseException catch (e) {
      debugPrint("🔥 Firebase error in submitRating:");
      debugPrint("   Code: ${e.code}");
      debugPrint("   Message: ${e.message}");
      debugPrint("   Details: ${e.stackTrace}");
      Get.snackbar(
        "error".tr,
        "firebase_error_occurred".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint("💥 General error in submitRating: $e");
      debugPrint("Stack trace: ${e.toString()}");
      Get.snackbar(
        "error".tr,
        "failed_to_submit_rating".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
      debugPrint("🏁 Rating submission process finished");
    }
  }
  Future<void> _updateDriverRating() async {
    debugPrint("📊 Starting driver rating calculation...");
    try {
      // Get all ratings for this driver
      debugPrint("🔍 Querying ratings for driver: $driverId");
      final ratingsSnapshot = await _firestore
          .collection('ratings')
          .where('driverId', isEqualTo: driverId)
          .get();

      debugPrint("📈 Found ${ratingsSnapshot.docs.length} ratings for driver");

      if (ratingsSnapshot.docs.isEmpty) {
        debugPrint("⚠️ No ratings found for driver, skipping update");
        return;
      }

      double totalRating = 0;
      int validRatings = 0;

      for (final doc in ratingsSnapshot.docs) {
        final ratingValue = doc.data()['rating'];
        final docId = doc.id;
        if (ratingValue != null) {
          totalRating += (ratingValue as num).toDouble();
          validRatings++;
          debugPrint("   - Rating $docId: $ratingValue");
        } else {
          debugPrint("   - Rating $docId: NULL (skipped)");
        }
      }

      debugPrint("📊 Rating summary:");
      debugPrint("   - Total valid ratings: $validRatings");
      debugPrint("   - Sum of ratings: $totalRating");

      if (validRatings > 0) {
        final averageRating = totalRating / validRatings;
        final roundedRating = double.parse(averageRating.toStringAsFixed(1));

        debugPrint("🧮 Calculated average: $averageRating");
        debugPrint("🔢 Rounded average: $roundedRating");

        // Update driver's rating
        debugPrint("💾 Updating driver document: users/$driverId");
        try {
          await _firestore.collection('users').doc(driverId).update({
            'rating': roundedRating,
            'totalRatings': validRatings,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          debugPrint("✅ Driver rating updated successfully!");
          debugPrint("   - New rating: $roundedRating");
          debugPrint("   - Total ratings: $validRatings");
        } catch (e) {
          debugPrint("❌ Error updating driver document: $e");
          throw e;
        }
      } else {
        debugPrint("⚠️ No valid ratings found for calculation");
      }

    } catch (e) {
      debugPrint("💥 Error in _updateDriverRating: $e");
      debugPrint("Stack trace: ${e.toString()}");
      // Don't show error to user for background update
    }
  }

  void skipRating() {
    debugPrint("⏭️ User chose to skip rating");
    Get.dialog(
      AlertDialog(
        title: Text("skip_rating".tr),
        content: Text("are_you_sure_skip_rating".tr),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint("❌ Skip cancelled");
              Get.back();
            },
            child: Text("cancel".tr),
          ),
          TextButton(
            onPressed: () {
              debugPrint("✅ Skip confirmed");
              Get.back();
              _dismissRatingPrompt();
            },
            child: Text("skip".tr),
          ),
        ],
      ),
    );
  }

  Future<void> _dismissRatingPrompt() async {
    debugPrint("🗑️ Dismissing rating prompt for booking: $bookingId");
    try {
      await _firestore.collection('ratingPrompts').doc(bookingId).update({
        'status': 'dismissed',
        'dismissedAt': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ Rating prompt dismissed successfully");
      Get.back();
    } catch (e) {
      debugPrint("❌ Error dismissing rating prompt: $e");
      Get.snackbar(
        "error".tr,
        "failed_to_dismiss_rating".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    debugPrint("🔚 RatingViewModel disposed");
    commentController.dispose();
    super.onClose();
  }
}