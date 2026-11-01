import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../app/themes/app_colors.dart';
import '../../../../../app/themes/app_text_styles.dart';
import '../../../../../app/widgets/custom_button.dart';
import '../../../../data/models/trip_segment_model.dart';
import '../../../../data/services/currency_service.dart';
import '../../../../data/models/trip_model.dart';
import '../viewmodels/trip_preview_viewmodel.dart';

class TripPreviewView extends GetView<TripPreviewViewModel> {
  const TripPreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final TripModel trip = Get.arguments as TripModel;
    controller.setTrip(trip);

    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          "trip_preview".tr,
          style: AppTextStyles.heading.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: AppColors.textWhite,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading:   Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 22,color: Colors.white,),
            onPressed: () => Get.back(),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.share_outlined, size: 22,color: Colors.white,),
              onPressed: () => _shareTrip(trip),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildTripHeader(trip),
                    const SizedBox(height: 24),
                    _buildSegmentsCard(trip),
                    const SizedBox(height: 20),
                    _buildTripDetailsCard(trip, dateFormat, timeFormat),
                    const SizedBox(height: 20),
                    _buildVehiclesInfoCard(trip),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildPublishButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTripHeader(TripModel trip) {
    return Container(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              trip.hasMultipleSegments ? Icons.connecting_airports : _getVehicleIcon(trip.vehicleType),
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ready_to_publish".tr,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${trip.fromCity} → ${trip.destinationCity}",
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (trip.hasMultipleSegments)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "${trip.segments.length} ${'segments'.tr} • ${trip.vehicleTypesUsed.join(', ')}",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentsCard(TripModel trip) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                trip.hasMultipleSegments ? "trip_segments".tr : "route_details".tr,
                style: AppTextStyles.subheading.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(trip.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 20),

          if (trip.hasMultipleSegments)
            _buildSegmentsTimeline(trip)
          else
            _buildSingleSegmentRoute(trip),
        ],
      ),
    );
  }

  Widget _buildSingleSegmentRoute(TripModel trip) {
    return Column(
      children: [
        _buildRouteVisualization(trip),
        const SizedBox(height: 16),
        _buildPointsSection(trip),
      ],
    );
  }

  Widget _buildSegmentsTimeline(TripModel trip) {
    return Column(
      children: trip.segments.asMap().entries.map((entry) {
        final index = entry.key;
        final segment = entry.value;
        final isLast = index == trip.segments.length - 1;

        return Column(
          children: [
            _buildSegmentItem(segment, index + 1),
            if (!isLast) _buildSegmentConnector(),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSegmentItem(TripSegment segment, int segmentNumber) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getVehicleIcon(segment.vehicleType),
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "segment".tr + " $segmentNumber",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        segment.vehicleType,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "${segment.fromPoint} → ${segment.toPoint}",
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${segment.fromCity} → ${segment.toCity}",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyService.instance.formatPrice(segment.price),
                  style: AppTextStyles.bodySmall.copyWith(
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

  Widget _buildSegmentConnector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 36),
          Container(
            width: 2,
            height: 20,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.arrow_downward,
            color: AppColors.primary.withOpacity(0.5),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildRouteVisualization(TripModel trip) {
    final segment = trip.segments.first;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          // Start point
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  segment.fromCity,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  segment.fromPoint,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Route line and vehicle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 2,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getVehicleIcon(segment.vehicleType),
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 2,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),

          // End point
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  segment.toCity,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  segment.toPoint,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsSection(TripModel trip) {
    final segment = trip.segments.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "departure_from".tr,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  segment.fromPoint,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.border,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "arrival_at".tr,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  segment.toPoint,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetailsCard(TripModel trip, DateFormat dateFormat, DateFormat timeFormat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "trip_details".tr,
            style: AppTextStyles.subheading.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          _buildDetailItem(
            icon: Icons.calendar_today_outlined,
            label: "date".tr,
            value: dateFormat.format(trip.dateTime),
          ),
          _buildDetailItem(
            icon: Icons.access_time_outlined,
            label: "time".tr,
            value: timeFormat.format(trip.dateTime),
          ),
          _buildDetailItem(
            icon: Icons.event_seat_outlined,
            label: "seats_available".tr,
            value: "${trip.seatsAvailable} ${'seats'.tr}",
          ),
          _buildDetailItem(
            icon: Icons.attach_money_outlined,
            label: "total_price".tr,
            value: CurrencyService.instance.formatPrice(trip.totalPrice),
            valueStyle: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          if (trip.hasMultipleSegments)
            _buildDetailItem(
              icon: Icons.airline_stops,
              label: "segments".tr,
              value: "${trip.segments.length}",
            ),
          _buildDetailItem(
            icon: Icons.payment_outlined,
            label: "payment_method".tr,
            value: trip.paymentMethodsDisplay,
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesInfoCard(TripModel trip) {
    // Get only segments that have vehicles
    final vehicleSegments = trip.segments.where((segment) => segment.vehicle != null).toList();

    if (vehicleSegments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
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
                Icons.directions_car_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                vehicleSegments.length == 1 ? "vehicle_information".tr : "vehicles_information".tr,
                style: AppTextStyles.subheading.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...vehicleSegments.asMap().entries.map((entry) {
            final index = entry.key;
            final segment = entry.value;
            final isLast = index == vehicleSegments.length - 1;

            return Column(
              children: [
                if (vehicleSegments.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "${segment.vehicleType} - ${'segment'.tr} ${trip.segments.indexWhere((s) => s.id == segment.id) + 1}",
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (segment.vehicle!.photoUrl != null && segment.vehicle!.photoUrl!.isNotEmpty)
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          segment.vehicle!.photoUrl!,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: AppColors.scaffoldBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.car_repair,
                                color: AppColors.primary,
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                _buildVehicleDetailItem("brand".tr, segment.vehicle!.brand),
                _buildVehicleDetailItem("model".tr, segment.vehicle!.model),
                _buildVehicleDetailItem("license_plate".tr, segment.vehicle!.plate),

                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(
                      color: AppColors.border,
                      height: 1,
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: valueStyle ?? AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value.isNotEmpty ? value : "-",
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() => CustomButton(
        text: "publish_trip".tr,
        onPressed: controller.isPublishing.value ? null : controller.publishTrip,
        isLoading: controller.isPublishing.value,
        icon: Icons.publish_outlined,
        type: ButtonType.primary,
        size: ButtonSize.large,
      )),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return AppColors.warning;
      case 'active':
        return AppColors.success;
      case 'scheduled':
        return AppColors.info;
      case 'completed':
        return AppColors.primary;
      default:
        return AppColors.grey;
    }
  }

  void _shareTrip(TripModel trip) {
    // Implement share functionality
    Get.snackbar(
      "share_trip".tr,
      "coming_soon".tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}