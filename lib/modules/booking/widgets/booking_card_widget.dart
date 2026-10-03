import 'package:elbabor/data/services/currency_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../data/models/booking_model.dart';
import '../../booking/view/booking_detail_view.dart';
import '../../passenger/viewmodels/passenger_booking_viewmodel.dart';

class BookingCard extends StatelessWidget {
  final BookingGroup bookingGroup;

  const BookingCard({required this.bookingGroup});

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.reserved:
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.completed:
        return Colors.blue;
      case BookingStatus.cancelled:
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  Color _getPaymentColor(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return Colors.green;
      case 'card':
        return Colors.blue;
      case 'wallet':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'bus':
        return Icons.directions_bus;
      case 'train':
        return Icons.train;
      case 'ferry':
        return Icons.directions_boat;
      case 'airplane':
        return Icons.flight;
      default:
        return Icons.directions_car;
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = bookingGroup.bookings.first;
    final totalSeats = bookingGroup.totalSeats;
    final totalPrice = bookingGroup.totalPrice;
    final formattedDate = DateFormat('MMM dd, yyyy').format(booking.tripDateTime);
    final formattedTime = DateFormat('hh:mm a').format(booking.tripDateTime);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.to(() => BookingDetailPage(), arguments: bookingGroup),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with route and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${bookingGroup.fromCity} → ${bookingGroup.destinationCity}',
                            style: AppTextStyles.heading.copyWith(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (bookingGroup.departurePoint.isNotEmpty)
                            Text(
                              bookingGroup.departurePoint,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(booking.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getStatusColor(booking.status)),
                      ),
                      child: Text(
                        booking.status.name.capitalizeFirst!,
                        style: TextStyle(
                          color: _getStatusColor(booking.status),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Trip date and time
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      formattedDate,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      formattedTime,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Vehicle and booking details
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getVehicleIcon(bookingGroup.vehicleType),
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${bookingGroup.vehicle.brand} ${bookingGroup.vehicle.model} • ${bookingGroup.vehicleType}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Booking details in a grid
                Row(
                  children: [
                    _buildDetailItem(
                      icon: Icons.event_seat,
                      value: '$totalSeats ${'seats'.tr}',
                      color: AppColors.primary,
                    ),
                    _buildDetailItem(
                      icon: Icons.money,
                      value: ' ${CurrencyService.instance.formatPrice(totalPrice)}',
                      color: Colors.green,
                    ),
                    _buildDetailItem(
                      icon: Icons.payment,
                      value: booking.paymentMethod.name.capitalizeFirst!,
                      color: _getPaymentColor(booking.paymentMethod.name),
                    ),
                  ],
                ),

                // Multiple bookings indicator - only show if same status
                if (bookingGroup.bookings.length > 1 && !bookingGroup.hasMixedStatus)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.group, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${bookingGroup.bookings.length} ${'bookings_combined'.tr}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({required IconData icon, required String value, required Color color}) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}