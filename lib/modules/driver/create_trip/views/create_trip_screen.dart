import 'package:elbabor/app/themes/app_colors.dart';
import 'package:elbabor/app/themes/app_text_styles.dart';
import 'package:elbabor/data/services/currency_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/widgets/custom_button.dart';
import '../../../../app/widgets/custom_text_field.dart';
import '../../../../app/widgets/responsive_widgets.dart';
import '../../../../data/models/trip_segment_model.dart';
import '../viewmodels/create_trip_viewmodel.dart';

class CreateTripScreen extends GetView<CreateTripViewModel> {
  const CreateTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 1200) {
                  return _buildDesktopLayout(context);
                } else if (constraints.maxWidth >= 600) {
                  return _buildTabletLayout(context);
                } else {
                  return _buildMobileLayout(context);
                }
              },
            ),
          ),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSegmentManagementSection(context),
          const SizedBox(height: 16),
          _buildSegmentDetailsSection(context),
          const SizedBox(height: 16),
          _buildTripSettingsSection(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildSegmentManagementSection(context),
                const SizedBox(height: 20),
                _buildTripSettingsSection(context),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 1,
            child: _buildSegmentDetailsSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: _buildSegmentManagementSection(context),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: _buildSegmentDetailsSection(context),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: _buildTripSettingsSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentManagementSection(BuildContext context) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "trip_segments".tr,
                style: AppTextStyles.subheading.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: controller.addSegment,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSegmentsList(),
        ],
      ),
    );
  }

  Widget _buildSegmentsList() {
    return Obx(() {
      if (controller.segments.isEmpty) {
        return _buildEmptySegmentsState();
      }

      return Column(
        children: controller.segments.asMap().entries.map((entry) {
          final index = entry.key;
          final segment = entry.value;
          return _buildSegmentListItem(segment, index);
        }).toList(),
      );
    });
  }

  Widget _buildSegmentListItem(TripSegment segment, int index) {
    final isActive = controller.currentEditingSegmentIndex.value == index;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isActive ? AppColors.primary : AppColors.grey.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        leading: Icon(
          _getVehicleIcon(segment.vehicleType),
          color: isActive ? AppColors.primary : AppColors.grey,
        ),
        title: Text(
          segment.vehicleType.isNotEmpty ? segment.vehicleType : "select_vehicle_type".tr,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w500,
            color: isActive ? AppColors.primary : AppColors.darkGrey,
          ),
        ),
        subtitle: segment.fromPoint.isNotEmpty && segment.toPoint.isNotEmpty
            ? Text("${segment.fromPoint} → ${segment.toPoint}")
            : Text("set_route_points".tr),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (segment.price > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  CurrencyService.instance.formatPrice(segment.price),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: () => _showDeleteSegmentDialog(index),
            ),
          ],
        ),
        onTap: () => controller.setCurrentSegment(index),
      ),
    );
  }

  Widget _buildEmptySegmentsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.route_outlined, size: 48, color: AppColors.grey),
          const SizedBox(height: 16),
          Text(
            "no_segments_added".tr,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "start_by_adding_your_first_journey_segment".tr,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: "add_first_segment".tr,
            onPressed: controller.addSegment,
            type: ButtonType.outlined,
            size: ButtonSize.small,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentDetailsSection(BuildContext context) {
    return Obx(() {
      final currentIndex = controller.currentEditingSegmentIndex.value;
      if (currentIndex == null) {
        return ResponsiveCard(
          child: Column(
            children: [
              Icon(Icons.select_all, size: 48, color: AppColors.grey.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                "no_segment_selected".tr,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "select_or_add_segment_to_configure".tr,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          ResponsiveCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "segment_details".tr + " ${currentIndex + 1}",
                  style: AppTextStyles.subheading.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildVehicleTypeSelector(currentIndex),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ResponsiveCard(
            child: Column(
              children: [
                Text(
                  "route_locations".tr,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSegmentCities(currentIndex),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ResponsiveCard(
            child: Column(
              children: [
                Text(
                  "specific_points".tr,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSegmentPoints(currentIndex),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ResponsiveCard(
            child: Column(
              children: [
                Text(
                  "pricing".tr,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSegmentPrice(currentIndex),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.currentSegmentVehicleType.value == 'Car' ||
                controller.currentSegmentVehicleType.value == 'Van' ||
                controller.currentSegmentVehicleType.value == 'SUV') {
              return Column(
                children: [
                  ResponsiveCard(
                    child: Column(
                      children: [
                        Text(
                          "vehicle_information".tr,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildVehicleInfo(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            } else if (controller.currentSegmentVehicleType.value.isNotEmpty) {
              return Column(
                children: [
                  ResponsiveCard(
                    child: Column(
                      children: [
                        Text(
                          "operator_information".tr,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildOperatorInfo(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      );
    });
  }

  Widget _buildVehicleTypeSelector(int segmentIndex) {
    return Obx(() => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: controller.vehicleTypes.map((type) {
        final selected = controller.currentSegmentVehicleType.value == type;
        return FilterChip(
          label: Text(
            type,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          selected: selected,
          backgroundColor: Colors.white,
          selectedColor: AppColors.primary,
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: selected ? AppColors.primary : AppColors.grey.withOpacity(0.3),
            ),
          ),
          onSelected: (_) => controller.selectVehicleTypeForCurrentSegment(type),
        );
      }).toList(),
    ));
  }

  Widget _buildSegmentCities(int segmentIndex) {
    return Column(
      children: [
        CustomTextField(
          controller: controller.fromCityController,
          onChanged: (_) => controller.updateCurrentSegment(),
          labelText: "from_city".tr,
          hintText: "enter_from_city".tr,
          prefixIcon: Icon(Icons.location_city_outlined, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: controller.toCityController,
          onChanged: (_) => controller.updateCurrentSegment(),
          labelText: "to_city".tr,
          hintText: "enter_to_city".tr,
          prefixIcon: Icon(Icons.location_city, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildSegmentPoints(int segmentIndex) {
    return Column(
      children: [
        Obx(() => CustomTextField(
          controller: controller.fromPointController,
          onChanged: (_) => controller.updateCurrentSegment(),
          labelText: controller.getDepartureLabel(controller.currentSegmentVehicleType.value),
          hintText: _getDepartureHintText(controller.currentSegmentVehicleType.value),
          prefixIcon: Icon(_getDepartureIcon(controller.currentSegmentVehicleType.value), color: AppColors.primary),
        )),
        const SizedBox(height: 16),
        Obx(() => CustomTextField(
          controller: controller.toPointController,
          onChanged: (_) => controller.updateCurrentSegment(),
          labelText: controller.getArrivalLabel(controller.currentSegmentVehicleType.value),
          hintText: _getArrivalHintText(controller.currentSegmentVehicleType.value),
          prefixIcon: Icon(_getArrivalIcon(controller.currentSegmentVehicleType.value), color: AppColors.primary),
        )),
      ],
    );
  }

  Widget _buildSegmentPrice(int segmentIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: controller.priceController,
          onChanged: (_) {
            controller.updateCurrentSegment();
            Get.forceAppUpdate();
          },
          labelText: "segment_price".tr,
          hintText: "0.00",
          keyboardType: TextInputType.number,
          prefixIcon: Icon(Icons.attach_money, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        const SizedBox(height: 12),
        GetBuilder<CreateTripViewModel>(
          builder: (controller) {
            final price = double.tryParse(controller.priceController.text) ?? 0;
            if (price == 0) return const SizedBox.shrink();

            return _buildCurrencyConversion(CurrencyService.instance.formatPrice(price));
          },
        ),
      ],
    );
  }

  Widget _buildVehicleInfo() {
    return Column(
      children: [
        CustomTextField(
          controller: controller.brandController,
          onChanged: (_) => controller.updateCurrentSegment(),
          labelText: "vehicle_brand".tr,
          hintText: "enter_vehicle_brand".tr,
          prefixIcon: Icon(Icons.branding_watermark_outlined, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: controller.modelController,
          onChanged: (_) => controller.updateCurrentSegment(),
          labelText: "vehicle_model".tr,
          hintText: "enter_vehicle_model".tr,
          prefixIcon: Icon(Icons.directions_car_outlined, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: controller.plateController,
          onChanged: (_) => controller.updateCurrentSegment(),
          labelText: "vehicle_plate".tr,
          hintText: "enter_vehicle_plate".tr,
          prefixIcon: Icon(Icons.confirmation_number_outlined, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildOperatorInfo() {
    return CustomTextField(
      controller: controller.operatorNameController,
      onChanged: (_) => controller.updateCurrentSegment(),
      labelText: "operator_name".tr,
      hintText: "enter_operator_name".tr,
      prefixIcon: Icon(Icons.business_center_outlined, color: AppColors.primary),
    );
  }

  Widget _buildTripSettingsSection(BuildContext context) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "trip_settings".tr,
            style: AppTextStyles.subheading.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildDateTimeField(),
          const SizedBox(height: 20),
          _buildSeatsAndPayment(),
        ],
      ),
    );
  }

  Widget _buildDateTimeField() {
    return GestureDetector(
      onTap: () => controller.selectDateTime(Get.context!),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.dateTime.value == null
                        ? "select_trip_date_time".tr
                        : _formatDateTime(controller.dateTime.value!),
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                      color: controller.dateTime.value == null
                          ? AppColors.grey
                          : AppColors.darkGrey,
                    ),
                  ),
                  if (controller.dateTime.value != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(controller.dateTime.value!),
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
                    ),
                  ],
                ],
              )),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatsAndPayment() {
    return Column(
      children: [
        _buildSeatsSelector(),
        const SizedBox(height: 20),
        _buildPaymentMethod(),
      ],
    );
  }

  Widget _buildSeatsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "seats_available".tr,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: controller.decrementSeats,
                icon: Icon(
                  Icons.remove,
                  color: controller.seatsAvailable.value > 1
                      ? AppColors.primary
                      : AppColors.grey,
                  size: 20,
                ),
              ),
              Obx(() => Text(
                "${controller.seatsAvailable.value}",
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )),
              IconButton(
                onPressed: controller.incrementSeats,
                icon: Icon(
                  Icons.add,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "payment_method".tr,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(8),
            color: AppColors.primary.withOpacity(0.05),
          ),
          child: Row(
            children: [
              Icon(Icons.credit_card, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                "Credit Card",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: "save_draft".tr,
              onPressed: () {},
              type: ButtonType.outlined,
              backgroundColor: Colors.transparent,
              textColor: AppColors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => CustomButton(
              text: "preview_trip".tr,
              onPressed: controller.onPreviewPressed,
              isLoading: controller.isLoading.value,
              icon: Icons.visibility_outlined,
              backgroundColor: AppColors.primary,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyConversion(String convertedPrice) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.currency_exchange, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            "approximately".tr,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
          ),
          const SizedBox(width: 4),
          Text(
            convertedPrice,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteSegmentDialog(int index) {
    Get.dialog(
      AlertDialog(
        title: Text("delete_segment".tr),
        content: Text("are_you_sure_delete_segment".tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("cancel".tr, style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removeSegment(index);
            },
            child: Text("delete".tr, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return "${_formatDate(dateTime)} • ${_formatTime(dateTime)}";
  }

  String _formatDate(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType) {
      case 'Car': return Icons.directions_car;
      case 'Van': return Icons.airport_shuttle;
      case 'SUV': return Icons.agriculture;
      case 'Bus': return Icons.directions_bus;
      case 'Ferry': return Icons.directions_boat;
      case 'Train': return Icons.train;
      default: return Icons.emoji_transportation;
    }
  }

  IconData _getDepartureIcon(String vehicleType) {
    switch (vehicleType) {
      case 'Ferry': return Icons.sailing;
      case 'Bus': return Icons.departure_board;
      case 'Train': return Icons.train;
      default: return Icons.location_on_outlined;
    }
  }

  IconData _getArrivalIcon(String vehicleType) {
    switch (vehicleType) {
      case 'Ferry': return Icons.sailing;
      case 'Bus': return Icons.departure_board;
      case 'Train': return Icons.train;
      default: return Icons.location_on;
    }
  }

  String _getDepartureHintText(String vehicleType) {
    switch (vehicleType) {
      case 'Ferry': return "enter_departure_port".tr;
      case 'Bus': return "enter_bus_station".tr;
      case 'Train': return "enter_train_station".tr;
      default: return "enter_pickup_point".tr;
    }
  }

  String _getArrivalHintText(String vehicleType) {
    switch (vehicleType) {
      case 'Ferry': return "enter_arrival_port".tr;
      case 'Bus': return "enter_bus_stop".tr;
      case 'Train': return "enter_train_station".tr;
      default: return "enter_dropoff_point".tr;
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        "create_trip".tr,
        style: AppTextStyles.heading.copyWith(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
      ),
      actions: [
        Obx(() => controller.segments.isNotEmpty
            ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: Chip(
            label: Text(
              "${controller.segments.length} ${"segments".tr}",
              style: const TextStyle(color: AppColors.primary),
            ),
            backgroundColor: Colors.white.withOpacity(0.2),
          ),
        )
            : const SizedBox()),
      ],
    );
  }
}