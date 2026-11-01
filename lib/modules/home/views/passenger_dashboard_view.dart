import 'package:elbabor/modules/common/message/viewmodels/message_tab_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../common/message/view/message_tab_view.dart';
import '../../common/profile/view/profile_view.dart';
import '../../common/profile/viewmodel/profile_viewmodel.dart';
import '../../passenger/viewmodels/passenger_booking_viewmodel.dart';
import '../../passenger/views/passenger_booking_view.dart';
import '../viewmodels/passenger_dashboard_viewmodel.dart';
import 'tabs/passenger_home_tab.dart';

class PassengerDashboardView extends GetView<PassengerDashboardViewModel> {
  const PassengerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PassengerDashboardViewModel());
    Get.put(PassengerBookingViewModel());
    Get.put(ProfileViewModel());
    Get.put(MessagesViewModel());

    return Obx(() {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: [
            const PassengerHomeTab(),
            PassengerBookingView(),
            const MessagesTab(),
            const ProfileView(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: 'home'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.directions_car_outlined),
              activeIcon: const Icon(Icons.directions_car),
              label: 'my_bookings'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat_bubble_outline),
              activeIcon: const Icon(Icons.chat_bubble),
              label: 'messages'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: 'profile'.tr,
            ),
          ],
        ),
      );
    });
  }
}
