import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_colors.dart';

class DriverDetailsViewModel extends GetxController {
  final formKey = GlobalKey<FormState>();
  final vehiclePlateController = TextEditingController(); // NEW: Vehicle plate
  final passportController = TextEditingController();     // NEW: Passport number
  final phoneController = TextEditingController();
  final licenseController = TextEditingController();

  final selectedImage = Rx<XFile?>(null);
  final isLoading = false.obs;
  final isUploadingImage = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _loadExistingData();
  }

  @override
  void onClose() {
    vehiclePlateController.dispose();
    passportController.dispose();
    phoneController.dispose();
    licenseController.dispose();
    super.onClose();
  }

  Future<void> _loadExistingData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        vehiclePlateController.text = data?['vehiclePlate'] ?? ''; // NEW
        passportController.text = data?['passportNumber'] ?? '';   // NEW
        phoneController.text = data?['phoneNumber'] ?? '';
        licenseController.text = data?['licenseNumber'] ?? '';
      }
    } catch (e) {
      debugPrint('Error loading existing data: $e');
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (picked != null) {
        selectedImage.value = picked;
      }
    } catch (e) {
      Get.snackbar(
        "error".tr,
        "failed_to_pick_image".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
      debugPrint('Image picker error: $e');
    }
  }

  // NEW: Vehicle plate validation
  String? validateVehiclePlate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "please_enter_vehicle_plate".tr;
    }
    if (value.trim().length < 4) {
      return "vehicle_plate_too_short".tr;
    }
    return null;
  }

  // NEW: Passport validation
  String? validatePassport(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "please_enter_passport".tr;
    }
    if (value.trim().length < 6) {
      return "passport_too_short".tr;
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "please_enter_phone".tr;
    }
    final cleaned = value.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.length < 10) {
      return "invalid_phone_number".tr;
    }
    return null;
  }

  String? validateLicense(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "please_enter_license".tr;
    }
    if (value.trim().length < 5) {
      return "license_too_short".tr;
    }
    return null;
  }

  Future<void> onSubmitPressed() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        "validation_error".tr,
        "please_fix_errors".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final uid = _auth.currentUser!.uid;
      String? photoUrl;

      // Upload image if selected
      if (selectedImage.value != null) {
        isUploadingImage.value = true;
        photoUrl = await _uploadImage(uid);
        isUploadingImage.value = false;
      }

      // Update user profile
      await _updateDriverProfile(uid, photoUrl);

      Get.snackbar(
        "success".tr,
        "profile_updated_success".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withOpacity(0.9),
        colorText: Colors.white,
      );

      // Navigate to driver home
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(Routes.DRIVER_HOME);

    } catch (e) {
      Get.snackbar(
        "error".tr,
        "failed_to_save_profile".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
      debugPrint('Profile update error: $e');
    } finally {
      isLoading.value = false;
      isUploadingImage.value = false;
    }
  }

  Future<String> _uploadImage(String uid) async {
    try {
      final ref = _storage.ref().child('driver_profiles/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final task = await ref.putFile(
        File(selectedImage.value!.path),
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'uploaded_by': uid},
        ),
      );
      return await task.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Image upload error: $e');
      rethrow;
    }
  }

  Future<void> _updateDriverProfile(String uid, String? photoUrl) async {
    final updateData = <String, dynamic>{
      'vehiclePlate': vehiclePlateController.text.trim().toUpperCase(), // NEW: Store in uppercase
      'passportNumber': passportController.text.trim().toUpperCase(),   // NEW
      'phoneNumber': phoneController.text.trim(),
      'licenseNumber': licenseController.text.trim(),
      'profileCompleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (photoUrl != null) {
      updateData['photoUrl'] = photoUrl;
    }

    await _firestore.collection('users').doc(uid).update(updateData);
  }

  void onSkipPressed() {
    Get.dialog(
      AlertDialog(
        title: Text("complete_later".tr),
        content: Text("safety_verification_warning".tr), // Updated warning
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("cancel".tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed(Routes.DRIVER_HOME);
            },
            child: Text("proceed".tr),
          ),
        ],
      ),
    );
  }
}