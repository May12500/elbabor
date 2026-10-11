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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? editingTripId;

  final segments = <TripSegment>[].obs;
  final currentEditingSegmentIndex = Rx<int?>(null);
  final dateTime = Rx<DateTime?>(null);
  final seatsAvailable = 1.obs;
  final paymentMethod = 'Cash'.obs;
  final isLoading = false.obs;
  final List<String> vehicleTypes = ['Car', 'Van', 'Bus', 'Ferry', 'SUV'];

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

  @override
  void onInit() {
    super.onInit();
    fromCityController.addListener(updateCurrentSegment);
    toCityController.addListener(updateCurrentSegment);
    fromPointController.addListener(updateCurrentSegment);
    toPointController.addListener(updateCurrentSegment);
    priceController.addListener(updateCurrentSegment);
    brandController.addListener(updateCurrentSegment);
    modelController.addListener(updateCurrentSegment);
    plateController.addListener(updateCurrentSegment);
    operatorNameController.addListener(updateCurrentSegment);
    final args = Get.arguments;
    if (args != null) {
      if (args is TripModel) loadTripForEdit(args);
      else if (args is Map<String, dynamic>) loadTripForEdit(TripModel.fromJson(args));
      else if (args is Map) loadTripForEdit(TripModel.fromJson(Map<String, dynamic>.from(args)));
    }
  }

  void loadTripForEdit(TripModel trip) {
    editingTripId = trip.id;
    segments.assignAll(trip.segments);
    dateTime.value = trip.dateTime;
    seatsAvailable.value = trip.seatsAvailable;
    paymentMethod.value = trip.acceptedPaymentMethods.contains('stripe_card') ? 'Credit Card' : 'Cash';
    if (segments.isNotEmpty) setCurrentSegment(0);
  }

  void addSegment() {
    String fromCity = segments.isNotEmpty ? segments.last.toCity : '';
    String fromPoint = segments.isNotEmpty ? segments.last.toPoint : '';
    final newSegment = TripSegment(id: DateTime.now().millisecondsSinceEpoch.toString(), vehicleType: '', fromPoint: fromPoint, toPoint: '', fromCity: fromCity, toCity: '', price: 0.0);
    segments.add(newSegment);
    setCurrentSegment(segments.length - 1);
    fromCityController.text = fromCity;
    fromPointController.text = fromPoint;
    toCityController.clear(); toPointController.clear(); priceController.clear(); brandController.clear(); modelController.clear(); plateController.clear(); operatorNameController.clear();
    currentSegmentVehicleType.value = '';
  }

  void removeSegment(int index) {
    segments.removeAt(index);
    if (segments.isEmpty) currentEditingSegmentIndex.value = null;
    else if (currentEditingSegmentIndex.value == index) {
      currentEditingSegmentIndex.value = segments.length - 1;
      loadSegmentIntoForm(segments.length - 1);
    }
  }

  void setCurrentSegment(int index) {
    currentEditingSegmentIndex.value = index;
    if (index >= 0 && index < segments.length) loadSegmentIntoForm(index);
  }

  void loadSegmentIntoForm(int index) {
    fromCityController.removeListener(updateCurrentSegment);
    toCityController.removeListener(updateCurrentSegment);
    fromPointController.removeListener(updateCurrentSegment);
    toPointController.removeListener(updateCurrentSegment);
    priceController.removeListener(updateCurrentSegment);
    brandController.removeListener(updateCurrentSegment);
    modelController.removeListener(updateCurrentSegment);
    plateController.removeListener(updateCurrentSegment);
    operatorNameController.removeListener(updateCurrentSegment);
    final segment = segments[index];
    fromCityController.text = segment.fromCity;
    toCityController.text = segment.toCity;
    fromPointController.text = segment.fromPoint;
    toPointController.text = segment.toPoint;
    priceController.text = segment.price > 0 ? segment.price.toStringAsFixed(2) : '';
    currentSegmentVehicleType.value = segment.vehicleType;
    if (segment.vehicle != null) {
      brandController.text = segment.vehicle!.brand;
      modelController.text = segment.vehicle!.model;
      plateController.text = segment.vehicle!.plate;
    } else { brandController.clear(); modelController.clear(); plateController.clear(); }
    operatorNameController.text = segment.operatorName ?? '';
    fromCityController.addListener(updateCurrentSegment);
    toCityController.addListener(updateCurrentSegment);
    fromPointController.addListener(updateCurrentSegment);
    toPointController.addListener(updateCurrentSegment);
    priceController.addListener(updateCurrentSegment);
    brandController.addListener(updateCurrentSegment);
    modelController.addListener(updateCurrentSegment);
    plateController.addListener(updateCurrentSegment);
    operatorNameController.addListener(updateCurrentSegment);
  }

  void updateCurrentSegment() {
    final currentIndex = currentEditingSegmentIndex.value;
    if (currentIndex == null || currentIndex >= segments.length) return;
    final raw = priceController.text.trim().replaceAll(',', '.').replaceAll(' ', '').replaceAll('\$', '').replaceAll('€', '');
    final price = double.tryParse(raw) ?? 0.0;
    VehicleInfo? vehicle;
    if (currentSegmentVehicleType.value == 'Car' || currentSegmentVehicleType.value == 'Van' || currentSegmentVehicleType.value == 'SUV') {
      vehicle = VehicleInfo(brand: brandController.text.trim(), model: modelController.text.trim(), plate: plateController.text.trim());
    }
    final updated = TripSegment(id: segments[currentIndex].id, vehicleType: currentSegmentVehicleType.value, fromPoint: fromPointController.text.trim(), toPoint: toPointController.text.trim(), fromCity: fromCityController.text.trim(), toCity: toCityController.text.trim(), price: price, vehicle: vehicle, operatorName: operatorNameController.text.trim().isNotEmpty ? operatorNameController.text.trim() : null);
    segments[currentIndex] = updated;
  }

  String getDepartureLabel(String v) => v == 'Ferry' ? 'departure_port'.tr : 'pickup_point'.tr;
  String getArrivalLabel(String v) => v == 'Ferry' ? 'arrival_port'.tr : 'dropoff_point'.tr;

  Future<void> selectDateTime(BuildContext context) async {
    final d = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(2100), initialDate: dateTime.value ?? DateTime.now());
    if (d == null) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t == null) return;
    dateTime.value = DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  void incrementSeats() => seatsAvailable.value++;
  void decrementSeats() { if (seatsAvailable.value > 1) seatsAvailable.value--; }
  void selectPayment(String m) => paymentMethod.value = m;
  void selectVehicleTypeForCurrentSegment(String type) { currentSegmentVehicleType.value = type; updateCurrentSegment(); }

  bool validateSegments() {
    if (segments.isEmpty) { Get.snackbar('error'.tr, 'add_at_least_one_segment'.tr); return false; }
    updateCurrentSegment();
    for (int i = 0; i < segments.length; i++) {
      final s = segments[i];
      if (s.vehicleType.isEmpty) { Get.snackbar('error'.tr, 'select_vehicle_type_for_segment'.tr + ' ${i + 1}'); return false; }
      if (s.fromPoint.isEmpty || s.toPoint.isEmpty) { Get.snackbar('error'.tr, 'fill_all_points_for_segment'.tr + ' ${i + 1}'); return false; }
      if (s.fromCity.isEmpty || s.toCity.isEmpty) { Get.snackbar('error'.tr, 'fill_all_cities_for_segment'.tr + ' ${i + 1}'); return false; }
      if (s.price <= 0) { Get.snackbar('error'.tr, 'enter_valid_price_for_segment'.tr + ' ${i + 1}'); return false; }
    }
    return true;
  }

  Future<void> onPreviewPressed() async {
    updateCurrentSegment();
    if (segments.isEmpty) { Get.snackbar('error'.tr, 'add_at_least_one_segment'.tr); return; }
    if (!validateSegments()) return;
    if (dateTime.value == null) { Get.snackbar('error'.tr, 'select_trip_date_time'.tr); return; }
    final totalPrice = segments.fold(0.0, (sum, s) => sum + s.price);
    final trip = TripModel(id: editingTripId ?? '', driverId: _auth.currentUser?.uid ?? '', fromCity: segments.isNotEmpty ? segments.first.fromCity : '', destinationCity: segments.isNotEmpty ? segments.last.toCity : '', segments: segments.toList(), dateTime: dateTime.value ?? DateTime.now(), seatsAvailable: seatsAvailable.value, totalSeats: seatsAvailable.value, totalPrice: totalPrice, acceptedPaymentMethods: [paymentMethod.value == 'Credit Card' ? 'stripe_card' : 'cash'], rating: 0.0, status: 'draft', createdAt: Timestamp.now());
    Get.toNamed(Routes.TRIP_PREVIEW, arguments: trip);
  }

  // LIGNE 345 FIXEE - PLUS DE "!" 
  Future<void> saveDirectEdit() async {
    try {
      updateCurrentSegment();
      isLoading.value = true;

      // VERIFICATIONS SANS "!"
      if (editingTripId == null || editingTripId!.isEmpty) {
        Get.snackbar('Erreur', 'ID du trajet manquant - repasse par Mes Trajets > Modifier', backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      if (segments.isEmpty) {
        Get.snackbar('Erreur', 'Aucun segment', backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      if (!validateSegments()) return;

      final totalPrice = segments.fold(0.0, (sum, s) => sum + s.price);
      final id = editingTripId!;

      // UPDATE MINIMAL - SEULEMENT PRIX + SEGMENTS
      await _firestore.collection('trips').doc(id).update({
        'totalPrice': totalPrice,
        'segments': segments.map((s) => s.toJson()).toList(),
        'updatedAt': Timestamp.now(),
      });

      Get.snackbar('Succes', 'Trajet mis a jour: ${totalPrice.toStringAsFixed(2)}', backgroundColor: Colors.green, colorText: Colors.white);
      await Future.delayed(Duration(milliseconds: 600));
      Get.offAllNamed(Routes.HOME);
    } catch (e, stack) {
      // Affiche la vraie erreur avec la ligne
      print('SAVE ERROR: $e');
      print(stack);
      Get.snackbar('Erreur Firestore L345', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, duration: Duration(seconds: 8));
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fromCityController.dispose(); toCityController.dispose(); fromPointController.dispose(); toPointController.dispose(); priceController.dispose(); brandController.dispose(); modelController.dispose(); plateController.dispose(); operatorNameController.dispose();
    super.onClose();
  }
}
