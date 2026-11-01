import 'package:elbabor/modules/passenger/views/widgets/route_visualization_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../app/themes/app_text_styles.dart';
import '../../../../app/widgets/custom_button.dart';
import '../../../../app/widgets/custom_loader.dart';
import '../../../data/models/trip_segment_model.dart';
import '../../../data/services/currency_service.dart';
import '../../../data/models/trip_model.dart';
import '../viewmodels/passenger_trip_detail_viewmodel.dart';

class PassengerTripDetailView extends GetView<PassengerTripDetailViewModel> {
  const PassengerTripDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final TripModel trip = Get.arguments;
    final controller = Get.put(PassengerTripDetailViewModel());
    controller.setTrip(trip);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("trip_details".tr, style: AppTextStyles.heading.copyWith(color: Colors.white)),
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
          return CustomLoader(message: "loading_trip_details".tr);
        }

        return CustomScrollView(
          slivers: [
            // Trip Overview Section
            SliverToBoxAdapter(
              child: _buildTripOverviewCard(trip, controller),
            ),

            // Trip Details Section
            SliverToBoxAdapter(
              child: _buildTripDetailsCard(trip),
            ),

            // Driver Info Section
            SliverToBoxAdapter(
              child: _buildDriverInfoCard(controller),
            ),

            // Seat Availability Section
            SliverToBoxAdapter(
              child: _buildSeatAvailabilityCard(controller),
            ),

            // Vehicle Info Section
            // SliverToBoxAdapter(
            //   child: _buildVehicleInfoCard(trip),
            // ),

            // Action Button
            SliverToBoxAdapter(
              child: _buildActionButtons(controller),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTripDetailsCard(TripModel trip) {
    final formattedDuration = _calculateDuration(trip.dateTime);

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
                "trip_details".tr,
                style: AppTextStyles.heading.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.confirmation_number, "trip_id".tr, trip.id.substring(0, 8)),
          _buildDetailRow(Icons.payment, "payment_method".tr, trip.paymentMethodsDisplay),
          _buildDetailRow(Icons.schedule, "departure_in".tr, formattedDuration),
          _buildDetailRow(Icons.star, "trip_rating".tr, trip.rating.toStringAsFixed(1)),
        ],
      ),
    );
  }

  Widget _buildDriverInfoCard(PassengerTripDetailViewModel controller) {
    final driver = controller.driver.value;
    if (driver == null) return const SizedBox();

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
              Icon(Icons.person_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                "driver_info".tr,
                style: AppTextStyles.heading.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Driver Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
                ),
                child: ClipOval(
                  child: driver.photoUrl != null
                      ? Image.network(driver.photoUrl!, fit: BoxFit.cover)
                      : Container(
                    color: AppColors.primary.withOpacity(0.1),
                    child: Icon(Icons.person, color: AppColors.primary, size: 30),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Driver Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          driver.rating.toStringAsFixed(1),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${driver.totalTrips} ${'trips'.tr}",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (driver.phoneNumber!.isNotEmpty)
                      Text(
                        driver.phoneNumber ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              // View Profile Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GestureDetector(
                  onTap: controller.onViewDriverProfile,
                  child: Text(
                    "view_profile".tr,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeatAvailabilityCard(PassengerTripDetailViewModel controller) {
    return Obx(() {
      final booked = controller.bookedSeats;
      final available = controller.availableSeats;
      final total = controller.totalSeats;
      final percentage = total > 0 ? (booked / total) * 100 : 0;

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
                Icon(Icons.event_seat, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  "seat_availability".tr,
                  style: AppTextStyles.heading.copyWith(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Bar
            Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  height: 8,
                  width: (percentage / 100) * (MediaQuery.of(Get.context!).size.width - 72),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        percentage > 80 ? Colors.red : AppColors.primary,
                        percentage > 80 ? Colors.orange : AppColors.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Seat Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSeatStat("total".tr, "$total", AppColors.textPrimary),
                _buildSeatStat("booked".tr, "$booked", Colors.orange),
                _buildSeatStat("available".tr, "$available", available > 0 ? Colors.green : Colors.red),
              ],
            ),

            // Availability Message
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: available > 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    available > 0 ? Icons.check_circle : Icons.warning,
                    color: available > 0 ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      available > 0
                          ? "${'seats_available_message'.tr} $available ${'seats'.tr}"
                          : "fully_booked_message".tr,
                      style: TextStyle(
                        color: available > 0 ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActionButtons(PassengerTripDetailViewModel controller) {
    return Obx(() {
      final available = controller.availableSeats;

      return Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomButton(
              text: available > 0 ? 'book_now'.tr : 'fully_booked'.tr,
              onPressed: available > 0 ? controller.onBookNow : null,
              backgroundColor: available > 0 ? AppColors.primary : Colors.grey,
              textColor: Colors.white,
              height: 56,
              borderRadius: 16,
              hasShadow: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    available > 0 ? Icons.confirmation_number : Icons.warning,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    available > 0 ? 'book_now'.tr : 'fully_booked'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (available > 0)
              Text(
                "${available} ${'seats_available'.tr}",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      );
    });
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
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

  Widget _buildSeatStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading.copyWith(
            fontSize: 18,
            color: color,
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

  String _calculateDuration(DateTime tripDateTime) {
    final now = DateTime.now();
    final difference = tripDateTime.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours.remainder(24)}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes.remainder(60)}m';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'departing_soon'.tr;
    }
  }


  Widget _buildTripOverviewCard(TripModel trip, PassengerTripDetailViewModel controller) {
    final formattedDate = DateFormat('EEE, MMM dd, yyyy').format(trip.dateTime);
    final formattedTime = DateFormat('hh:mm a').format(trip.dateTime);

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
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // New Route Visualization
          RouteVisualizationWidget(
            trip: trip,
            showFullDetails: true,
          ),

          const SizedBox(height: 16),

          // Time and Seats Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  icon: Icons.access_time,
                  label: formattedTime,
                ),
                Container(
                  width: 1,
                  height: 20,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildInfoItem(
                  icon: Icons.event_seat,
                  label: "${trip.seatsAvailable} ${'seats'.tr}",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'ferry':
        return Icons.directions_boat;
      case 'bus':
        return Icons.directions_bus;
      case 'van':
        return Icons.airport_shuttle;
      case 'suv':
        return Icons.directions_car_filled;
      default:
        return Icons.directions_car;
    }
  }

  Widget _buildTripDetail({required IconData icon, required String label, required Color color}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _VehicleData {
  final IconData icon;
  final Color color;
  _VehicleData(this.icon, this.color);
}