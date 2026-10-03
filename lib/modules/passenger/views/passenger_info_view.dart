import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../app/themes/app_text_styles.dart';
import '../../../../app/widgets/custom_button.dart';
import '../../../../app/widgets/custom_loader.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/passenger_model.dart';
import '../../../data/services/currency_service.dart';
import '../viewmodels/passenger_info_viewmodel.dart';

class PassengerInfoView extends GetView<PassengerInfoViewModel> {
  const PassengerInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("passenger_profile".tr, style: AppTextStyles.heading.copyWith(color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16)),
          child: IconButton(onPressed: (){Get.back();}, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return CustomLoader(message: "loading_passenger".tr);
        }

        final passenger = controller.passenger.value;
        if (passenger == null) {
          return _buildErrorState();
        }

        return CustomScrollView(
          slivers: [
            // Passenger Header Section
            SliverToBoxAdapter(
              child: _buildPassengerHeader(passenger),
            ),

            // Passenger Stats Section
            SliverToBoxAdapter(
              child: _buildPassengerStats(),
            ),

            // About Section
            SliverToBoxAdapter(
              child: _buildAboutSection(passenger),
            ),

            // Recent Bookings Section
            SliverToBoxAdapter(
              child: _buildRecentBookings(controller.bookings),
            ),

            // Action Buttons - Only Message Button
            SliverToBoxAdapter(
              child: _buildMessageButton(),
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
            "passenger_not_found".tr,
            style: AppTextStyles.heading.copyWith(
              color: AppColors.textSecondary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "passenger_not_found_desc".tr,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerHeader(PassengerModel passenger) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Passenger Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
            ),
            child: ClipOval(
              child: passenger.photoUrl != null
                  ? Image.network(passenger.photoUrl!, fit: BoxFit.cover)
                  : Container(
                color: Colors.white.withOpacity(0.2),
                child: Icon(Icons.person, color: Colors.white, size: 40),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Passenger Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  passenger.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Bookings Count
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${controller.totalBookings} ${'bookings'.tr}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Join Date
                if (passenger.createdAt != null)
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.7), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "joined".tr + " " + DateFormat('MMM yyyy').format(passenger.createdAt!),
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

  Widget _buildPassengerStats() {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.check_circle,
            value: controller.completedBookings.toString(),
            label: "completed".tr,
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.pending,
            value: controller.pendingBookings.toString(),
            label: "pending".tr,
            color: Colors.orange,
          ),
          _buildStatItem(
            icon: Icons.cancel,
            value: controller.cancelledBookings.toString(),
            label: "cancelled".tr,
            color: Colors.red,
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

  Widget _buildAboutSection(PassengerModel passenger) {
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
              Icon(Icons.info_outline, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              Text(
                "about_passenger".tr,
                style: AppTextStyles.heading.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Contact Info
          _buildAboutItem(Icons.phone, "phone".tr, passenger.phoneNumber ?? 'Not provided'),
          _buildAboutItem(Icons.email, "email".tr, passenger.email),
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

  Widget _buildRecentBookings(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
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
              Icons.assignment,
              size: 60,
              color: AppColors.secondary.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              "no_recent_bookings".tr,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "no_recent_bookings_desc".tr,
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
                Icon(Icons.history, color: AppColors.secondary, size: 20),
                const SizedBox(width: 8),
                Text(
                  "recent_bookings".tr,
                  style: AppTextStyles.heading.copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
          ...bookings.take(3).map((booking) => _buildBookingCard(booking)).toList(),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final statusData = _getBookingStatusData(booking.status.name);
    final formattedDate = DateFormat('EEE, MMM dd').format(booking.createdAt);
    final formattedTime = DateFormat('hh:mm a').format(booking.createdAt);

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
          onTap: () => _viewBookingDetails(booking),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Status Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusData.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(statusData.icon, color: statusData.color, size: 20),
                ),
                const SizedBox(width: 12),

                // Booking Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${booking.fromCity} → ${booking.destinationCity}",
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
                      const SizedBox(height: 4),
                      Text(
                        statusData.label,
                        style: AppTextStyles.caption.copyWith(
                          color: statusData.color,
                          fontWeight: FontWeight.w600,
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
                      CurrencyService.instance.formatPrice(booking.price),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${booking.seatsBooked} ${'seats'.tr}",
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

  Widget _buildMessageButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: CustomButton(
        text: "message_passenger".tr,
        onPressed: () => Get.find<PassengerInfoViewModel>().onMessagePassenger(),
        backgroundColor: AppColors.secondary,
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
              "message_passenger".tr,
              style: const TextStyle(
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

  void _viewBookingDetails(BookingModel booking) {
    // Navigate to booking details
    Get.toNamed('/driver-booking-detail', arguments: booking);
  }

  _BookingStatusData _getBookingStatusData(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return _BookingStatusData(Icons.check_circle, Colors.green, "confirmed".tr);
      case 'pending':
        return _BookingStatusData(Icons.pending, Colors.orange, "pending".tr);
      case 'cancelled':
        return _BookingStatusData(Icons.cancel, Colors.red, "cancelled".tr);
      case 'completed':
        return _BookingStatusData(Icons.verified, Colors.blue, "completed".tr);
      default:
        return _BookingStatusData(Icons.pending, AppColors.warning, status);
    }
  }
}

class _BookingStatusData {
  final IconData icon;
  final Color color;
  final String label;
  _BookingStatusData(this.icon, this.color, this.label);
}