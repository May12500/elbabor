import 'package:elbabor/data/services/currency_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../passenger/views/all_trips_screen.dart';
import '../../../data/models/trip_model.dart';
import '../home/viewmodels/driver_home_viewmodel.dart';


class AllDriverTripsScreen extends StatelessWidget {
  final String screenTitle;
  final List<TripModel> trips;
  final TripType tripType;

  const AllDriverTripsScreen({
    super.key,
    required this.screenTitle,
    required this.trips,
    required this.tripType,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverHomeViewModel>();

    return Scaffold(
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
        actions: [
          if (tripType == TripType.upcoming)
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => Get.toNamed(Routes.DRIVER_CREATE_TRIP),
                icon: const Icon(Icons.add,color: Colors.white,),
                tooltip: 'create_new_trip'.tr,
              ),
            ),
        ],
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
            tripType == TripType.active
                ? Icons.directions_car_outlined
                : Icons.calendar_today_outlined,
            size: 80,
            color: AppColors.textHint.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            tripType == TripType.active
                ? 'no_active_trips'.tr
                : 'no_upcoming_trips'.tr,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            tripType == TripType.active
                ? 'you_dont_have_any_active_trips'.tr
                : 'schedule_your_first_trip_to_get_started'.tr,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (tripType == TripType.upcoming) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.toNamed(Routes.DRIVER_CREATE_TRIP),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('create_trip'.tr),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTripCard(TripModel trip, DriverHomeViewModel controller) {
    final vehicleData = _getVehicleData(trip.vehicleType);
    final formattedDate = DateFormat('EEE, MMM dd • hh:mm a').format(trip.dateTime);
    final timeLeft = trip.dateTime.difference(DateTime.now());
    final bookingsCount = trip.bookedPassengers?.length ?? 0;

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
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(trip.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getStatusColor(trip.status).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  trip.status.toUpperCase(),
                  style: AppTextStyles.overline.copyWith(
                    color: _getStatusColor(trip.status),
                    fontWeight: FontWeight.w600,
                  ),
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
                title: 'bookings'.tr,
                value: '$bookingsCount / ${trip.totalSeats}',
                icon: Icons.people_outline,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Footer with earnings and action button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'estimated_earnings'.tr,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    CurrencyService.instance.formatPrice(_calculateEarnings(trip)),
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),

              // Action button based on trip type and status
              _buildActionButton(trip, controller, timeLeft),
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

  Widget _buildActionButton(TripModel trip, DriverHomeViewModel controller, Duration timeLeft) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.TRIP_DETAIL, arguments: trip),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'view_details'.tr,
              style: AppTextStyles.buttonSmall.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
          ],
        ),
      ),
    );
  }

  double _calculateEarnings(TripModel trip) {
    final bookingsCount = trip.bookedPassengers.length ?? 0;
    return bookingsCount * trip.pricePerPassenger;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'upcoming':
        return AppColors.primary;
      case 'completed':
        return AppColors.textSecondary;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
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