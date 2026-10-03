import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../data/models/trip_model.dart';
import '../../../../data/models/trip_segment_model.dart';
import '../../../../data/models/vehicle_info_model.dart';

class CreateTripViewModel extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Segment management
  final segments = <TripSegment>[].obs;
  final currentEditingSegmentIndex = Rx<int?>(null);

  // Main trip controllers
  final dateTime = Rx<DateTime?>(null);
  final seatsAvailable = 1.obs;
  final paymentMethod = 'Credit Card'.obs;
  final isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> vehicleTypes = [
    'Car',
    'Van',
    'SUV',
    'Ferry',
  ];

  // Text controllers for current segment
  final fromCityController = TextEditingController();
  final toCityController = TextEditingController();
  final fromPointController = TextEditingController();
  final toPointController = TextEditingController();
  final priceController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final plateController = TextEditingController();
  final operatorNameController = TextEditingController();

  final currentSegmentVehicleType = ''.obs;

  /// --- Segment Management ---

  void addSegment() {
    String fromCity = '';
    String fromPoint = '';

    // If there are previous segments, auto-fill from the last segment
    if (segments.isNotEmpty) {
      final lastSegment = segments.last;
      fromCity = lastSegment.toCity;
      fromPoint = lastSegment.toPoint;
    }

    final newSegment = TripSegment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      vehicleType: '',
      fromPoint: fromPoint,
      toPoint: '',
      fromCity: fromCity,
      toCity: '',
      price: 0.0,
    );

    segments.add(newSegment);
    setCurrentSegment(segments.length - 1);

    // Auto-fill the form fields
    fromCityController.text = fromCity;
    fromPointController.text = fromPoint;
    toCityController.clear();
    toPointController.clear();
    priceController.clear();
    brandController.clear();
    modelController.clear();
    plateController.clear();
    operatorNameController.clear();
    currentSegmentVehicleType.value = '';
  }

  void removeSegment(int index) {
    segments.removeAt(index);
    if (segments.isEmpty) {
      currentEditingSegmentIndex.value = null;
    } else if (currentEditingSegmentIndex.value == index) {
      currentEditingSegmentIndex.value = segments.length - 1;
      loadSegmentIntoForm(segments.length - 1);
    }
  }

  void setCurrentSegment(int index) {
    currentEditingSegmentIndex.value = index;
    if (index >= 0 && index < segments.length) {
      loadSegmentIntoForm(index);
    }
  }

  void loadSegmentIntoForm(int index) {
    final segment = segments[index];
    fromCityController.text = segment.fromCity;
    toCityController.text = segment.toCity;
    fromPointController.text = segment.fromPoint;
    toPointController.text = segment.toPoint;
    priceController.text = segment.price > 0 ? segment.price.toStringAsFixed(2) : '';
    currentSegmentVehicleType.value = segment.vehicleType;

    // Vehicle info
    if (segment.vehicle != null) {
      brandController.text = segment.vehicle!.brand;
      modelController.text = segment.vehicle!.model;
      plateController.text = segment.vehicle!.plate;
    } else {
      brandController.clear();
      modelController.clear();
      plateController.clear();
    }

    // Operator name
    operatorNameController.text = segment.operatorName ?? '';
  }

  void clearSegmentForm() {
    fromCityController.clear();
    toCityController.clear();
    fromPointController.clear();
    toPointController.clear();
    priceController.clear();
    brandController.clear();
    modelController.clear();
    plateController.clear();
    operatorNameController.clear();
    currentSegmentVehicleType.value = '';
  }

  void updateCurrentSegment() {
    final currentIndex = currentEditingSegmentIndex.value;
    if (currentIndex == null || currentIndex >= segments.length) return;

    final price = double.tryParse(priceController.text.trim()) ?? 0.0;

    VehicleInfo? vehicle;
    if (currentSegmentVehicleType.value == 'Car' ||
        currentSegmentVehicleType.value == 'Van' ||
        currentSegmentVehicleType.value == 'SUV') {
      vehicle = VehicleInfo(
        brand: brandController.text.trim(),
        model: modelController.text.trim(),
        plate: plateController.text.trim(),
      );
    }

    final updatedSegment = TripSegment(
      id: segments[currentIndex].id,
      vehicleType: currentSegmentVehicleType.value,
      fromPoint: fromPointController.text.trim(),
      toPoint: toPointController.text.trim(),
      fromCity: fromCityController.text.trim(),
      toCity: toCityController.text.trim(),
      price: price,
      vehicle: vehicle,
      operatorName: operatorNameController.text.trim().isNotEmpty
          ? operatorNameController.text.trim()
          : null,
    );

    segments[currentIndex] = updatedSegment;
  }

  /// --- UI Logic ---

  String getDepartureLabel(String vehicleType) {
    switch (vehicleType) {
      case 'Ferry':
        return 'departure_port'.tr;
      default:
        return 'pickup_point'.tr;
    }
  }

  String getArrivalLabel(String vehicleType) {
    switch (vehicleType) {
      case 'Ferry':
        return 'arrival_port'.tr;
      default:
        return 'dropoff_point'.tr;
    }
  }

  /// --- Selectors ---
  Future<void> selectDateTime(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    dateTime.value = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  void incrementSeats() => seatsAvailable.value++;
  void decrementSeats() {
    if (seatsAvailable.value > 1) seatsAvailable.value--;
  }

  void selectPayment(String method) => paymentMethod.value = method;

  void selectVehicleTypeForCurrentSegment(String type) {
    currentSegmentVehicleType.value = type;
    updateCurrentSegment();
  }

  /// --- Validation ---
  bool validateSegments() {
    if (segments.isEmpty) {
      Get.snackbar('error'.tr, 'add_at_least_one_segment'.tr);
      return false;
    }

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      if (segment.vehicleType.isEmpty) {
        Get.snackbar('error'.tr, 'select_vehicle_type_for_segment'.tr + ' ${i + 1}');
        return false;
      }
      if (segment.fromPoint.isEmpty || segment.toPoint.isEmpty) {
        Get.snackbar('error'.tr, 'fill_all_points_for_segment'.tr + ' ${i + 1}');
        return false;
      }
      if (segment.fromCity.isEmpty || segment.toCity.isEmpty) {
        Get.snackbar('error'.tr, 'fill_all_cities_for_segment'.tr + ' ${i + 1}');
        return false;
      }
      if (segment.price <= 0) {
        Get.snackbar('error'.tr, 'enter_valid_price_for_segment'.tr + ' ${i + 1}');
        return false;
      }
    }

    // Validate continuity between segments
    for (int i = 1; i < segments.length; i++) {
      if (segments[i].fromCity != segments[i-1].toCity) {
        Get.snackbar('error'.tr, 'segments_must_be_connected'.tr);
        return false;
      }
    }

    return true;
  }

  /// --- Actions ---
  Future<void> onPreviewPressed() async {
    if (!validateSegments()) return;
    if (dateTime.value == null) {
      Get.snackbar(
        'error'.tr,
        'select_trip_date_time'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Calculate total price
    final totalPrice = segments.fold(0.0, (sum, segment) => sum + segment.price);

    final trip = TripModel(
      id: '',
      driverId: _auth.currentUser!.uid,
      fromCity: segments.first.fromCity,
      destinationCity: segments.last.toCity,
      segments: segments.toList(),
      dateTime: dateTime.value!,
      seatsAvailable: seatsAvailable.value,
      totalSeats: seatsAvailable.value,
      totalPrice: totalPrice,
      acceptedPaymentMethods: [paymentMethod.value == 'Credit Card' ? 'stripe_card' : 'cash'],
      rating: 0.0,
      status: 'draft',
      createdAt: Timestamp.now(),
    );

    Get.toNamed(Routes.TRIP_PREVIEW, arguments: trip);
  }

  Future<void> publishTrip(TripModel trip) async {
    isLoading.value = true;
    try {
      final docRef = _firestore.collection('trips').doc();
      final tripData = trip.copyWith(
        id: docRef.id,
        status: 'active',
        createdAt: Timestamp.now(),
      );
      await docRef.set(tripData.toJson());
      Get.snackbar('success'.tr, 'trip_published_successfully'.tr);
      Get.offAllNamed(Routes.DRIVER_HOME);
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// --- Clean up controllers ---
  @override
  void onClose() {
    fromCityController.dispose();
    toCityController.dispose();
    fromPointController.dispose();
    toPointController.dispose();
    priceController.dispose();
    brandController.dispose();
    modelController.dispose();
    plateController.dispose();
    operatorNameController.dispose();
    super.onClose();
  }
}