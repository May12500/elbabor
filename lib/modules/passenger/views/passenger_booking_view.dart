import 'package:elbabor/app/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../booking/widgets/booking_card_widget.dart';
import '../viewmodels/passenger_booking_viewmodel.dart';

class PassengerBookingView extends GetView<PassengerBookingViewModel> {
  const PassengerBookingView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('my_bookings'.tr, style: AppTextStyles.heading.copyWith(color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.bookings.isEmpty) {
          return const CustomLoader();
        }

        if (controller.combinedBookings.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            _buildHeaderStats(),
            _buildFilterBar(),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                backgroundColor: AppColors.primary,
                color: Colors.white,
                onRefresh: controller.refreshData, // Use the new refresh method
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: controller.combinedBookings.length,
                  itemBuilder: (context, index) {
                    final bookingGroup = controller.combinedBookings[index];
                    return BookingCard(bookingGroup: bookingGroup);
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.airline_seat_recline_normal,
            size: 80,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Text(
            'no_bookings_found'.tr,
            style: AppTextStyles.heading.copyWith(
              color: AppColors.textSecondary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'book_your_first_trip'.tr,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              controller.applyFilter('All');
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('explore_trips'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStats() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.confirmation_number,
            'total_bookings'.tr,
            controller.totalBookings.toString(),
            subtitle: 'active'.tr, // Clarify these are active bookings
          ),
          _buildStatItem(
            Icons.pending_actions,
            'pending'.tr,
            controller.pendingCount.toString(),
          ),
          _buildStatItem(
            Icons.check_circle,
            'confirmed'.tr,
            controller.confirmedCount.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, {String? subtitle}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: controller.filters.length,
        itemBuilder: (context, index) {
          final filter = controller.filters[index];
          final isSelected = controller.selectedFilter.value == filter;

          return GestureDetector(
            onTap: () => controller.applyFilter(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                )
                    : null,
                color: isSelected ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Text(
                filter.tr,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}