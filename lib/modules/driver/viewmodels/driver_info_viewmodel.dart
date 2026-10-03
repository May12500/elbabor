import 'package:get/get.dart';
import '../../../data/models/driver_model.dart';
import '../../../data/repositories/driver_repository.dart';
import '../../common/message/model/chat_model.dart';
import '../../common/message/viewmodels/message_tab_viewmodel.dart';
import '../../../data/models/trip_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/services/firebase_service.dart';
import '../home/repository/driver_home_repository.dart';

class DriverInfoViewModel extends GetxController {
  final isLoading = false.obs;
  final driver = Rxn<DriverModel>();
  final trips = <TripModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    final DriverModel? d = Get.arguments;
    if (d != null) {
      driver.value = d;
      fetchDriverDetails();
      fetchDriverTrips();
    }
  }

  Future<void> fetchDriverDetails() async {
    isLoading.value = true;
    try {
      final uid = driver.value?.uid;
      if (uid == null) return;

      final fetchedDriver = await DriverRepository.getDriverById(uid);
      if (fetchedDriver != null) {
        driver.value = fetchedDriver;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDriverTrips() async {
    final uid = driver.value?.uid;
    if (uid == null) return;
    trips.value = await DriverHomeRepository.getActiveTrips(uid);
  }

  void onMessageDriver() {
    final currentDriver = driver.value;
    if (currentDriver == null) return;

    // Get the MessagesViewModel to create/access chat
    final messagesController = Get.find<MessagesViewModel>();

    // Create or open chat with this driver
    messagesController.createNewChat(
      currentDriver.uid,
      currentDriver.name,
    );
  }

  // Alternative method that navigates directly to chat
  void onMessageDriverDirect() {
    final currentDriver = driver.value;
    if (currentDriver == null) return;

    // Create chat data directly
    _createOrOpenChat(currentDriver);
  }

  Future<void> _createOrOpenChat(DriverModel driver) async {
    try {
      final currentUserId = FirebaseService.currentUserId;
      if (currentUserId == null) return;

      // Check if chat already exists
      final existingChat = await _findExistingChat(driver.uid);

      if (existingChat != null) {
        // Open existing chat
        Get.toNamed('/chat-detail', arguments: existingChat);
      } else {
        // Create new chat
        final messagesController = Get.find<MessagesViewModel>();
        await messagesController.createNewChat(driver.uid, driver.name);
      }
    } catch (e) {
      print('Error creating/opening chat: $e');
      Get.snackbar('Error', 'Failed to start chat with ${driver.name}');
    }
  }

  Future<ChatModel?> _findExistingChat(String driverId) async {
    try {
      final currentUserId = FirebaseService.currentUserId;
      if (currentUserId == null) return null;

      final querySnapshot = await FirebaseService.firestore
          .collection('chats')
          .where('driverId', isEqualTo: driverId)
          .where('passengerId', isEqualTo: currentUserId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ChatModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error finding existing chat: $e');
      return null;
    }
  }
}