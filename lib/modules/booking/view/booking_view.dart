import 'package:elbabor/app/themes/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../data/services/currency_service.dart';
import '../../common/widgets/common_text_field.dart';
import '../../common/widgets/primary_button.dart';
import '../../../data/models/trip_model.dart';
import '../viewmodel/booking_viewmodel.dart';

class BookingView extends GetView<BookingViewModel> {
  const BookingView({super.key});

  @override
  Widget build(BuildContext context) {
    final TripModel trip = Get.arguments as TripModel;
    final controller = Get.put(BookingViewModel(trip));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "book_now".tr,
          style: AppTextStyles.heading.copyWith(color: Colors.white),
        ),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
      body: StreamBuilder<Map<String, List<int>>>(
        stream: controller.getSeatStream(),
        builder: (context, snapshot) {
          final reserved = snapshot.data ?? [];

          return LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxHeight < 700;
              final isVerySmallScreen = constraints.maxHeight < 600;

              return CustomScrollView(
                slivers: [
                  // Responsive SliverAppBar height
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.white,
                    elevation: 4,
                    expandedHeight: _getAppBarHeight(
                      constraints.maxHeight,
                      trip.hasMultipleSegments,
                    ),
                    flexibleSpace: LayoutBuilder(
                      builder: (context, constraints) {
                        final isExpanded = constraints.biggest.height > 100;
                        return FlexibleSpaceBar(
                          collapseMode: CollapseMode.pin,
                          title: isExpanded ? null : _buildCollapsedTitle(trip),
                          background: _buildExpandedTripSummary(trip, isSmallScreen),
                        );
                      },
                    ),
                    pinned: true,
                    floating: false,
                    snap: false,
                  ),

                  // Main content with responsive padding
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Passenger Information Section
                            _buildPassengerInfoSection(controller, isSmallScreen),
                            SizedBox(height: isSmallScreen ? 16 : 24),

                            // Seat Selection Section
                            _buildSeatSelectionSection(controller, isSmallScreen),
                            SizedBox(height: isSmallScreen ? 16 : 24),

                            // Payment Section
                            _buildPaymentSection(controller, isSmallScreen),
                            SizedBox(height: isSmallScreen ? 16 : 24),

                            // Booking Summary
                            _buildBookingSummary(controller, trip, isSmallScreen),
                            SizedBox(height: isSmallScreen ? 20 : 30),

                            // Confirm Button
                            _buildConfirmButton(controller, isSmallScreen),
                            SizedBox(height: isSmallScreen ? 20 : 40),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  double _getAppBarHeight(double screenHeight, bool hasMultipleSegments) {
    print("Screen Height: $screenHeight");
    if (screenHeight < 600) {
      return hasMultipleSegments ? 240 : 200; // Very small screens
    } else if (screenHeight < 700) {
      return hasMultipleSegments ? 280 : 240; // Small screens
    } else if (screenHeight < 800) {
      return hasMultipleSegments ? 320 : 280; // Medium screens
    } else {
      return hasMultipleSegments ?450 : 320; // Large screens
    }
  }

  Widget _buildExpandedTripSummary(TripModel trip, bool isSmallScreen) {
    final primarySegment = trip.segments.first;
    IconData vehicleIcon;
    Color vehicleColor;

    switch (primarySegment.vehicleType.toLowerCase()) {
      case 'ferry':
        vehicleIcon = Icons.directions_boat;
        vehicleColor = Colors.blueAccent;
        break;
      case 'bus':
        vehicleIcon = Icons.directions_bus;
        vehicleColor = Colors.orangeAccent;
        break;
      default:
        vehicleIcon = Icons.directions_car;
        vehicleColor = AppColors.primary;
    }

    return SingleChildScrollView( // Added ScrollView to prevent overflow
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.08),
                AppColors.primary.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
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
            mainAxisSize: MainAxisSize.min, // Important: Use min to prevent overflow
            children: [
              // Header with title and seats badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        Icon(
                          trip.hasMultipleSegments ? Icons.connecting_airports : Icons.trip_origin,
                          color: AppColors.primary,
                          size: isSmallScreen ? 18 : 20,
                        ),
                        SizedBox(width: isSmallScreen ? 6 : 8),
                        Flexible(
                          child: Text(
                            "trip_summary".tr,
                            style: Get.textTheme.titleMedium!.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 16 : 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 8 : 12,
                      vertical: isSmallScreen ? 4 : 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      "${trip.seatsAvailable} ${"seats_available".tr}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 10 : 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: isSmallScreen ? 12 : 16),

              // Multi-segment indicator
              if (trip.hasMultipleSegments)
                Padding(
                  padding: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 6 : 8,
                          vertical: isSmallScreen ? 3 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.airline_stops,
                                size: isSmallScreen ? 12 : 14,
                                color: AppColors.info),
                            SizedBox(width: isSmallScreen ? 3 : 4),
                            Text(
                              "${trip.segments.length} ${'segments'.tr}",
                              style: TextStyle(
                                color: AppColors.info,
                                fontSize: isSmallScreen ? 10 : 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      Flexible(
                        child: Text(
                          trip.vehicleTypesUsed.join(' → '),
                          style: Get.textTheme.bodySmall!.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                            fontSize: isSmallScreen ? 10 : 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

              // Route visualization with conditional sizing
              if (trip.hasMultipleSegments)
                _buildMultiSegmentRoute(trip, isSmallScreen)
              else
                _buildSingleSegmentRoute(trip, vehicleIcon, vehicleColor, isSmallScreen),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMultiSegmentRoute(TripModel trip, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Start point
          _buildRoutePoint(
            trip.segments.first.fromCity,
            trip.segments.first.fromPoint,
            Icons.location_on,
            Colors.green,
            isSmallScreen,
          ),
          // Middle segments
          ...trip.segments.asMap().entries.map((entry) {
            final index = entry.key;
            final segment = entry.value;
            final isLast = index == trip.segments.length - 1;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSegmentConnector(segment.vehicleType, isSmallScreen),
                if (!isLast)
                  _buildRoutePoint(
                    segment.toCity,
                    segment.toPoint,
                    Icons.transfer_within_a_station,
                    Colors.orange,
                    isSmallScreen,
                    isTransfer: true,
                  ),
              ],
            );
          }).toList(),


          // End point
          _buildRoutePoint(
            trip.segments.last.toCity,
            trip.segments.last.toPoint,
            Icons.flag,
            Colors.red,
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildRoutePoint(String city, String point, IconData icon, Color color,
      bool isSmallScreen, {bool isTransfer = false}) {
    return Row(
      children: [
        Container(
          width: isSmallScreen ? 16 : 20,
          height: isSmallScreen ? 16 : 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: isSmallScreen ? 8 : 10),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                city,
                style: Get.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (point.isNotEmpty)
                Text(
                  point,
                  style: Get.textTheme.bodySmall!.copyWith(
                    color: Colors.grey[600],
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentConnector(String vehicleType, bool isSmallScreen) {
    IconData vehicleIcon;
    Color vehicleColor;

    switch (vehicleType.toLowerCase()) {
      case 'ferry':
        vehicleIcon = Icons.directions_boat;
        vehicleColor = Colors.blueAccent;
        break;
      case 'bus':
        vehicleIcon = Icons.directions_bus;
        vehicleColor = Colors.orangeAccent;
        break;
      default:
        vehicleIcon = Icons.directions_car;
        vehicleColor = AppColors.primary;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 2 : 4),
      child: Row(
        children: [
          SizedBox(width: isSmallScreen ? 8 : 10),
          Container(
            width: 2,
            height: isSmallScreen ? 16 : 20,
            color: Colors.grey[300],
          ),
          SizedBox(width: isSmallScreen ? 6 : 8),
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 3 : 4),
            decoration: BoxDecoration(
              color: vehicleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isSmallScreen ? 4 : 6),
            ),
            child: Icon(vehicleIcon, color: vehicleColor, size: isSmallScreen ? 10 : 12),
          ),
          SizedBox(width: isSmallScreen ? 6 : 8),
          Expanded(
            child: Container(
              height: 1,
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleSegmentRoute(TripModel trip, IconData vehicleIcon, Color vehicleColor, bool isSmallScreen) {
    final segment = trip.segments.first;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // From location
          Row(
            children: [
              Container(
                width: isSmallScreen ? 10 : 12,
                height: isSmallScreen ? 10 : 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 5 : 6),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      segment.fromCity,
                      style: Get.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (segment.fromPoint.isNotEmpty)
                      Text(
                        segment.fromPoint,
                        style: Get.textTheme.bodySmall!.copyWith(
                          color: Colors.grey[600],
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Connecting line with vehicle icon
          Padding(
            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 2 : 4),
            child: Row(
              children: [
                SizedBox(width: isSmallScreen ? 4 : 5),
                Container(
                  width: 2,
                  height: isSmallScreen ? 16 : 20,
                  color: Colors.grey[300],
                  margin: EdgeInsets.only(left: isSmallScreen ? 4 : 5),
                ),
                SizedBox(width: isSmallScreen ? 4 : 5),
                Icon(vehicleIcon, color: vehicleColor, size: isSmallScreen ? 14 : 16),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),

          // To location
          Row(
            children: [
              Container(
                width: isSmallScreen ? 10 : 12,
                height: isSmallScreen ? 10 : 12,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 5 : 6),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      segment.toCity,
                      style: Get.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (segment.toPoint.isNotEmpty)
                      Text(
                        segment.toPoint,
                        style: Get.textTheme.bodySmall!.copyWith(
                          color: Colors.grey[600],
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildCollapsedTitle(TripModel trip) {
    // Get primary vehicle icon and color from first segment
    final primarySegment = trip.segments.first;
    IconData vehicleIcon;
    Color vehicleColor;

    switch (primarySegment.vehicleType.toLowerCase()) {
      case 'ferry':
        vehicleIcon = Icons.directions_boat;
        vehicleColor = Colors.blueAccent;
        break;
      case 'bus':
        vehicleIcon = Icons.directions_bus;
        vehicleColor = Colors.orangeAccent;
        break;
      default:
        vehicleIcon = Icons.directions_car;
        vehicleColor = AppColors.primary;
    }

    final formattedTime = _formatTime(trip.dateTime);

    return Container(
      color: Colors.white,
      child: Row(
        children: [
          // Vehicle icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: vehicleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
                trip.hasMultipleSegments ? Icons.connecting_airports : vehicleIcon,
                color: vehicleColor,
                size: 16
            ),
          ),
          const SizedBox(width: 8),

          // Route info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${trip.fromCity} → ${trip.destinationCity}",
                  style: Get.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "$formattedTime • ${CurrencyService.instance.formatPrice(trip.totalPrice)}",
                  style: Get.textTheme.bodySmall!.copyWith(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // if (trip.hasMultipleSegments)
                //   Text(
                //     "${trip.segments.length} ${'segments'.tr}",
                //     style: Get.textTheme.bodySmall!.copyWith(
                //       color: AppColors.info,
                //       fontSize: 10,
                //     ),
                //   ),
              ],
            ),
          ),

          // Seats available
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "${trip.seatsAvailable}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  Widget _buildPassengerInfoSection(BookingViewModel controller, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "passenger_information".tr,
          style: Get.textTheme.titleMedium!.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 16 : 18,
          ),
        ),
        SizedBox(height: isSmallScreen ? 2 : 4),
        Text(
          "fill_passenger_details".tr,
          style: Get.textTheme.bodySmall!.copyWith(
            color: Colors.grey[600],
            fontSize: isSmallScreen ? 12 : 14,
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        CommonTextField(
          controller: controller.nameController,
          label: "full_name".tr,
          prefixIcon: Icons.person_outline,
          onChanged: (v) {},
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        CommonTextField(
          controller: controller.emailController,
          label: "email_address".tr,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          onChanged: (v) {},
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        CommonTextField(
          controller: controller.phoneController,
          label: "phone_number".tr,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          onChanged: (v) {},
        ),
      ],
    );
  }

  Widget _buildSeatSelectionSection(BookingViewModel controller, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "select_seat".tr,
              style: Get.textTheme.titleMedium!.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Obx(() => Text(
              "${controller.selectedSeats.length} ${"selected".tr}",
              style: Get.textTheme.bodyMedium!.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            )),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "tap_to_select_deseat".tr,
          style: Get.textTheme.bodySmall!.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        _buildSeatGrid(controller),
        const SizedBox(height: 12),
        _buildSeatLegend(),
      ],
    );
  }

  Widget _buildSeatGrid(BookingViewModel controller) {
    final totalSeats = controller.trip.totalSeats ?? 8;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: GridView.builder(
        itemCount: totalSeats,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (_, index) {
          final seatNumber = index + 1;

          return Obx(() {
            final seatStatus = controller.getSeatStatus(seatNumber);

            Color color;
            Color textColor;
            Color borderColor;
            String label;
            Widget? statusIcon;

            switch (seatStatus) {
              case SeatStatus.available:
                color = AppColors.success.withOpacity(0.1);
                textColor = AppColors.success;
                borderColor = AppColors.success;
                label = "available".tr;
                statusIcon = Icon(Icons.event_seat, color: AppColors.success, size: 16);
                break;

              case SeatStatus.reserved:
                color = AppColors.warning.withOpacity(0.1);
                textColor = AppColors.warning;
                borderColor = AppColors.warning;
                label = "reserved".tr;
                statusIcon = Icon(Icons.access_time, color: AppColors.warning, size: 16);
                break;

              case SeatStatus.selected:
                color = AppColors.primary;
                textColor = Colors.white;
                borderColor = AppColors.primary;
                label = "selected".tr;
                statusIcon = Icon(Icons.check, color: Colors.white, size: 16);
                break;

              case SeatStatus.unavailable:
                color = AppColors.error.withOpacity(0.1); // CHANGED: Use error color for booked seats
                textColor = AppColors.error;
                borderColor = AppColors.error;
                label = "booked".tr; // CHANGED: Label as "booked"
                statusIcon = Icon(Icons.block, color: AppColors.error, size: 16);
                break;
            }

            return GestureDetector(
              onTap: seatStatus == SeatStatus.available || seatStatus == SeatStatus.selected
                  ? () => controller.toggleSeat(seatNumber)
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: borderColor,
                    width: seatStatus == SeatStatus.selected ? 2 : 1,
                  ),
                  boxShadow: seatStatus == SeatStatus.selected ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ] : null,
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Status Icon
                    if (statusIcon != null) ...[
                      statusIcon,
                      const SizedBox(height: 2),
                    ],

                    // Seat Number
                    Text(
                      "$seatNumber",
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    // Status Label
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildSeatLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(
            AppColors.success.withOpacity(0.1),
            AppColors.success,
            "available".tr
        ),
        _buildLegendItem(
            AppColors.primary,
            AppColors.primary,
            "selected".tr
        ),
        _buildLegendItem(
            AppColors.warning.withOpacity(0.1),
            AppColors.warning,
            "reserved".tr
        ),
        _buildLegendItem(
            AppColors.error.withOpacity(0.1), // CHANGED: Use error color
            AppColors.error,
            "booked".tr // CHANGED: Label as "booked"
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, Color textColor, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: textColor),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 10,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection(BookingViewModel controller, isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "select_payment".tr,
          style: Get.textTheme.titleMedium!.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "choose_payment_method".tr,
          style: Get.textTheme.bodySmall!.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        _buildPaymentOptions(controller),
      ],
    );
  }

  Widget _buildPaymentOptions(BookingViewModel controller,) {
    return Obx(() {
      final availableMethods = controller.availablePaymentMethods;

      return Column(
        children: availableMethods.map((methodId) {
          final isSelected = controller.selectedPayment.value == methodId;
          final displayName = controller.getPaymentMethodDisplayName(methodId);
          final icon = _getPaymentMethodIcon(methodId);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => controller.selectPayment(methodId),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: isSelected ? AppColors.primary : Colors.grey[600],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primary : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildBookingSummary(BookingViewModel controller, TripModel trip,isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Text(
            "booking_summary".tr,
            style: Get.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Column(
            children: [
              _buildSummaryRow("seats_selected".tr, "${controller.selectedSeats.length}"),
              _buildSummaryRow("price_per_seat".tr, CurrencyService.instance.formatPrice(trip.totalPrice)),
              const Divider(),
              _buildSummaryRow(
                "total_amount".tr,
                CurrencyService.instance.formatPrice((trip.totalPrice * controller.selectedSeats.length)),
                isTotal: true,
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? AppColors.primary : Colors.black87,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BookingViewModel controller, bool isSmallScreen) {
    return Obx(() {
      final noSeatsLeft = controller.availableSeatsCount <= 0;
      final noSeatsSelected = controller.selectedSeats.isEmpty;
      final isProcessingPayment = controller.isProcessingPayment.value;
      final hasReservationConflict = controller.validateSeatSelection() != null;

      String buttonText;
      Color? buttonColor;
      bool isEnabled = true;

      if (isProcessingPayment) {
        buttonText = "processing_payment".tr;
        isEnabled = false;
      } else if (controller.isLoading.value) {
        buttonText = "processing".tr;
        isEnabled = false;
      } else if (noSeatsLeft) {
        buttonText = "no_seats_available".tr;
        isEnabled = false;
      } else if (noSeatsSelected) {
        buttonText = "select_seats_first".tr;
        isEnabled = false;
      } else if (hasReservationConflict) {
        buttonText = "seats_no_longer_available".tr;
        isEnabled = false;
        buttonColor = AppColors.error;
      } else {
        buttonText = "book_now".tr; // Changed text
        isEnabled = true;
      }

      return PrimaryButton(
        label: buttonText,
        onPressed: isEnabled ? controller.confirmBooking : null,
        loading: controller.isProcessingPayment.value || controller.isLoading.value,
        backgroundColor: buttonColor,
      );
    });
  }
  // Helper method to get appropriate icons for each payment method
  IconData _getPaymentMethodIcon(String methodId) {
    switch (methodId) {
      case 'cash':
        return Icons.money_outlined;
      case 'stripe_card':
        return Icons.credit_card_outlined;
      case 'google_pay':
        return Icons.phone_android_outlined; // Google Pay icon
      case 'jazz_cash':
        return Icons.phone_iphone_outlined; // Mobile money icon
      case 'easy_paisa':
        return Icons.account_balance_wallet_outlined; // Wallet icon
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.payment_outlined;
    }
  }
}