import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../data/models/driver_model.dart';
import '../../../app/themes/app_colors.dart';

class EditDriverProfileViewModel extends GetxController {
  final isSaving = false.obs;
  final selectedImage = Rxn<File>();
  final photoUrl = RxnString();
  final hasChanges = false.obs;

  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController vehiclePlateCtrl; // NEW: Vehicle plate
  late TextEditingController passportCtrl;      // NEW: Passport number
  late TextEditingController licenseCtrl;
  late TextEditingController vehicleTypeCtrl;

  late DriverModel _originalDriver;
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void initDriver(DriverModel driver) {
    _originalDriver = driver;

    nameCtrl = TextEditingController(text: driver.name);
    phoneCtrl = TextEditingController(text: driver.phoneNumber ?? '');
    vehiclePlateCtrl = TextEditingController(text: driver.vehiclePlate ?? ''); // NEW
    passportCtrl = TextEditingController(text: driver.passportNumber ?? '');   // NEW
    licenseCtrl = TextEditingController(text: driver.licenseNumber ?? '');
    vehicleTypeCtrl = TextEditingController(text: driver.vehicleType ?? '');
    photoUrl.value = driver.photoUrl;

    // Add listeners to track changes
    nameCtrl.addListener(checkChanges);
    phoneCtrl.addListener(checkChanges);
    vehiclePlateCtrl.addListener(checkChanges); // NEW
    passportCtrl.addListener(checkChanges);     // NEW
    licenseCtrl.addListener(checkChanges);
    vehicleTypeCtrl.addListener(checkChanges);
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    vehiclePlateCtrl.dispose(); // NEW
    passportCtrl.dispose();     // NEW
    licenseCtrl.dispose();
    vehicleTypeCtrl.dispose();
    super.onClose();
  }

  void checkChanges() {
    final currentData = _getCurrentData();
    hasChanges.value = currentData != _getOriginalData() || selectedImage.value != null;
  }

  Map<String, dynamic> _getCurrentData() {
    return {
      'name': nameCtrl.text.trim(),
      'phoneNumber': phoneCtrl.text.trim(),
      'vehiclePlate': vehiclePlateCtrl.text.trim(), // NEW
      'passportNumber': passportCtrl.text.trim(),   // NEW
      'licenseNumber': licenseCtrl.text.trim(),
      'vehicleType': vehicleTypeCtrl.text.trim(),
    };
  }

  Map<String, dynamic> _getOriginalData() {
    return {
      'name': _originalDriver.name,
      'phoneNumber': _originalDriver.phoneNumber ?? '',
      'vehiclePlate': _originalDriver.vehiclePlate ?? '', // NEW
      'passportNumber': _originalDriver.passportNumber ?? '', // NEW
      'licenseNumber': _originalDriver.licenseNumber ?? '',
      'vehicleType': _originalDriver.vehicleType ?? '',
    };
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
        selectedImage.value = File(picked.path);
        checkChanges();
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

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "please_enter_name".tr;
    }
    if (value.trim().length < 2) {
      return "name_too_short".tr;
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }
    final cleaned = value.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.length < 10) {
      return "invalid_phone_number".tr;
    }
    return null;
  }

  // NEW: Vehicle plate validation
  String? validateVehiclePlate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    if (value.trim().length < 4) {
      return "vehicle_plate_too_short".tr;
    }
    return null;
  }

  // NEW: Passport validation
  String? validatePassport(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    if (value.trim().length < 6) {
      return "passport_too_short".tr;
    }
    return null;
  }

  String? validateLicense(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // License is optional
    }
    if (value.trim().length < 5) {
      return "license_too_short".tr;
    }
    return null;
  }

  Future<void> saveProfile() async {
    if (!hasChanges.value) {
      Get.back();
      return;
    }
    isSaving.value = true;

    try {
      String? imageUrl = photoUrl.value;

      // Upload new image if selected
      if (selectedImage.value != null) {
        imageUrl = await _uploadImage(selectedImage.value!);
      }

      // Create updated driver model
      final updatedDriver = _originalDriver.copyWith(
        name: nameCtrl.text.trim(),
        phoneNumber: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
        vehiclePlate: vehiclePlateCtrl.text.trim().isEmpty ? null : vehiclePlateCtrl.text.trim().toUpperCase(), // NEW
        passportNumber: passportCtrl.text.trim().isEmpty ? null : passportCtrl.text.trim().toUpperCase(),       // NEW
        licenseNumber: licenseCtrl.text.trim().isEmpty ? null : licenseCtrl.text.trim(),
        vehicleType: vehicleTypeCtrl.text.trim().isEmpty ? null : vehicleTypeCtrl.text.trim(),
        photoUrl: imageUrl,
      );
      print('save profile: ${updatedDriver.toMap()}');

      // Update in Firestore
      await _firestore
          .collection('users')
          .doc(_originalDriver.uid)
          .update(updatedDriver.toMap());

      // Show success message
      Get.snackbar(
        "success".tr,
        "profile_updated_success".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withOpacity(0.9),
        colorText: Colors.white,
      );

      // Navigate back with updated data
      Get.back(result: updatedDriver);

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
      isSaving.value = false;
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage.ref().child('driver_profiles/${_originalDriver.uid}/$timestamp.jpg');

      final task = await ref.putFile(
        image,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'uploaded_by': _originalDriver.uid},
        ),
      );

      return await task.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Image upload error: $e');
      Get.snackbar(
        "upload_failed".tr,
        "image_upload_failed".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
      return null;
    }
  }
}