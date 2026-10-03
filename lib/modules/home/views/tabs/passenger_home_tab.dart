import 'package:carousel_slider/carousel_slider.dart';
import 'package:elbabor/data/services/currency_service.dart';
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
    final controller =Get.put(PassengerHomeViewModel());

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

              // Rating notification badge
              if (controller.hasPendingRatings)
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
                    child: Badge(
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
            ],
          ),
          const SizedBox(height: 20),

          // Search Bar (keep the same)
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
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

  Widget _buildRecommendedTrips(List<TripModel> trips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "recommended_trips".tr,
                style: AppTextStyles.heading.copyWith(fontSize: 20),
              ),
              TextButton(
                onPressed: trips.isNotEmpty ? () => controller.openAllRecommendedTrips() : null,
                child: Text(
                  'see_all'.tr,
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (trips.isEmpty)
          _buildEmptyRecommendedTrips()
        else
        CarouselSlider.builder(
          itemCount: trips.length,
          itemBuilder: (context, index, _) {
            final trip = trips[index];
            final vehicleData = _getVehicleData(trip.vehicleType);
            final formattedDate = DateFormat('EEE, MMM dd • hh:mm a').format(trip.dateTime);

            return GestureDetector(
              onTap: () => Get.find<PassengerHomeViewModel>().openTripDetails(trip),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      vehicleData.color.withOpacity(0.15),
                      vehicleData.color.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: vehicleData.color.withOpacity(0.1),
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
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: vehicleData.color.withOpacity(0.2),
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
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'price'.tr,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              CurrencyService.instance.formatPrice(trip.pricePerPassenger),
                              style: AppTextStyles.heading.copyWith(
                                fontSize: 18,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'seats'.tr,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              "${trip.seatsAvailable} ${'available'.tr}",
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'book_now'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 180,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.85,
            autoPlayInterval: const Duration(seconds: 5),
            pauseAutoPlayOnTouch: true,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEmptyRecommendedTrips() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 32, color: AppColors.textHint),
            const SizedBox(height: 8),
            Text(
              'no_recommended_trips_found'.tr,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularRoutes(List<Map<String, dynamic>> popularRoutes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "popular_routes".tr,
            style: AppTextStyles.heading.copyWith(fontSize: 20),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: popularRoutes.length,
            itemBuilder: (context, index) {
              final route = popularRoutes[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.route, color: AppColors.primary, size: 20),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route['route'],
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${route['trips']} ${'trips'.tr}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildUpcomingTrips(List<TripModel> trips, PassengerHomeViewModel controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "upcoming_trips".tr,
                style: AppTextStyles.heading.copyWith(fontSize: 20),
              ),
              TextButton(
                onPressed: trips.isNotEmpty ? () => controller.openAllUpcomingTrips() : null,
                child: Text(
                  'view_all'.tr,
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (trips.isEmpty)
          _buildEmptyUpcomingTrips()
        else
        ...trips.take(3).map((trip) {
          final vehicleData = _getVehicleData(trip.vehicleType);
          final formattedDate = DateFormat('EEE, MMM dd • hh:mm a').format(trip.dateTime);
          final timeLeft = trip.dateTime.difference(DateTime.now());

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(16),
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
            child: Row(
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
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimeLeft(timeLeft),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => controller.openTripDetails(trip),
                  icon: Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEmptyUpcomingTrips() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.calendar_today_outlined, size: 32, color: AppColors.textHint),
            const SizedBox(height: 8),
            Text(
              'no_upcoming_trips'.tr,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              'book_your_first_trip_to_see_it_here'.tr,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFindTripButton(PassengerHomeViewModel controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CustomButton(
        text: 'find_trip'.tr, // Still required for backward compatibility
        onPressed: controller.onFindTrip,
        backgroundColor: AppColors.primary,
        textColor: Colors.white,
        isFullWidth: true,
        height: 56,
        borderRadius: 16,
        hasShadow: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'find_trip'.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
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