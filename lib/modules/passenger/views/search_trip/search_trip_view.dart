import 'package:elbabor/modules/passenger/views/search_trip/widgets/trip_filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../app/themes/app_text_styles.dart';
import '../../../../app/widgets/appbar_icon_button_widget.dart';
import '../../../../app/widgets/custom_button.dart';
import '../../../../app/widgets/custom_loader.dart';
import '../../../../data/services/currency_service.dart';
import '../../../../data/models/trip_model.dart';
import '../../viewmodels/search_trip_viewmodel.dart';

class SearchTripView extends GetView<SearchTripViewModel> {
  const SearchTripView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchTripViewModel());
    final isSmallScreen = MediaQuery.of(context).size.height < 1900;

    return Scaffold(
      appBar: AppBar(
        title: Text('search_trip_title'.tr,style: AppTextStyles.heading.copyWith(color: Colors.white),),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: AppBarIconButton(
          icon: Icons.arrow_back_ios,
          onPressed: () => Get.back(),
        ),
        actions: [
          // Show filters toggle button only when results are shown on small screens
          if (isSmallScreen || controller.searchResults.isNotEmpty)
            Obx(() =>AppBarIconButton(
              icon: controller.showFilters.value ? Icons.close : Icons.filter_alt,
              onPressed: () {
                if(controller.searchResults.isNotEmpty) {
                  controller.toggleFilters();
                }
              },
            ),),

        ],
      ),
      body: SafeArea(
        child: Obx ((){
          final showFilters = controller.showFilters.value;
          final hasResults = controller.searchResults.isNotEmpty;
          return Column(
            children: [
              // Always show search header on large screens, conditionally on small screens
              if (!isSmallScreen || !hasResults || showFilters)
                _buildSearchHeader(controller, isSmallScreen),

              // Results Section - takes full space when filters are hidden
              Expanded(
                child: _buildResultsSection(controller, isSmallScreen),
              ),
            ],
          );
        })
      ),
    );
  }

  Widget _buildSearchHeader(SearchTripViewModel controller,bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Fields
          _buildSearchFields(controller),
          const SizedBox(height: 16),
          // Quick Filters - hide on small screens when showing results
          if (!isSmallScreen || controller.searchResults.isEmpty)
            _buildQuickFilters(controller),

          if (!isSmallScreen || controller.searchResults.isEmpty)
            const SizedBox(height: 16),

          // Search Button
          CustomButton(
            text: 'search_trips'.tr,
            onPressed: controller.searchTrips,
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
            borderRadius: 12,
            hasShadow: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'search_trips'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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

  Widget _buildSearchFields(SearchTripViewModel controller) {
    return Column(
      children: [
        // From - To Row
        Row(
          children: [
            Expanded(
              child: _buildLocationField(
                controller: controller.fromController,
                label: 'from_city'.tr,
                icon: Icons.location_on_outlined,
                hint: 'enter_city'.tr,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward, color: AppColors.primary, size: 16),
            ),
            Expanded(
              child: _buildLocationField(
                controller: controller.toController,
                label: 'to_city'.tr,
                icon: Icons.flag_outlined,
                hint: 'enter_city'.tr,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Date and Vehicle Type Row
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildDateField(controller),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: _buildVehicleTypeField(controller),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Time Range
        _buildTimeRangeField(controller),
      ],
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(SearchTripViewModel controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'date'.tr,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: controller.pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => Text(
                    controller.selectedDate.value != null
                        ? DateFormat('EEE, MMM dd, yyyy').format(controller.selectedDate.value!)
                        : 'select_date'.tr,
                    style: AppTextStyles.body.copyWith(
                      color: controller.selectedDate.value != null
                          ? AppColors.textPrimary
                          : Colors.grey.shade500,
                    ),
                  )),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleTypeField(SearchTripViewModel controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'vehicle'.tr,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Obx(() => DropdownButton<String>(
            value: controller.selectedVehicleType.value.isEmpty
                ? null
                : controller.selectedVehicleType.value,
            hint: Text('any'.tr, style: AppTextStyles.body),
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
            items: [
              'Car', 'Van', 'SUV', 'Bus', 'Train', 'Ferry', 'Airplane'
            ].map((v) => DropdownMenuItem(
              value: v,
              child: Text(v, style: AppTextStyles.body),
            )).toList(),
            onChanged: (v) => controller.selectedVehicleType.value = v ?? '',
            underline: const SizedBox(),
          )),
        ),
      ],
    );
  }

  Widget _buildTimeRangeField(SearchTripViewModel controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'time_range'.tr,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _buildTimeField(
                onTap: controller.pickStartTime,
                time: controller.startTime.value,
                label: 'start_time'.tr,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeField(
                onTap: controller.pickEndTime,
                time: controller.endTime.value,
                label: 'end_time'.tr,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required VoidCallback onTap,
    required TimeOfDay? time,
    required String label,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                time != null
                    ? time.format(Get.context!)
                    : label,
                style: AppTextStyles.body.copyWith(
                  color: time != null ? AppColors.textPrimary : Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilters(SearchTripViewModel controller) {
    return Row(
      children: [
        // Seats Filter
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'seats'.tr,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(() => DropdownButton<int>(
                  value: controller.selectedSeats.value,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
                  items: List.generate(8, (i) => i + 1)
                      .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text("$e ${'seats'.tr}", style: AppTextStyles.body),
                  ))
                      .toList(),
                  onChanged: (v) => controller.selectedSeats.value = v!,
                  underline: const SizedBox(),
                )),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Sort Filter
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'sort_by'.tr,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(() => DropdownButton<String>(
                  value: controller.selectedSort.value,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
                  items: [
                    DropdownMenuItem(value: 'price', child: Text('price'.tr, style: AppTextStyles.body)),
                    DropdownMenuItem(value: 'rating', child: Text('rating'.tr, style: AppTextStyles.body)),
                    DropdownMenuItem(value: 'date', child: Text('date'.tr, style: AppTextStyles.body)),
                  ],
                  onChanged: (v) => controller.selectedSort.value = v!,
                  underline: const SizedBox(),
                )),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Advanced Filters
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'filters'.tr,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            // Replace the existing filter button with this:
            Container(
              height: 48,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.filter_alt_outlined, color: AppColors.primary, size: 20),
                ),
                onPressed: () => Get.bottomSheet(
                  TripFilterDialog(onApplyFilters: controller.applyFilters),
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultsSection(SearchTripViewModel controller, bool isSmallScreen) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CustomLoader());
      }

      if (controller.searchResults.isEmpty) {
        return _buildEmptyState();
      }

      return Column(
        children: [
          // Results Header with Filter Toggle for Small Screens
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${controller.searchResults.length} ${'trips_found'.tr}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),

                Row(
                  children: [
                    Text(
                      'sorted_by'.tr + ' ' + _getSortText(controller.selectedSort.value),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    // Filter toggle for small screens
                    if (isSmallScreen) ...[
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: controller.toggleFilters,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.filter_alt,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                controller.showFilters.value ? 'hide_filters'.tr : 'filters'.tr,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Results List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: controller.searchResults.length,
              itemBuilder: (_, index) {
                final trip = controller.searchResults[index];
                return _buildTripCard(trip, controller);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Text(
            'no_trips_found'.tr,
            style: AppTextStyles.heading.copyWith(
              color: AppColors.textSecondary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'try_different_search'.tr,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(TripModel trip, SearchTripViewModel controller) {
    final vehicleData = _getVehicleData(trip.vehicleType);
    final formattedDate = DateFormat('EEE, MMM dd').format(trip.dateTime);
    final formattedTime = DateFormat('hh:mm a').format(trip.dateTime);

    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => controller.openTripDetails(trip),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with vehicle and price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: vehicleData.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(vehicleData.icon, color: vehicleData.color, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          trip.vehicleType,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        CurrencyService.instance.formatPrice(trip.pricePerPassenger),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Route
                Text(
                  "${trip.fromCity} → ${trip.destinationCity}",
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // Date, Time and Seats
                Row(
                  children: [
                    _buildTripDetail(Icons.calendar_today, formattedDate),
                    const SizedBox(width: 12),
                    _buildTripDetail(Icons.access_time, formattedTime),
                    const SizedBox(width: 12),
                    _buildTripDetail(Icons.event_seat, "${trip.seatsAvailable} ${'seats_available'.tr}"),
                  ],
                ),
                const SizedBox(height: 12),

                // Rating and Book Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          trip.rating.toStringAsFixed(1),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'view_details'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildTripDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _getSortText(String sortValue) {
    switch (sortValue) {
      case 'price': return 'price'.tr;
      case 'rating': return 'rating'.tr;
      case 'date': return 'date'.tr;
      default: return 'price'.tr;
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