import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../app/themes/app_text_styles.dart';
import '../../../../app/widgets/custom_button.dart';
import '../../../../app/widgets/custom_loader.dart';
import '../../../data/models/driver_model.dart';
import '../../../data/services/currency_service.dart';
import '../../../data/models/trip_model.dart';
import '../viewmodels/driver_info_viewmodel.dart';

class DriverInfoView extends GetView<DriverInfoViewModel> {
  const DriverInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("driver_profile".tr, style: AppTextStyles.heading.copyWith(color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading:  Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed:(){Get.back();},
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return CustomLoader(message: "loading_driver".tr);
        }

        final driver = controller.driver.value;
        if (driver == null) {
          return _buildErrorState();
        }

        return CustomScrollView(
          slivers: [
            // Driver Header Section
            SliverToBoxAdapter(
              child: _buildDriverHeader(driver),
            ),

            // Driver Stats Section
            SliverToBoxAdapter(
              child: _buildDriverStats(driver),
            ),

            // About Section
            SliverToBoxAdapter(
              child: _buildAboutSection(driver),
            ),

            // Available Trips Section
            SliverToBoxAdapter(
              child: _buildAvailableTrips(controller.trips),
            ),

            // Action Buttons
            SliverToBoxAdapter(
              child: _buildActionButtons(),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 80,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Text(
            "driver_not_found".tr,
            style: AppTextStyles.heading.copyWith(
              color: AppColors.textSecondary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "driver_not_found_desc".tr,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDriverHeader(DriverModel driver) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Driver Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
            ),
            child: ClipOval(
              child: driver.photoUrl != null
                  ? Image.network(driver.photoUrl!, fit: BoxFit.cover)
                  : Container(
                color: Colors.white.withOpacity(0.2),
                child: Icon(Icons.person, color: Colors.white, size: 40),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Driver Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Rating and Trips
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            driver.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${driver.totalTrips} ${'trips'.tr}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Join Date
                if (driver.createdAt != null)
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.7), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "joined".tr + " " + DateFormat('MMM yyyy').format(driver.createdAt!),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverStats(DriverModel driver) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.check_circle,
                value: driver.completedTrips.toString(),
                label: "completed".tr,
                color: Colors.green,
              ),
              _buildStatItem(
                icon: Icons.star,
                value: driver.rating.toStringAsFixed(1),
                label: "rating".tr,
                color: Colors.amber,
              ),
              _buildStatItem(
                icon: Icons.cancel,
                value: driver.cancelledTrips.toString(),
                label: "cancelled".tr,
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Success Rate
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  "success_rate".tr + " ${_calculateSuccessRate(driver).toStringAsFixed(1)}%",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String value, required String label, required Color color}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.heading.copyWith(
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(DriverModel driver) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                "about_driver".tr,
                style: AppTextStyles.heading.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Contact Info
          _buildAboutItem(Icons.phone, "phone".tr, driver.phoneNumber!),
          _buildAboutItem(Icons.email, "email".tr, driver.email),

          // Experience
          if (driver.totalTrips > 0)
            _buildAboutItem(
              Icons.work_history,
              "experience".tr,
              "${driver.totalTrips} ${'completed_trips'.tr}",
            ),

          // // Vehicle Info (if available)
          // if (driver.vehicleInfo != null)
          //   _buildAboutItem(
          //     Icons.directions_car,
          //     "vehicle".tr,
          //     "${driver.vehicleInfo!['brand']} ${driver.vehicleInfo!['model']}",
          //   ),
        ],
      ),
    );
  }

  Widget _buildAboutItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableTrips(List<TripModel> trips) {
    if (trips.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          children: [
            Icon(
              Icons.airline_seat_recline_normal,
              size: 60,
              color: AppColors.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              "no_active_trip".tr,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "no_active_trip_desc".tr,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.directions_bus, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  "available_trips".tr,
                  style: AppTextStyles.heading.copyWith(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trips.length.toString(),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...trips.map((trip) => _buildTripCard(trip)).toList(),
        ],
      ),
    );
  }

  Widget _buildTripCard(TripModel trip) {
    final vehicleData = _getVehicleData(trip.vehicleType);
    final formattedDate = DateFormat('EEE, MMM dd').format(trip.dateTime);
    final formattedTime = DateFormat('hh:mm a').format(trip.dateTime);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          // onTap: () => _viewTripDetails(trip),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Vehicle Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: vehicleData.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(vehicleData.icon, color: vehicleData.color, size: 20),
                ),
                const SizedBox(width: 12),

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
                        "$formattedDate • $formattedTime",
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Price and Seats
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyService.instance.formatPrice(trip.pricePerPassenger),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${trip.seatsAvailable} ${'seats'.tr}",
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
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

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomButton(
            text: "message_driver".tr,
            onPressed: () => Get.find<DriverInfoViewModel>().onMessageDriver(),
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
            height: 56,
            borderRadius: 16,
            hasShadow: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  "message_driver".tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 12),
          // CustomButton(
          //   text: "view_all_trips".tr,
          //   onPressed: () => _viewAllTrips(),
          //   type: ButtonType.outlined,
          //   height: 50,
          //   borderRadius: 16,
          // ),
        ],
      ),
    );
  }

  double _calculateSuccessRate(DriverModel driver) {
    final total = driver.completedTrips + driver.cancelledTrips;
    return total > 0 ? (driver.completedTrips / total) * 100 : 100;
  }

  void _viewTripDetails(TripModel trip) {
    // Navigate to trip details
    Get.toNamed('/passenger-trip-detail', arguments: trip);
  }

  void _viewAllTrips() {
    // Navigate to all trips by this driver
    final driver = Get.find<DriverInfoViewModel>().driver.value;
    if (driver != null) {
      // Get.toNamed('/driver-trips', arguments: driver.uid);
    }
  }

  _VehicleData _getVehicleData(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'ferry':
        return _VehicleData(Icons.directions_boat, Colors.blueAccent);
      case 'bus':
        return _VehicleData(Icons.directions_bus, Colors.orangeAccent);
      case 'train':
        return _VehicleData(Icons.train, Colors.green);
      case 'airplane':
        return _VehicleData(Icons.flight_takeoff, Colors.purple);
      default:
        return _VehicleData(Icons.directions_car, AppColors.primary);
    }
  }
}

class _VehicleData {
  final IconData icon;
  final Color color;
  _VehicleData(this.icon, this.color);
}