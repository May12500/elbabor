import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final MessageType type;
  final bool read;
  final bool delivered;
  final String? senderPhotoUrl;
  final String? senderName;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.type = MessageType.text,
    this.read = false,
    this.delivered = false,
    this.senderPhotoUrl,
    this.senderName,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MessageModel(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: MessageType.values.firstWhere(
            (e) => e.name == data['type'],
        orElse: () => MessageType.text,
      ),
      read: data['read'] ?? false,
      delivered: data['delivered'] ?? false,
      senderPhotoUrl: data['senderPhotoUrl'],
      senderName: data['senderName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.name,
      'read': read,
      'delivered': delivered,
      'senderPhotoUrl': senderPhotoUrl,
      'senderName': senderName,
    };
  }
}

enum MessageType {
  text,
  image,
  location,
  system,
}