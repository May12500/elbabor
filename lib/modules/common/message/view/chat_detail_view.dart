import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../app/themes/app_text_styles.dart';
import '../../../../data/services/firebase_service.dart';
import '../model/chat_model.dart';
import '../model/message_model.dart';
import '../viewmodels/chat_detail_viewmodel.dart';

class ChatDetailView extends GetView<ChatDetailViewModel> {
  const ChatDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final chat = Get.arguments as ChatModel;
    final controller = Get.put(ChatDetailViewModel(chat));

    return Scaffold(
      backgroundColor: const Color(0xFFE5DDD5),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 1,
        leading:Container(
          margin: const EdgeInsets.all(8), // Move slightly left
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        title: Row(
          children: [
            GestureDetector(
              onTap: () => _viewUserProfile(chat.otherUser),
              child: CircleAvatar(
                radius: 18,backgroundColor:Colors.white.withOpacity(0.15) ,
                backgroundImage: chat.otherUser.photoUrl != null
                    ? NetworkImage(chat.otherUser.photoUrl!)
                    : null,
                child: chat.otherUser.photoUrl == null
                    ? const Icon(Icons.person, size: 18, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _viewUserProfile(chat.otherUser),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.otherUser.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Obx(() {
                      final isOnline = controller.isOtherUserOnline.value;
                      final lastSeen = controller.lastSeen.value;
                      final lastSeenText = controller.lastSeenText;

                      return Text(
                        // isOnline
                        //     ? 'online'.tr
                        //     : lastSeen != null
                        //     ? 'last_seen'.tr + ' ' + _formatLastSeen(lastSeen)
                        //     : chat.otherUser.role,
                        controller.isOtherUserOnline.value ? 'Online' : controller.lastSeenText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Colors.white
                        ),
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          Visibility(
            visible: false,
            child: Container(
              margin: const EdgeInsets.all(8), // Move slightly left
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                ),
              child: IconButton(
                icon: const Icon(Icons.videocam, size: 22,color: Colors.white,),
                onPressed: () => _initiateVideoCall(chat),
                tooltip: 'video_call'.tr,
              ),
            ),
          ),
          Visibility(
            visible: false,
            child: Container(
              margin: const EdgeInsets.all(8), // Move slightly left
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.call, size: 22,color: Colors.white,),
                onPressed: () => _initiateVoiceCall(chat),
                tooltip: 'voice_call'.tr,
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 22,color: Colors.white,),
            onSelected: (value) => _handleMenuSelection(value, controller, chat),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'view_profile',
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 20),
                    const SizedBox(width: 8),
                    Text('view_profile'.tr),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'media',
                child: Row(
                  children: [
                    const Icon(Icons.photo_library, size: 20),
                    const SizedBox(width: 8),
                    Text('view_media'.tr),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'clear_chat',
                child: Row(
                  children: [
                    const Icon(Icons.delete, size: 20, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('clear_chat'.tr),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    const Icon(Icons.block, size: 20, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('block_user'.tr),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat info banner for trips
          if (chat.tripId != null) _buildTripInfoBanner(chat),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return Column(
                children: [
                  // Encryption notice
                  _buildEncryptionNotice(),

                  Expanded(
                    child: ListView.builder(
                      reverse: false,
                      padding: const EdgeInsets.all(8),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final message = controller.messages[index];
                        final showDate = _shouldShowDate(controller.messages, index);
                        final showTime = _shouldShowTime(controller.messages, index);

                        return Column(
                          children: [
                            if (showDate) _buildDateSeparator(message.timestamp),
                            _buildMessageBubble(message, controller, showTime: showTime),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
          _buildMessageInput(controller),
        ],
      ),
    );
  }

  Widget _buildTripInfoBanner(ChatModel chat) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.directions_car, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'trip_chat_info'.tr,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _viewTripDetails(chat.tripId!),
            child: Text(
              'view_trip'.tr,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEncryptionNotice() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            'messages_are_encrypted'.tr,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, ChatDetailViewModel controller, {bool showTime = true}) {
    final isMe = message.senderId == FirebaseService.currentUserId;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: message.senderPhotoUrl != null
                  ? NetworkImage(message.senderPhotoUrl!)
                  : null,
              child: message.senderPhotoUrl == null
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(8),
                      topRight: const Radius.circular(8),
                      bottomLeft: isMe ? const Radius.circular(8) : const Radius.circular(2),
                      bottomRight: isMe ? const Radius.circular(2) : const Radius.circular(8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                      if (showTime)
                        const SizedBox(height: 2),
                    ],
                  ),
                ),
                if (showTime)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, right: 4, left: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(message.timestamp),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          _buildMessageStatus(message),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 4),
            CircleAvatar(
              radius: 16,
              backgroundImage: FirebaseService.currentUser?.photoURL != null
                  ? NetworkImage(FirebaseService.currentUser!.photoURL!)
                  : null,
              child: FirebaseService.currentUser?.photoURL == null
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageStatus(MessageModel message) {
    if (message.read) {
      return const Icon(
        Icons.done_all,
        size: 14,
        color: Colors.blue,
      );
    } else if (message.delivered) {
      return const Icon(
        Icons.done_all,
        size: 14,
        color: Colors.grey,
      );
    } else {
      return const Icon(
        Icons.done,
        size: 14,
        color: Colors.grey,
      );
    }
  }

  Widget _buildDateSeparator(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatDate(date),
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black54,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'today'.tr;
    } else if (messageDate == yesterday) {
      return 'yesterday'.tr;
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  bool _shouldShowDate(List<MessageModel> messages, int index) {
    if (index == 0) return true;

    final currentDate = DateTime(
      messages[index].timestamp.year,
      messages[index].timestamp.month,
      messages[index].timestamp.day,
    );
    final previousDate = DateTime(
      messages[index - 1].timestamp.year,
      messages[index - 1].timestamp.month,
      messages[index - 1].timestamp.day,
    );

    return currentDate != previousDate;
  }

  bool _shouldShowTime(List<MessageModel> messages, int index) {
    if (index == messages.length - 1) return true;

    final currentTime = messages[index].timestamp;
    final nextTime = messages[index + 1].timestamp;
    final timeDiff = nextTime.difference(currentTime).inMinutes;

    return timeDiff > 5 ||
        messages[index].senderId != messages[index + 1].senderId;
  }

  Widget _buildMessageInput(ChatDetailViewModel controller) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Emoji Button
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
            onPressed: () => Get.snackbar('Emoji', 'Emoji picker coming soon!'),
          ),

          // Attachment Button
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.grey),
            onPressed: () => _showAttachmentOptions(controller),
          ),

          // Message Input
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 100,
              ),
              child: TextField(
                controller: controller.messageController,
                maxLines: null,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: 'type_message'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => controller.sendMessage(),
              ),
            ),
          ),

          // Send Button
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: controller.sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions(ChatDetailViewModel controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.green),
              title: Text('photo_gallery'.tr),
              onTap: () {
                Get.back();
                Get.snackbar('Gallery', 'Photo picker coming soon!');
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: Text('camera'.tr),
              onTap: () {
                Get.back();
                Get.snackbar('Camera', 'Camera feature coming soon!');
              },
            ),
            ListTile(
              leading: const Icon(Icons.place, color: Colors.red),
              title: Text('location'.tr),
              onTap: () {
                Get.back();
                Get.snackbar('Location', 'Location sharing coming soon!');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearChatDialog(ChatDetailViewModel controller) {
    Get.dialog(
      AlertDialog(
        title: Text('clear_chat'.tr),
        content: Text('clear_chat_confirmation'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearChat();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('clear'.tr),
          ),
        ],
      ),
    );
  }

  void _showBlockUserDialog(ChatDetailViewModel controller) {
    Get.dialog(
      AlertDialog(
        title: Text('block_user'.tr),
        content: Text('block_user_confirmation'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.blockUser();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('block'.tr),
          ),
        ],
      ),
    );
  }
  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'just_now'.tr;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${'minutes_ago'.tr}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${'hours_ago'.tr}';
    } else {
      return DateFormat('MMM dd').format(lastSeen);
    }
  }

  void _viewUserProfile(ChatUser user) {
    if (user.role == 'Driver') {
      // Navigate to driver profile
      // Get.toNamed(Routes.DRIVER_PROFILE, arguments: user.id);
    } else {
      // Navigate to passenger profile
      // Get.toNamed(Routes.PASSENGER_PROFILE, arguments: user.id);
    }
  }

  void _initiateVideoCall(ChatModel chat) {
    Get.snackbar('Video Call', 'Calling ${chat.otherUser.name}...');
    // Implement video call functionality
  }

  void _initiateVoiceCall(ChatModel chat) {
    Get.snackbar('Voice Call', 'Calling ${chat.otherUser.name}...');
    // Implement voice call functionality
  }

  void _viewTripDetails(String tripId) {
    // Navigate to trip details
    // Get.toNamed(Routes.TRIP_DETAILS, arguments: tripId);
  }

  void _handleMenuSelection(String value, ChatDetailViewModel controller, ChatModel chat) {
    switch (value) {
      case 'view_profile':
        _viewUserProfile(chat.otherUser);
        break;
      case 'media':
        Get.snackbar('Media', 'Media gallery coming soon!');
        break;
      case 'clear_chat':
        _showClearChatDialog(controller);
        break;
      case 'block':
        _showBlockUserDialog(controller);
        break;
    }
  }
}