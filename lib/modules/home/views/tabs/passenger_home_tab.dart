import 'package:carousel_slider/carousel_slider.dart';
import 'package:elbabor/data/services/currency_service.dart';
import 'package:elbabor/modules/common/message/viewmodels/message_tab_viewmodel.dart';
import 'package:elbabor/modules/home/viewmodels/passenger_dashboard_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../app/themes/app_text_styles.dart';
import '../../../../app/widgets/custom_button.dart';
import '../../../../app/widgets/custom_loader.dart';
import '../../../../data/services/firebase_service.dart';
import '../../../../data/models/trip_model.dart';
import '../../viewmodels/tabs/passenger_home_viewmodel.dart';

class PassengerHomeTab extends GetView<PassengerHomeViewModel> {
  const PassengerHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PassengerHomeViewModel());

    final userId = FirebaseService.currentUserId;

    if (userId == null) {
      return CustomLoader(message: "user_not_logged".tr);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.hasLoaded) controller.fetchHomeData(userId);
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // Status bar background
            Container(
              color: AppColors.primary,
              height: MediaQuery.of(context).padding.top,
            ),
            // Main content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CustomLoader());
                }

                final trips = controller.recommendedTrips;
                final upcomingTrips = controller.upcomingTrips;
                final popularRoutes = controller.popularRoutes;

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildHeaderSection(),
                    ),
                    SliverToBoxAdapter(
                      child: _buildQuickStats(controller),
                    ),
                    if (trips.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _buildRecommendedTrips(trips),
                      ),
                    if (popularRoutes.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _buildPopularRoutes(popularRoutes),
                      ),
                    if (upcomingTrips.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _buildUpcomingTrips(upcomingTrips, controller),
                      ),
                    SliverToBoxAdapter(
                      child: _buildFindTripButton(controller),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 20),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Message Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.currentGreeting.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "passenger_home_title".tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rating notification badge
                  if (controller.hasPendingRatings) ...[
                    GestureDetector(
                      onTap: () {
                        if (controller.currentRatingPrompt.value != null) {
                          controller.showRatingDialog(controller.currentRatingPrompt.value!);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.warning.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Badge(
                          smallSize: 8,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.star_rate_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],

                  // Notification Bell Button with live unread badge
                  Obx(() {
                    final messagesVm = Get.isRegistered<MessagesViewModel>()
                        ? Get.find<MessagesViewModel>()
                        : Get.put(MessagesViewModel());
                    final unreadCount = messagesVm.totalUnreadCount.value;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Badge(
                          isLabelVisible: unreadCount > 0,
                          label: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: AppColors.error,
                          child: Icon(
                            unreadCount > 0
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_none_rounded,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          if (Get.isRegistered<PassengerDashboardViewModel>()) {
                            Get.find<PassengerDashboardViewModel>().changeTab(2);
                          }
                        },
                        tooltip: 'notifications'.tr,
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search Bar
          GestureDetector(
            onTap: controller.onSearchTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'search_trip_placeholder'.tr,
                    style: AppTextStyles.body.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.tune, color: AppColors.primary, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(PassengerHomeViewModel controller) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.confirmation_number,
            value: controller.totalBookings.toString(),
            label: 'total_bookings'.tr,
            color: Colors.blue,
          ),
          _buildStatItem(
            icon: Icons.upcoming,
            value: controller.upcomingTrips.length.toString(),
            label: 'upcoming'.tr,
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.star,
            value: controller.completedTrips.toString(),
            label: 'completed'.tr,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String value, required String label, required Color color}) {
    return Column(
      children: [
        Container(
