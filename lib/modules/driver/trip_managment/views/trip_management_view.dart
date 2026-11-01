import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../app/themes/app_colors.dart';
import '../../../../../app/themes/app_text_styles.dart';
import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/widgets/custom_loader.dart';
import '../../../../../data/services/firebase_service.dart';
import '../../../../app/widgets/custom_button.dart';
import '../../../../data/services/currency_service.dart';
import '../../../../data/models/trip_model.dart';
import '../viewmodels/trip_management_viewmodel.dart';

class TripManagementView extends GetView<TripManagementViewModel> {
  const TripManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final driverId = FirebaseService.currentUserId;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (driverId != null && !controller.hasLoaded) {
        await controller.fetchDriverTrips(driverId);
      }
    });

    if (driverId == null) {
      return CustomLoader(message: "driver_not_logged".tr);
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          "my_trips".tr,
          style: AppTextStyles.heading.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textWhite
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8), // Move slightly left
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_outlined, color: Colors.white,size: 22,),
              onPressed: () => controller.refreshTrips(),
              tooltip: 'refresh'.tr,
            ),
          ),

        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Stats Overview
            _buildStatsOverview(),
            const SizedBox(height: 16),
      
            // Tab Bar
            _buildTabBar(),
            const SizedBox(height: 8),
      
            // Tab Content
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            count: controller.activeTrips.length,
            label: "active_trips".tr,
            color: AppColors.success,
          ),
          _buildStatItem(
            count: controller.pastTrips.length,
            label: "past_trips".tr,
            color: AppColors.info,
          ),
          _buildStatItem(
            count: controller.activeTrips.length + controller.pastTrips.length,
            label: "total_trips".tr,
            color: AppColors.primary,
          ),
        ],
      )),
    );
  }

  Widget _buildStatItem({
    required int count,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            count.toString(),
            style: AppTextStyles.heading.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.directions_car, size: 18),
                const SizedBox(width: 6),
                Text("active_trips".tr),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history, size: 18),
                const SizedBox(width: 6),
                Text("past_trips".tr),
              ],
            ),
          ),
        ],
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      children: [
        _buildTripList(controller.activeTrips, isActive: true),
        _buildTripList(controller.pastTrips, isActive: false),
      ],
    );
  }

  Widget _buildTripList(RxList<TripModel> trips, {required bool isActive}) {
    return Obx(() {
      if (trips.isEmpty) {
        return _buildEmptyState(isActive: isActive);
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshTrips(),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: trips.length,
          separatorBuilder: (_, index) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            final trip = trips[index];
            return _buildTripCard(trip, isActive: isActive);
          },
        ),
      );
    });
  }

  Widget _buildTripCard(TripModel trip, {required bool isActive}) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    // Check if trip is expired
    final isExpired = controller.isTripExpired(trip);
    final displayStatus = isExpired ? 'expired' : trip.status;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.toNamed(Routes.TRIP_DETAIL, arguments: trip),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Vehicle Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getVehicleColor(trip.vehicleType).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getVehicleIcon(trip.vehicleType),
                        color: _getVehicleColor(trip.vehicleType),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Route Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${trip.fromCity} → ${trip.destinationCity}",
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${dateFormat.format(trip.dateTime)} • ${timeFormat.format(trip.dateTime)}",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isExpired ? AppColors.error : AppColors.textSecondary,
                            ),
                          ),
                          if (isExpired)
                            Text(
                              "Trip expired",
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(trip.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        trip.status.tr.capitalizeFirst!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: _getStatusColor(trip.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Trip Details Row
                Row(
                  children: [
                    _buildDetailChip(
                      icon: Icons.event_seat_outlined,
                      text: "${trip.seatsAvailable} ${'seats'.tr}",
                    ),
                    const SizedBox(width: 8),
                    _buildDetailChip(
                      icon: Icons.money,
                      text: CurrencyService.instance.formatPrice(trip.pricePerPassenger),
                    ),
                    const SizedBox(width: 8),
                    _buildDetailChip(
                      icon: Icons.payment_outlined,
                      text: trip.paymentMethodsDisplay,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.remove_red_eye_outlined,
                        text: "view_details".tr,
                        color: AppColors.primary,
                        onTap: () => Get.toNamed(Routes.TRIP_DETAIL, arguments: trip),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isActive && trip.status == 'draft')
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.edit_outlined,
                          text: "edit".tr,
                          color: AppColors.warning,
                          onTap: () => _editTrip(trip),
                        ),
                      ),
                    if (isActive && trip.status == 'draft')
                      const SizedBox(width: 8),
                    if (isActive)
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.delete_outline,
                          text: "delete".tr,
                          color: AppColors.error,
                          onTap: () => _showDeleteDialog(trip),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                text,
                style: AppTextStyles.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({required bool isActive}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActive ? Icons.directions_car_outlined : Icons.history_outlined,
            size: 64,
            color: AppColors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isActive ? "no_active_trips".tr : "no_past_trips".tr,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isActive ? "create_first_trip".tr : "completed_trips_appear_here".tr,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          if (isActive) ...[
            const SizedBox(height: 20),
            CustomButton(
              text: "create_trip".tr,
              onPressed: () => Get.toNamed(Routes.DRIVER_CREATE_TRIP),
              isFullWidth: false,
            ),
          ],
        ],
      ),
    );
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'ferry':
        return Icons.directions_boat;
      case 'bus':
        return Icons.directions_bus;
      case 'train':
        return Icons.train;
      case 'airplane':
        return Icons.flight_takeoff;
      default:
        return Icons.directions_car;
    }
  }

  Color _getVehicleColor(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'ferry':
        return Colors.blueAccent;
      case 'bus':
        return Colors.orangeAccent;
      case 'train':
        return Colors.green;
      case 'airplane':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
      case 'scheduled':
        return AppColors.success;
      case 'draft':
        return AppColors.warning;
      case 'completed':
        return AppColors.info;
      case 'expired':
        return AppColors.error;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  void _editTrip(TripModel trip) {
    // Navigate to edit trip screen
    Get.snackbar(
      "coming_soon".tr,
      "edit_feature_coming_soon".tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showDeleteDialog(TripModel trip) {
    Get.dialog(
      AlertDialog(
        title: Text("delete_trip".tr),
        content: Text("delete_trip_confirmation".tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("cancel".tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteTrip(trip.id);
            },
            child: Text(
              "delete".tr,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}