import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/services/firebase_service.dart';
import '../model/chat_model.dart';
import '../model/message_model.dart';

class MessagesViewModel extends GetxController {
  final isLoading = false.obs;
  final chats = <ChatModel>[].obs;
  final selectedFilter = 'all'.obs;
  final isDriverRole = false.obs;
  final totalUnreadCount = 0.obs; // Added total unread count

  String? _currentUserRole;

  @override
  void onInit() {
    super.onInit();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    await _loadUserRole();
    await loadChats();
    _setupChatsListener();
  }

  Future<void> _loadUserRole() async {
    try {
      final userData = await FirebaseService.getCurrentUserData();
      _currentUserRole = userData?['role'];
      isDriverRole.value = _currentUserRole == 'Driver';
    } catch (e) {
      print('Error loading user role: $e');
      isDriverRole.value = false;
    }
  }

  // Get current user info
  String get currentUserId => FirebaseService.currentUserId ?? '';

  // Use the observable for isDriver check
  bool get isDriver => isDriverRole.value;

  // Calculate total unread count
  int get _calculateTotalUnreadCount {
    return chats.fold(0, (sum, chat) => sum + chat.unreadCount);
  }

  Future<void> loadChats() async {
    try {
      isLoading.value = true;
      await _fetchChats();
      _updateTotalUnreadCount();
    } catch (e) {
      print('Error loading chats: $e');
      Get.snackbar('Error', 'Failed to load messages');
    } finally {
      isLoading.value = false;
    }
  }

  void _setupChatsListener() {
    FirebaseService.firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .listen((snapshot) {
      final chatList = snapshot.docs.map((doc) {
        return ChatModel.fromFirestore(doc);
      }).toList();
      chats.assignAll(chatList);
      _updateTotalUnreadCount();
    });
  }

  void _updateTotalUnreadCount() {
    totalUnreadCount.value = _calculateTotalUnreadCount;
  }

  void applyFilter(String filter) {
    selectedFilter.value = filter;
    // Filter logic will be implemented based on chat data
  }

  List<ChatModel> get filteredChats {
    switch (selectedFilter.value) {
      case 'unread':
        return chats.where((chat) => chat.unreadCount > 0).toList();
      case 'trips':
        return chats.where((chat) => chat.tripId != null).toList();
      case 'passengers':
        return chats.where((chat) => chat.otherUser.role == 'Passenger').toList();
      case 'drivers':
        return chats.where((chat) => chat.otherUser.role == 'Driver').toList();
      default:
        return chats.toList();
    }
  }

  void searchChats() {
    Get.snackbar('Search', 'Search functionality coming soon!');
  }

  void openChat(ChatModel chat) {
    Get.toNamed('/chat-detail', arguments: chat);
  }

  void findUsersToMessage() {
    if (isDriver) {
      Get.toNamed('/driver-passengers');
    } else {
      Get.toNamed('/passenger-drivers');
    }
  }

  Future<void> _fetchChats() async {
    try {
      final querySnapshot = await FirebaseService.firestore
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .orderBy('lastMessageTime', descending: true)
          .get();

      final chatList = querySnapshot.docs.map((doc) {
        return ChatModel.fromFirestore(doc);
      }).toList();

      chats.assignAll(chatList);
      _updateTotalUnreadCount();
    } catch (e) {
      print('Error fetching chats: $e');
      rethrow;
    }
  }

  // Create new chat with enhanced data
  Future<void> createNewChat(String otherUserId, String otherUserName, {String? tripId, Map<String, dynamic>? tripInfo}) async {
    try {
      // Check if chat already exists first
      final existingChat = await _findExistingChat(otherUserId);
      if (existingChat != null) {
        openChat(existingChat);
        return;
      }

      final currentUserId = FirebaseService.currentUserId!;
      final currentUserData = await FirebaseService.getCurrentUserData();
      final currentUserName = currentUserData?['name'] ?? 'User';
      final currentUserRole = currentUserData?['role'] ?? 'User';

      // Determine who is driver and who is passenger
      final isCurrentUserDriver = currentUserRole == 'Driver';
      final driverId = isCurrentUserDriver ? currentUserId : otherUserId;
      final passengerId = isCurrentUserDriver ? otherUserId : currentUserId;
      final driverName = isCurrentUserDriver ? currentUserName : otherUserName;
      final passengerName = isCurrentUserDriver ? otherUserName : currentUserName;

      final chatData = {
        'driverId': driverId,
        'passengerId': passengerId,
        'lastMessage': 'Chat started',
        'lastMessageTime': Timestamp.now(),
        'unreadCount': 0,
        'createdAt': Timestamp.now(),
        'tripId': tripId,
        'participants': [currentUserId, otherUserId],
        'driverName': driverName,
        'passengerName': passengerName,
        'driverPhotoUrl': isCurrentUserDriver ? currentUserData!['photoUrl'] : null,
        'passengerPhotoUrl': isCurrentUserDriver ? null : currentUserData?['photoUrl'],
        'otherUserOnline': false, // Default to offline
        // Store trip info if available
        if (tripInfo != null) ...{
          'tripFrom': tripInfo['from'],
          'tripTo': tripInfo['to'],
          'tripDate': tripInfo['date'] != null ? Timestamp.fromDate(tripInfo['date']) : null,
        },
      };

      final docRef = await FirebaseService.firestore.collection('chats').add(chatData);

      // Create the first welcome message
      await _createWelcomeMessage(docRef.id, otherUserName);

      // Navigate to the new chat
      final newChat = ChatModel(
        id: docRef.id,
        driverId: driverId,
        passengerId: passengerId,
        lastMessage: 'Chat started',
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
        createdAt: DateTime.now(),
        tripId: tripId,
        otherUser: ChatUser(
          id: otherUserId,
          name: otherUserName,
          role: isCurrentUserDriver ? 'Passenger' : 'Driver',
          isOnline: false,
        ),
        tripInfo: tripInfo, // Include trip info
      );

      openChat(newChat);
    } catch (e) {
      print('Error creating chat: $e');
      Get.snackbar('Error', 'Failed to start chat');
    }
  }

  Future<ChatModel?> _findExistingChat(String otherUserId) async {
    try {
      final querySnapshot = await FirebaseService.firestore
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .get();

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participants'] ?? []);
        if (participants.contains(otherUserId)) {
          return ChatModel.fromFirestore(doc);
        }
      }
      return null;
    } catch (e) {
      print('Error finding existing chat: $e');
      return null;
    }
  }

  Future<void> _createWelcomeMessage(String chatId, String otherUserName) async {
    try {
      final welcomeMessage = MessageModel(
        id: '',
        chatId: chatId,
        senderId: currentUserId,
        receiverId: '', // Will be set based on chat participants
        text: 'Hello! I would like to chat with you about your trip.',
        timestamp: DateTime.now(),
        type: MessageType.text,
        read: false,
      );

      await FirebaseService.firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(welcomeMessage.toMap());
    } catch (e) {
      print('Error creating welcome message: $e');
    }
  }

  // Method to update user online status
  Future<void> updateUserOnlineStatus(bool isOnline) async {
    try {
      final currentUserId = FirebaseService.currentUserId;
      if (currentUserId == null) return;

      // Update all chats where this user is a participant
      final querySnapshot = await FirebaseService.firestore
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .get();

      final batch = FirebaseService.firestore.batch();

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final isDriver = data['driverId'] == currentUserId;

        batch.update(doc.reference, {
          isDriver ? 'driverOnline' : 'passengerOnline': isOnline,
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error updating online status: $e');
    }
  }
}