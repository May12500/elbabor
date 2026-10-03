import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbabor/data/services/firebase_service.dart';

class ChatModel {
  final String id;
  final String driverId;
  final String passengerId;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final DateTime createdAt;
  final String? tripId;
  final ChatUser otherUser;
  final Map<String, dynamic>? tripInfo; // Added tripInfo property

  ChatModel({
    required this.id,
    required this.driverId,
    required this.passengerId,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.createdAt,
    this.tripId,
    required this.otherUser,
    this.tripInfo, // Added to constructor
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final currentUserId = FirebaseService.currentUserId;

    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    // Get both user IDs from the chat
    final driverId = data['driverId'] ?? '';
    final passengerId = data['passengerId'] ?? '';

    // Determine which user is the "other user" (not the current user)
    String otherUserId;
    String otherUserName;
    String otherUserRole;
    String? otherUserPhotoUrl;
    bool? isOnline; // Added online status

    if (currentUserId == driverId) {
      // Current user is driver, so other user is passenger
      otherUserId = passengerId;
      otherUserName = data['passengerName'] ?? 'Passenger';
      otherUserRole = 'Passenger';
      otherUserPhotoUrl = data['passengerPhotoUrl'];
    } else if (currentUserId == passengerId) {
      // Current user is passenger, so other user is driver
      otherUserId = driverId;
      otherUserName = data['driverName'] ?? 'Driver';
      otherUserRole = 'Driver';
      otherUserPhotoUrl = data['driverPhotoUrl'];
    } else {
      // Fallback - this shouldn't happen normally
      otherUserId = currentUserId == driverId ? passengerId : driverId;
      otherUserName = 'Unknown User';
      otherUserRole = 'User';
      otherUserPhotoUrl = null;
    }

    // Extract trip info if available
    Map<String, dynamic>? tripInfo;
    if (data['tripId'] != null) {
      tripInfo = {
        'from': data['tripFrom'] ?? 'Unknown',
        'to': data['tripTo'] ?? 'Unknown',
        'date': data['tripDate'] != null ? (data['tripDate'] as Timestamp).toDate() : null,
      };
    }

    final otherUser = ChatUser(
      id: otherUserId,
      name: otherUserName,
      photoUrl: otherUserPhotoUrl,
      role: otherUserRole,
      isOnline: data['otherUserOnline'] ?? false, // Default to offline
    );

    return ChatModel(
      id: doc.id,
      driverId: driverId,
      passengerId: passengerId,
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      unreadCount: data['unreadCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      tripId: data['tripId'],
      otherUser: otherUser,
      tripInfo: tripInfo, // Added trip info
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'passengerId': passengerId,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'unreadCount': unreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'tripId': tripId,
      'driverName': isCurrentUserDriver ? 'You' : otherUser.name,
      'passengerName': isCurrentUserDriver ? otherUser.name : 'You',
      'driverPhotoUrl': isCurrentUserDriver ? null : otherUser.photoUrl,
      'passengerPhotoUrl': isCurrentUserDriver ? otherUser.photoUrl : null,
      'otherUserOnline': otherUser.isOnline, // Store online status
      // Store trip info if available
      if (tripInfo != null) ...{
        'tripFrom': tripInfo!['from'],
        'tripTo': tripInfo!['to'],
        'tripDate': tripInfo!['date'] != null ? Timestamp.fromDate(tripInfo!['date']) : null,
      },
    };
  }

  // Helper method to check if current user is driver in this chat
  bool get isCurrentUserDriver {
    return FirebaseService.currentUserId == driverId;
  }
}

class ChatUser {
  final String id;
  final String name;
  final String? photoUrl;
  final String role;
  final bool isOnline; // Added online status

  ChatUser({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.role,
    this.isOnline = false, // Default to offline
  });
}