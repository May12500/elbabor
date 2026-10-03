import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../app/themes/app_colors.dart';
import '../../../../app/themes/app_text_styles.dart';
import '../../../../data/models/passenger_model.dart';
import '../../../../data/services/currency_service.dart';
import '../viewmodels/trip_detail_viewmodel.dart';

class PassengerItem extends StatefulWidget {
  final PassengerModel passenger;
  final TripDetailViewModel controller;
  final Function(PassengerModel) messagePassenger;
  final Function(PassengerModel) viewPassengerProfile;

  const PassengerItem({
    Key? key,
    required this.passenger,
    required this.controller,
    required this.messagePassenger,
    required this.viewPassengerProfile,
  }) : super(key: key);

  @override
  State<PassengerItem> createState() => _PassengerItemState();
}

class _PassengerItemState extends State<PassengerItem> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  late Animation<double> _opacityAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final passenger = widget.passenger;
    final bookingDate = widget.controller.getBookingDate(passenger.uid);
    final seatNumbers = widget.controller.getSeatNumbers(passenger.uid);
    final totalSeatsBooked = widget.controller.getTotalSeatsBooked(passenger.uid);
    final paymentMethods = widget.controller.getPaymentMethods(passenger.uid);
    final totalAmount = widget.controller.getTotalAmount(passenger.uid);
    final bookingStatus = widget.controller.getBookingStatus(passenger.uid);
    final hasPaid = widget.controller.hasPassengerPaid(passenger.uid);

    final contactInfo = passenger.phoneNumber ?? passenger.email;
    final contactIcon = passenger.phoneNumber != null ? Icons.phone : Icons.email;
    final contactType = passenger.phoneNumber != null ? "phone".tr : "email".tr;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Compact Header (Always Visible)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.2),
                            AppColors.primary.withOpacity(0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                        image: passenger.photoUrl != null
                            ? DecorationImage(
                          image: NetworkImage(passenger.photoUrl!),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: passenger.photoUrl == null
                          ? Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 24,
                      )
                          : null,
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Essential Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              passenger.name.isNotEmpty ? passenger.name : "Passenger",
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _getStatusColor(bookingStatus).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              bookingStatus.tr.capitalizeFirst!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: _getStatusColor(bookingStatus),
                                fontWeight: FontWeight.w600,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            contactIcon,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              contactInfo,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.event_seat_outlined,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "$totalSeatsBooked ${'seats'.tr}",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          if (totalAmount > 0)
                            Row(
                              children: [
                                Icon(
                                  hasPaid ? Icons.check_circle : Icons.pending,
                                  size: 12,
                                  color: hasPaid ? AppColors.success : AppColors.warning,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  CurrencyService.instance.formatPrice(totalAmount),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: hasPaid ? AppColors.success : AppColors.warning,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Expand/Collapse Button
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _toggleExpansion,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: _isExpanded ? 0.5 : 0.0,
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Expandable Details Section
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  heightFactor: _heightAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: child,
                  ),
                ),
              );
            },
            child: Column(
              children: [
                const Divider(height: 1),

                // Detailed Information
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Booking Date & Contact Type
                      Row(
                        children: [
                          Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.info.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 12,
                                    color: AppColors.info,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'booked_on'.tr,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const Spacer(),
                          if (bookingDate != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _formatBookingDate(bookingDate),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.info,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Seats Information
                      if (seatNumbers.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.event_seat_outlined,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${'seat_numbers'.tr}:",
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 2,
                                      children: seatNumbers.map((seat) =>
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(
                                                color: AppColors.primary.withOpacity(0.2),
                                              ),
                                            ),
                                            child: Text(
                                              seat.toString(),
                                              style: AppTextStyles.bodySmall.copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                      ).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Payment Details
                      if (totalAmount > 0) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: hasPaid ? AppColors.success.withOpacity(0.05) : AppColors.warning.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: hasPaid ? AppColors.success : AppColors.warning,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  hasPaid ? Icons.check_circle_outline : Icons.payment_outlined,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hasPaid ? "payment_completed".tr : "payment_pending".tr,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: hasPaid ? AppColors.success : AppColors.warning,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          "${CurrencyService.instance.formatPrice(totalAmount)}",
                                          style: AppTextStyles.body.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        if (paymentMethods.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.info.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              paymentMethods.join(', '),
                                              style: AppTextStyles.bodySmall.copyWith(
                                                color: AppColors.info,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 9,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),

                // Action Buttons
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBackground,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Message Button
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.9),
                                AppColors.primary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => widget.messagePassenger(passenger),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.message_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "message".tr,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // View Profile Button
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => widget.viewPassengerProfile(passenger),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_outline_rounded,
                                      color: AppColors.primary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "view_profile".tr,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  String _formatBookingDate(DateTime date) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    return "${dateFormat.format(date)} at ${timeFormat.format(date)}";
  }
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft' || 'pending':
        return AppColors.warning;
      case 'active' || 'confirmed':
        return AppColors.success;
      case 'scheduled':
        return AppColors.info;
      case 'completed':
        return AppColors.primary;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

}
