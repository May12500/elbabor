import 'package:elbabor/modules/common/message/view/message_tab_view.dart';
import 'package:elbabor/modules/common/message/viewmodels/message_tab_viewmodel.dart';
import 'package:elbabor/modules/common/profile/view/profile_view.dart';
import 'package:elbabor/modules/common/profile/viewmodel/profile_viewmodel.dart';
import 'package:elbabor/modules/driver/trip_managment/views/trip_management_view.dart';
import 'package:elbabor/modules/home/views/tabs/driver_messages_tab.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../driver/home/views/driver_home_tab.dart';
import '../../driver/trip_managment/viewmodels/trip_management_viewmodel.dart';
import '../viewmodels/driver_dashboard_viewmodel.dart';

class DriverDashboardView extends GetView<DriverDashboardViewModel> {
  const DriverDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(TripManagementViewModel());
    Get.put(ProfileViewModel());
    Get.put(MessagesViewModel());

    return Obx(() {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: [
            DriverHomeTab(),
            TripManagementView(),
            MessagesTab(),
            ProfileView(),
          ],
        ),
        bottomNavigationBar: _buildModernBottomNavBar(),
      );
    });
  }

  Widget _buildModernBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: IntrinsicHeight(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'home'.tr,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.directions_car_outlined,
                  activeIcon: Icons.directions_car_rounded,
                  label: 'my_trips'.tr,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.chat_bubble_outline_rounded,
                  activeIcon: Icons.chat_bubble_rounded,
                  label: 'messages'.tr,
                  showBadge: controller.hasUnreadMessages.value,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'profile'.tr,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    bool showBadge = false,
  }) {
    final isActive = controller.currentIndex.value == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => controller.changeTab(index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    // Icon Container with Animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary.withOpacity(0.15)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isActive ? activeIcon : icon,
                        color: isActive ? AppColors.primary : AppColors.textSecondary,
                        size: isActive ? 22 : 20,
                      ),
                    ),

                    // Notification Badge
                    if (showBadge && !isActive)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 4),

                // Label with Animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: isActive ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      fontSize: isActive ? 11 : 10,
                      height: 1.0, // Fixed height to prevent overflow
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBottomNavBar() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 25,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFloatingNavItem(
              index: 0,
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'home'.tr,
            ),
            _buildFloatingNavItem(
              index: 1,
              icon: Icons.directions_car_outlined,
              activeIcon: Icons.directions_car_rounded,
              label: 'my_trips'.tr,
            ),
            _buildFloatingNavItem(
              index: 2,
              icon: Icons.chat_bubble_outline_rounded,
              activeIcon: Icons.chat_bubble_rounded,
              label: 'messages'.tr,
              showBadge: controller.hasUnreadMessages.value,
            ),
            _buildFloatingNavItem(
              index: 3,
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'profile'.tr,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    bool showBadge = false,
  }) {
    final isActive = controller.currentIndex.value == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => controller.changeTab(index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background Circle for Active State
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isActive ? 40 : 0,
                      height: isActive ? 40 : 0,
                      decoration: BoxDecoration(
                        gradient: isActive
                            ? LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                            : null,
                        shape: BoxShape.circle,
                        boxShadow: isActive
                            ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                            : null,
                      ),
                    ),

                    // Icon
                    Icon(
                      isActive ? activeIcon : icon,
                      color: isActive ? Colors.white : AppColors.textSecondary,
                      size: isActive ? 20 : 22,
                    ),

                    // Notification Badge
                    if (showBadge && !isActive)
                      Positioned(
                        right: 8,
                        top: 4,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 4),

                // Label
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: isActive ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}