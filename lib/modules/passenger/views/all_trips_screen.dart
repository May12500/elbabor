// lib/modules/passenger/views/all_trips_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../data/services/currency_service.dart';
import '../../home/viewmodels/tabs/passenger_home_viewmodel.dart';
import '../../../data/models/trip_model.dart';

class AllTripsScreen extends StatelessWidget {
  final String screenTitle;
  final List<TripModel> trips;
  final TripType tripType;

  const AllTripsScreen({
    super.key,
    required this.screenTitle,
    required this.trips,
    required this.tripType,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PassengerHomeViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(screenTitle,style: AppTextStyles.heading.copyWith(color: Colors.white),),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
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
      body: trips.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return _buildTripCard(trip, controller);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.travel_explore_outlined,
            size: 80,
            color: AppColors.textHint.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            tripType == TripType.recommended
                ? 'no_recommended_trips'.tr
                : 'no_upcoming_trips'.tr,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            tripType == TripType.recommended
                ? 'check_back_later_for_new_trips'.tr
                : 'you_dont_have_any_upcoming_trips'.tr,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(TripModel trip, PassengerHomeViewModel controller) {
    final vehicleData = _getVehicleData(trip.vehicleType);
    final formattedDate = DateFormat('EEE, MMM dd • hh:mm a').format(trip.dateTime);
    final timeLeft = trip.dateTime.difference(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.border.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with route and vehicle
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: vehicleData.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(vehicleData.icon, color: vehicleData.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${trip.fromCity} → ${trip.destinationCity}",
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      formattedDate,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Trip details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailColumn(
                title: 'departure'.tr,
                value: trip.departurePoint,
                icon: Icons.location_on_outlined,
              ),
              _buildDetailColumn(
                title: 'arrival'.tr,
                value: trip.arrivalPoint,
                icon: Icons.location_on,
              ),
              _buildDetailColumn(
                title: 'seats'.tr,
                value: '${trip.seatsAvailable} ${'available'.tr}',
                icon: Icons.event_seat_outlined,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Footer with price and action button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'price_per_passenger'.tr,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    CurrencyService.instance.formatPrice(trip.pricePerPassenger),
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              // Different button based on trip type
              if (tripType == TripType.recommended)
                _buildBookNowButton(trip, controller)
              else
                _buildTripStatusInfo(timeLeft),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailColumn({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                title,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBookNowButton(TripModel trip, PassengerHomeViewModel controller) {
    return GestureDetector(
      onTap: () => controller.openTripDetails(trip),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          'book_now'.tr,
          style: AppTextStyles.buttonSmall.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTripStatusInfo(Duration timeLeft) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _formatTimeLeft(timeLeft),
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'departing_soon'.tr,
          style: AppTextStyles.overline.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatTimeLeft(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h left';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m left';
    } else {
      return '${duration.inMinutes}m left';
    }
  }

  VehicleData _getVehicleData(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'car':
        return VehicleData(
          icon: Icons.directions_car,
          color: AppColors.primary,
        );
      case 'bike':
        return VehicleData(
          icon: Icons.two_wheeler,
          color: Colors.orange,
        );
      case 'van':
        return VehicleData(
          icon: Icons.airport_shuttle,
          color: Colors.green,
        );
      default:
        return VehicleData(
          icon: Icons.directions_car,
          color: AppColors.primary,
        );
    }
  }
}

// Enums and helper classes
enum TripType {
  recommended,
  upcoming, active,
}

class VehicleData {
  final IconData icon;
  final Color color;

  VehicleData({required this.icon, required this.color});
}