import 'package:elbabor/data/services/currency_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/themes/app_colors.dart';
import '../../../../../app/themes/app_text_styles.dart';
import '../../../../../app/widgets/custom_button.dart';
import '../../../../../app/widgets/custom_loader.dart';
import '../../../../../data/services/firebase_service.dart';
import '../../../../data/models/trip_model.dart';
import '../viewmodels/driver_home_viewmodel.dart';

class DriverHomeTab extends StatelessWidget {
  DriverHomeTab({super.key});

  final vm = Get.put(DriverHomeViewModel());

  @override
  Widget build(BuildContext context) {
    final driverId = FirebaseService.currentUserId;

    if (driverId == null) {
      return CustomLoader(message: "driver_not_logged".tr);
    }

    return Column(
      children: [
        // Enhanced Header Section
        _buildEnhancedHeader(),

        // Content Section
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => vm.refreshData(),
            backgroundColor: AppColors.background,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(left: 10,right: 10,bottom: 10,top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Quick Stats Cards
                  _buildEnhancedStatsGrid(),
                  const SizedBox(height: 24),

                  // Create Trip Button
                  _buildCreateTripButton(),
                  const SizedBox(height: 32),

                  // Active Trips Section
                  _buildEnhancedActiveTripsSection(),
                  const SizedBox(height: 24),

                  // Upcoming Trips Section
                  _buildEnhancedUpcomingTripsSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 16,
        bottom: 20,
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
          // Header Row
          Row(
            children: [
              // Profile and Welcome
              Expanded(
                child: Obx(() {
                  final driver = vm.driverProfile.value;
                  return Row(
                    children: [
                      // Profile Avatar
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: driver?.photoUrl != null
                              ? Image.network(
                            driver!.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.white.withOpacity(0.2),
                                child: Icon(Icons.person, color: Colors.white),
                              );
                            },
                          )
                              : Container(
                            color: Colors.white.withOpacity(0.2),
                            child: Icon(Icons.person_rounded, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Welcome Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vm.currentGreeting.value,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              driver?.name.split(' ').first ?? 'Driver',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),

              // Notification Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                  onPressed: () {
                    // Navigate to notifications
                    Get.snackbar(
                      "Notifications",
                      "Notifications feature coming soon!",
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  tooltip: 'notifications'.tr,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats Summary
          Obx(() {
            if (vm.statsLoading.value) {
              return SizedBox(
                height: 40,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeaderStatItem('today_trips'.tr, '${vm.todayTrips}'),
                _buildHeaderStatItem('completion_rate'.tr, '${vm.completionRate.toStringAsFixed(0)}%'),
                _buildHeaderStatItem('earnings'.tr, CurrencyService.instance.formatPrice(vm.totalEarnings)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeaderStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedStatsGrid() {
    return Obx(() {
      if (vm.statsLoading.value) {
        return SizedBox(
          height: 140,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }

      final driver = vm.driverProfile.value;
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
        children: [
          _buildEnhancedStatCard(
            icon: Icons.directions_car_rounded,
            title: 'today_trips'.tr,
            value: '${vm.todayTrips}',
            subtitle: 'trips_today'.tr,
            color: AppColors.primary,
          ),
          _buildEnhancedStatCard(
            icon: Icons.star_rounded,
            title: 'driver_rating'.tr,
            value: driver?.rating.toStringAsFixed(1) ?? '0.0',
            subtitle: 'average_rating'.tr,
            color: AppColors.info,
          ),
        ],
      );
    });
  }

  Widget _buildEnhancedStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 120, // Ensure minimum height
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(14), // Balanced padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top row with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),

          // Spacer to push content down
          const Spacer(),

          // Value
          Text(
            value,
            style: AppTextStyles.heading.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Title
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 2),

          // Subtitle
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCreateTripButton() {
    return CustomButton(
      text: 'create_new_trip'.tr,
      onPressed: () {
        Get.toNamed(Routes.DRIVER_CREATE_TRIP);
      },
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
      borderRadius: 16,
      hasShadow: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_rounded, size: 20, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'create_new_trip'.tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedActiveTripsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_car_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "active_trips".tr,
                style: AppTextStyles.subheading.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => vm.openAllActiveTrips() ,
                // onPressed: vm.activeTrips.isNotEmpty ? () => vm.openAllActiveTrips() : null,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: Text(
                  "view_all".tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (vm.isLoading.value) {
              return SizedBox(
                height: 80,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }
            final trips = vm.activeTrips.take(3).toList();
            if (trips.isEmpty) {
              return _buildEnhancedEmptyState(
                icon: Icons.directions_car_outlined,
                message: "no_active_trips".tr,
                subtitle: "create_first_trip_desc".tr,
              );
            }
            return Column(
              children: trips.map((trip) => _buildEnhancedTripCard(trip)).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEnhancedUpcomingTripsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "upcoming_trips".tr,
                style: AppTextStyles.subheading.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => vm.openAllUpcomingTrips(),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: Text(
                  "view_all".tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final trips = vm.upcomingTrips.take(2).toList();
            if (trips.isEmpty) {
              return _buildEnhancedEmptyState(
                icon: Icons.calendar_today_outlined,
                message: "no_upcoming_trips".tr,
                subtitle: "schedule_trip_desc".tr,
              );
            }
            return Column(
              children: trips.map((trip) => _buildEnhancedTripCard(trip)).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEnhancedTripCard(TripModel trip) {
    final iconData = _getVehicleIcon(trip.vehicleType);
    final iconColor = _getVehicleColor(trip.vehicleType);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _handleTripTap(trip),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Vehicle Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconData, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),

                // Trip Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${trip.fromCity} → ${trip.destinationCity}",
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${trip.vehicleType} • ${trip.seatsAvailable} ${'seats_available'.tr}",
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${dateFormat.format(trip.dateTime)} • ${timeFormat.format(trip.dateTime)}",
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildEnhancedStatusChip(trip.status),
                    ],
                  ),
                ),

                // Price
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${CurrencyService.instance.formatPrice(trip.pricePerPassenger)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (status) {
      case 'draft':
        backgroundColor = AppColors.textSecondary.withOpacity(0.1);
        textColor = AppColors.textSecondary;
        statusText = 'draft'.tr;
        break;
      case 'active':
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        statusText = 'active'.tr;
        break;
      case 'scheduled':
        backgroundColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        statusText = 'scheduled'.tr;
        break;
      case 'completed':
        backgroundColor = AppColors.primary.withOpacity(0.1);
        textColor = AppColors.primary;
        statusText = 'completed'.tr;
        break;
      default:
        backgroundColor = AppColors.textSecondary.withOpacity(0.1);
        textColor = AppColors.textSecondary;
        statusText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        statusText,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEnhancedEmptyState({
    required IconData icon,
    required String message,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleTripTap(TripModel trip) {
    if (trip.status == 'draft') {
      Get.toNamed(Routes.TRIP_PREVIEW, arguments: trip);
    } else if (trip.status == 'active' || trip.status == 'scheduled') {
      Get.toNamed(Routes.TRIP_DETAIL, arguments: trip);
    }
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'ferry':
        return Icons.directions_boat_rounded;
      case 'bus':
        return Icons.directions_bus_rounded;
      case 'train':
        return Icons.train_rounded;
      case 'airplane':
        return Icons.flight_takeoff_rounded;
      default:
        return Icons.directions_car_rounded;
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
}