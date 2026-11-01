import 'package:elbabor/data/models/trip_model.dart';
import 'package:get/get.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/passenger_model.dart';
import '../../../data/repositories/passenger_repository.dart';
import '../../common/message/model/chat_model.dart';
import '../../common/message/viewmodels/message_tab_viewmodel.dart';
import '../../../data/services/firebase_service.dart';

class PassengerInfoViewModel extends GetxController {
  final isLoading = false.obs;
  final passenger = Rxn<PassengerModel>();
  final bookings = <BookingModel>[].obs;
  final bookingStats = <String, int>{}.obs; // NEW: For detailed stats

  @override
  void onInit() {
    super.onInit();
    final PassengerModel? p = Get.arguments;
    if (p != null) {
      passenger.value = p;
      fetchPassengerDetails();
      fetchPassengerBookings();
      fetchBookingStats(); // NEW: Fetch detailed stats
    }
  }

  Future<void> fetchPassengerDetails() async {
    isLoading.value = true;
    try {
      final uid = passenger.value?.uid;
      if (uid == null) return;

      final fetchedPassenger = await PassengerRepository.getPassengerById(uid);
      if (fetchedPassenger != null) {
        passenger.value = fetchedPassenger;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPassengerBookings() async {
    final uid = passenger.value?.uid;
    if (uid == null) return;
    final passengerBookings = await PassengerRepository.getPassengerBookings(uid);
    bookings.value = passengerBookings;
  }

  // NEW: Fetch detailed booking statistics
  Future<void> fetchBookingStats() async {
    final uid = passenger.value?.uid;
    if (uid == null) return;

    final stats = await PassengerRepository.getPassengerBookingStats(uid);
    bookingStats.value = stats;
  }

  // Getter for UI to use stats
  int get completedBookings => bookingStats['completed'] ?? passenger.value?.completedBookings ?? 0;
  int get cancelledBookings => bookingStats['cancelled'] ?? passenger.value?.cancelledBookings ?? 0;
  int get totalBookings => bookingStats['total'] ?? passenger.value?.totalBookings ?? 0;
  int get pendingBookings => bookingStats['pending'] ?? 0;

  void onMessagePassenger() {
    final currentPassenger = passenger.value;
    if (currentPassenger == null) return;

    // Get the MessagesViewModel to create/access chat
    final messagesController = Get.find<MessagesViewModel>();

    // Create or open chat with this passenger
    messagesController.createNewChat(
      currentPassenger.uid,
      currentPassenger.name,
    );
  }

  // Method to be called directly from trip details
  static void messagePassengerDirectly(PassengerModel passenger) {
    try {
      final messagesController = Get.find<MessagesViewModel>();
      messagesController.createNewChat(passenger.uid, passenger.name);
    } catch (e) {
      print('Error messaging passenger directly: $e');
      Get.snackbar('Error', 'Failed to start chat with ${passenger.name}');
    }
  }

  // Alternative method that navigates directly to chat
  void onMessagePassengerDirect() {
    final currentPassenger = passenger.value;
    if (currentPassenger == null) return;

    // Create chat data directly
    _createOrOpenChat(currentPassenger);
  }

  Future<void> _createOrOpenChat(PassengerModel passenger) async {
    try {
      final currentUserId = FirebaseService.currentUserId;
      if (currentUserId == null) return;

      // Check if chat already exists
      final existingChat = await _findExistingChat(passenger.uid);

      if (existingChat != null) {
        // Open existing chat
        Get.toNamed('/chat-detail', arguments: existingChat);
      } else {
        // Create new chat
        final messagesController = Get.find<MessagesViewModel>();
        await messagesController.createNewChat(passenger.uid, passenger.name);
      }
    } catch (e) {
      print('Error creating/opening chat: $e');
      Get.snackbar('Error', 'Failed to start chat with ${passenger.name}');
    }
  }

  Future<ChatModel?> _findExistingChat(String passengerId) async {
    try {
      final currentUserId = FirebaseService.currentUserId;
      if (currentUserId == null) return null;

      final querySnapshot = await FirebaseService.firestore
          .collection('chats')
          .where('passengerId', isEqualTo: passengerId)
          .where('driverId', isEqualTo: currentUserId)
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