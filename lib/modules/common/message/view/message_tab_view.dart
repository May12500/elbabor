import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../app/themes/app_text_styles.dart';
import '../../../../app/widgets/custom_loader.dart';
import '../model/chat_model.dart';
import '../viewmodels/message_tab_viewmodel.dart';

class MessagesTab extends GetView<MessagesViewModel> {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Custom App Bar
          _buildCustomAppBar(),
          // Filter Chips
          _buildFilterChips(),
          // Chat List
          Expanded(child: _buildChatList()),
        ],
      ),
      // Floating Action Button for new message
      // floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 16,
        bottom: 16,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'messages'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.search_rounded, color: Colors.white),
                  onPressed: controller.searchChats,
                  tooltip: 'search_messages'.tr,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
            '${controller.totalUnreadCount.value} ${'unread_messages'.tr}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
          children: [
            _buildFilterChip('all'.tr, controller.selectedFilter.value == 'all',
                    () => controller.applyFilter('all'), Icons.all_inbox_rounded),
            _buildFilterChip('unread'.tr, controller.selectedFilter.value == 'unread',
                    () => controller.applyFilter('unread'), Icons.mark_chat_unread_rounded),
            _buildFilterChip('trips'.tr, controller.selectedFilter.value == 'trips',
                    () => controller.applyFilter('trips'), Icons.directions_car_rounded),
            if (controller.isDriver) ...[
              _buildFilterChip('passengers'.tr, controller.selectedFilter.value == 'passengers',
                      () => controller.applyFilter('passengers'), Icons.people_rounded),
            ] else ...[
              _buildFilterChip('drivers'.tr, controller.selectedFilter.value == 'drivers',
                      () => controller.applyFilter('drivers'), Icons.local_taxi_rounded),
            ],
          ],
        )),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap, IconData icon) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: selected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        elevation: selected ? 2 : 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 0 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// In your MessagesTab, update the _buildChatList method:
  Widget _buildChatList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CustomLoader());
      }

      final filteredChats = controller.filteredChats; // Use filtered chats

      if (filteredChats.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        backgroundColor: AppColors.background,
        color: AppColors.primary,
        onRefresh: controller.loadChats,
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: filteredChats.length,
          itemBuilder: (context, index) {
            final chat = filteredChats[index];
            return _buildChatItem(chat, index);
          },
        ),
      );
    });
  }

  Widget _buildChatItem(ChatModel chat, int index) {
    final otherUser = chat.otherUser;
    final lastMessageTime = _formatTime(chat.lastMessageTime);
    final hasUnread = chat.unreadCount > 0;
    final isOnline = chat.otherUser.isOnline ?? false;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200 + (index * 50)),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, controller.isLoading.value ? 50 : 0, 0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => controller.openChat(chat),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with Online Status
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.15),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: otherUser.photoUrl != null
                            ? Image.network(
                          otherUser.photoUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: AppColors.primary.withOpacity(0.1),
                              child: Icon(Icons.person, color: AppColors.primary),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.primary.withOpacity(0.1),
                              child: Icon(Icons.person, color: AppColors.primary),
                            );
                          },
                        )
                            : Container(
                          color: AppColors.primary.withOpacity(0.1),
                          child: Icon(Icons.person_rounded, color: AppColors.primary, size: 24),
                        ),
                      ),
                    ),
                    // Online Status Indicator
                    if (isOnline)
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // Chat Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            otherUser.name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            lastMessageTime,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.lastMessage,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: hasUnread ? AppColors.textPrimary : AppColors.textSecondary,
                                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasUnread) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Trip Info if available
                      if (chat.tripInfo != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.directions_car_rounded, size: 12, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                '${chat.tripInfo!['from']} → ${chat.tripInfo!['to']}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 60,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'no_messages'.tr,
              style: AppTextStyles.heading.copyWith(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              controller.isDriver
                  ? 'no_messages_driver_desc'.tr
                  : 'no_messages_passenger_desc'.tr,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: (){
                // controller.findUsersToMessage();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_comment_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'start_chatting'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: controller.findUsersToMessage,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.chat_rounded, size: 24),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'yesterday'.tr;
    } else if (now.difference(messageDate).inDays < 7) {
      return DateFormat('EEEE').format(dateTime);
    } else {
      return DateFormat('dd/MM').format(dateTime);
    }
  }
}