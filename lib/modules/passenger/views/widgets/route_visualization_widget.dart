import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/trip_model.dart';
import '../../../../data/models/trip_segment_model.dart';
import '../../../../data/services/currency_service.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../app/themes/app_text_styles.dart';

class RouteVisualizationWidget extends StatelessWidget {
  final TripModel trip;
  final bool showFullDetails;

  const RouteVisualizationWidget({
    super.key,
    required this.trip,
    this.showFullDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    if (trip.segments.isEmpty) return const SizedBox();

    return trip.segments.length == 1
        ? _buildSingleSegmentRoute(trip.segments.first)
        : _buildModernMultiSegmentJourney(trip.segments);
  }

  Widget _buildSingleSegmentRoute(TripSegment segment) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildRouteWithVehicle(segment),
          const SizedBox(height: 16),
          _buildPointsDetails(segment),
        ],
      ),
    );
  }

  Widget _buildModernMultiSegmentJourney(List<TripSegment> segments) {
    final totalPrice = segments.fold(0.0, (sum, segment) => sum + segment.price);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Journey Progress Bar
          _buildJourneyProgressBar(segments),
          const SizedBox(height: 24),

          // Segments with Visual Connections
          _buildVisualSegmentsList(segments),
          const SizedBox(height: 16),

          // Total Price
          _buildTotalPriceCard(totalPrice),
        ],
      ),
    );
  }

  Widget _buildJourneyProgressBar(List<TripSegment> segments) {
    return Column(
      children: [
        // Progress Bar with Points
        SizedBox(
          height: 80,
          child: Stack(
            children: [
              // Main Progress Line
              Positioned(
                left: 30,
                right: 30,
                top: 35,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success,
                        AppColors.primary,
                        AppColors.warning,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Journey Points
              Row(
                children: [
                  _buildProgressPoint(
                    segment: segments.first,
                    type: JourneyPointType.start,
                    position: 0,
                    total: segments.length,
                  ),

                  ...segments.asMap().entries.map((entry) {
                    if (entry.key == 0) return const SizedBox.shrink();

                    return _buildProgressPoint(
                      segment: entry.value,
                      type: JourneyPointType.middle,
                      position: entry.key,
                      total: segments.length,
                    );
                  }),

                  _buildProgressPoint(
                    segment: segments.last,
                    type: JourneyPointType.end,
                    position: segments.length,
                    total: segments.length,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressPoint({
    required TripSegment segment,
    required JourneyPointType type,
    required int position,
    required int total,
  }) {
    final isStart = type == JourneyPointType.start;
    final isEnd = type == JourneyPointType.end;

    String city;
    if (isStart) {
      city = segment.fromCity;
    } else if (isEnd) {
      city = segment.toCity;
    } else {
      city = segment.fromCity;
    }

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated Point
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getPointColor(type),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.background, width: 3),
              boxShadow: [
                BoxShadow(
                  color: _getPointColor(type).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  _getPointIcon(type),
                  color: AppColors.background,
                  size: 16,
                ),

                // Vehicle type indicator for middle points
                if (!isStart && !isEnd)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                        border: Border.all(color: _getPointColor(type), width: 1),
                      ),
                      child: Icon(
                        _getVehicleIcon(segment.vehicleType),
                        color: _getPointColor(type),
                        size: 8,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // City Name
          Text(
            city,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildVisualSegmentsList(List<TripSegment> segments) {
    return Column(
      children: segments.asMap().entries.map((entry) {
        final index = entry.key;
        final segment = entry.value;
        final isLast = index == segments.length - 1;

        return Column(
          children: [
            // Segment Card
            _buildModernSegmentCard(segment, index + 1),

            // Connection Line (except for last segment)
            if (!isLast) _buildSegmentConnection(),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildModernSegmentCard(TripSegment segment, int segmentNumber) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row: Cities with connecting line and vehicle
          Row(
            children: [
              // Start City
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      segment.fromCity,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Connecting Line and Vehicle
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Dashed Line
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.4),
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),

                    // Vehicle in Center
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryVariant, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getVehicleIcon(segment.vehicleType),
                        color: AppColors.background,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // End City
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      segment.toCity,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Middle Row: Points with connecting line
          if (segment.fromPoint.isNotEmpty || segment.toPoint.isNotEmpty)
            Row(
              children: [
                // Start Point
                Expanded(
                  child: Text(
                    segment.fromPoint,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Connecting Line for Points
                Expanded(
                  child: Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                ),

                // End Point
                Expanded(
                  child: Text(
                    segment.toPoint,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 12),

          // Bottom Row: Price below vehicle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.attach_money_rounded,
                      color: AppColors.background,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      CurrencyService.instance.formatPrice(segment.price),
                      style: AppTextStyles.buttonSmall.copyWith(
                        color: AppColors.background,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentConnection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 25),
          Container(
            width: 2,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.6),
                  AppColors.warning.withOpacity(0.6),
                ],
              ),
            ),
          ),
          const SizedBox(width: 23),
          Icon(
            Icons.swap_vert,
            color: AppColors.primary.withOpacity(0.6),
            size: 16,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildTotalPriceCard(double totalPrice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_money_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "total_price".tr,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            CurrencyService.instance.formatPrice(totalPrice),
            style: AppTextStyles.priceLarge.copyWith(
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  // Single segment methods with updated colors
  Widget _buildRouteWithVehicle(TripSegment segment) {
    return Row(
      children: [
        Expanded(
          child: _buildJourneyPoint(
            city: segment.fromCity,
            point: segment.fromPoint,
            type: JourneyPointType.start,
          ),
        ),
        _buildVehicleConnection(segment),
        Expanded(
          child: _buildJourneyPoint(
            city: segment.toCity,
            point: segment.toPoint,
            type: JourneyPointType.end,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleConnection(TripSegment segment) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                _getVehicleIcon(segment.vehicleType),
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                CurrencyService.instance.formatPrice(segment.price),
                style: AppTextStyles.buttonSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Icon(
          Icons.arrow_forward,
          color: AppColors.primary,
          size: 20,
        ),
      ],
    );
  }

  Widget _buildJourneyPoint({
    required String city,
    required String point,
    required JourneyPointType type,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _getPointColor(type),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.background, width: 3),
          ),
          child: Icon(
            _getPointIcon(type),
            color: AppColors.background,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          city,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (point.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            point,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildPointsDetails(TripSegment segment) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildPointDetail(
            city: segment.fromCity,
            point: segment.fromPoint,
            type: 'Departure',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPointDetail(
            city: segment.toCity,
            point: segment.toPoint,
            type: 'Arrival',
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildPointDetail({
    required String city,
    required String point,
    required String type,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                type,
                style: AppTextStyles.labelMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            city,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          if (point.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              point,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  // Updated color scheme methods to match your theme
  Color _getPointColor(JourneyPointType type) {
    switch (type) {
      case JourneyPointType.start:
        return AppColors.success;
      case JourneyPointType.middle:
        return AppColors.primary;
      case JourneyPointType.end:
        return AppColors.warning;
    }
  }

  IconData _getPointIcon(JourneyPointType type) {
    switch (type) {
      case JourneyPointType.start:
        return Icons.location_on;
      case JourneyPointType.middle:
        return Icons.location_city;
      case JourneyPointType.end:
        return Icons.flag;
    }
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'car':
        return Icons.directions_car;
      case 'van':
        return Icons.airport_shuttle;
      case 'suv':
        return Icons.directions_car_filled;
      case 'bus':
        return Icons.directions_bus;
      case 'ferry':
        return Icons.directions_boat;
      default:
        return Icons.emoji_transportation;
    }
  }
}

enum JourneyPointType {
  start,
  middle,
  end,
}