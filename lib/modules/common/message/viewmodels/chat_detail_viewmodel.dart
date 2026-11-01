import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/services/firebase_service.dart';
import '../model/chat_model.dart';
import '../model/message_model.dart';

class ChatDetailViewModel extends GetxController {
  final ChatModel chat;
  final messages = <MessageModel>[].obs;
  final messageController = TextEditingController();
  final isLoading = false.obs;
  final isOtherUserOnline = false.obs;
  final lastSeen = Rx<DateTime?>(null); // Add this line

  ChatDetailViewModel(this.chat);

  @override
  void onInit() {
    super.onInit();
    _loadMessages();
    _setupMessagesListener();
    _markMessagesAsRead();
    _setupUserPresence();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  bool get isDriver => FirebaseService.currentUserId == chat.driverId;

  // Get the other user's ID
  String get otherUserId => isDriver ? chat.passengerId : chat.driverId;

  Future<void> _loadMessages() async {
    try {
      isLoading.value = true;
      final querySnapshot = await FirebaseService.firestore
          .collection('chats')
          .doc(chat.id)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .limit(100)
          .get();

      final messageList = querySnapshot.docs.map((doc) {
        return MessageModel.fromFirestore(doc);
      }).toList();

      messages.assignAll(messageList);
    } catch (e) {
      print('Error loading messages: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _setupMessagesListener() {
    FirebaseService.firestore
        .collection('chats')
        .doc(chat.id)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final message = MessageModel.fromFirestore(change.doc);
          if (!messages.any((m) => m.id == message.id)) {
            messages.add(message);

            if (message.senderId == FirebaseService.currentUserId && !message.delivered) {
              _markMessageAsDelivered(message.id);
            }

            if (message.senderId != FirebaseService.currentUserId && !message.read) {
              _markMessageAsRead(message.id);
            }
          }
        }
      }
    });
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    try {
      final message = MessageModel(
        id: '',
        chatId: chat.id,
        senderId: FirebaseService.currentUserId!,
        receiverId: otherUserId,
        text: text,
        timestamp: DateTime.now(),
        type: MessageType.text,
        read: false,
        delivered: false,
      );

      await FirebaseService.firestore
          .collection('chats')
          .doc(chat.id)
          .collection('messages')
          .add(message.toMap());

      await FirebaseService.firestore
          .collection('chats')
          .doc(chat.id)
          .update({
        'lastMessage': text,
        'lastMessageTime': Timestamp.now(),
        'unreadCount': FieldValue.increment(1),
      });

      messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar('Error', 'Failed to send message');
    }
  }

  Future<void> _markMessageAsDelivered(String messageId) async {
    await FirebaseService.firestore
        .collection('chats')
        .doc(chat.id)
        .collection('messages')
        .doc(messageId)
        .update({'delivered': true});
  }

  Future<void> _markMessageAsRead(String messageId) async {
    await FirebaseService.firestore
        .collection('chats')
        .doc(chat.id)
        .collection('messages')
        .doc(messageId)
        .update({'read': true});
  }

  Future<void> _markMessagesAsRead() async {
    final unreadMessages = messages.where((m) =>
    m.senderId != FirebaseService.currentUserId && !m.read);

    for (final message in unreadMessages) {
      await _markMessageAsRead(message.id);
    }

    await FirebaseService.firestore
        .collection('chats')
        .doc(chat.id)
        .update({
      'unreadCount': 0,
    });
  }

  void _setupUserPresence() {
    // Listen to the other user's presence status
    FirebaseService.firestore
        .collection('users')
        .doc(otherUserId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();

        // Update online status
        final isOnline = data?['isOnline'] ?? false;
        isOtherUserOnline.value = isOnline;

        // Update last seen timestamp
        final lastSeenTimestamp = data?['lastSeen'];
        if (lastSeenTimestamp != null) {
          lastSeen.value = (lastSeenTimestamp as Timestamp).toDate();
        }
      }
    });
  }

  // Helper method to format last seen time for display
  String get lastSeenText {
    if (isOtherUserOnline.value) {
      return 'Online';
    }

    if (lastSeen.value == null) {
      return 'Offline';
    }

    final now = DateTime.now();
    final difference = now.difference(lastSeen.value!);

    if (difference.inMinutes < 1) {
      return 'Last seen just now';
    } else if (difference.inMinutes < 60) {
      return 'Last seen ${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return 'Last seen ${difference.inHours} hours ago';
    } else {
      return 'Last seen ${difference.inDays} days ago';
    }
  }

  Future<void> clearChat() async {
    try {
      final messagesSnapshot = await FirebaseService.firestore
          .collection('chats')
          .doc(chat.id)
          .collection('messages')
          .get();

      final batch = FirebaseService.firestore.batch();
      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      await FirebaseService.firestore
          .collection('chats')
          .doc(chat.id)
          .update({
        'lastMessage': 'Chat cleared',
        'lastMessageTime': Timestamp.now(),
        'unreadCount': 0,
      });

      messages.clear();
      Get.snackbar('Success', 'Chat cleared successfully');
    } catch (e) {
      print('Error clearing chat: $e');
      Get.snackbar('Error', 'Failed to clear chat');
    }
  }

  Future<void> blockUser() async {
    Get.snackbar('Blocked', 'User has been blocked');
  }
}