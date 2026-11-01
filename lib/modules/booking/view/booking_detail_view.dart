import 'package:elbabor/data/services/currency_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../app/widgets/appbar_icon_button_widget.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/services/booking_share_service.dart';

class BookingDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bookingGroup = Get.arguments as BookingGroup;
    final primaryBooking = bookingGroup.bookings.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('booking_details'.tr, style: AppTextStyles.heading.copyWith(color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: AppBarIconButton(
          icon: Icons.arrow_back_ios,
          onPressed: () => Get.back(),
        ),
        actions: [
          AppBarIconButton(
            icon: Icons.share,
            onPressed: () => _shareBookingDetails(bookingGroup),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Booking Status Card
            _buildStatusCard(primaryBooking),
            const SizedBox(height: 20),

            // Trip Information
            _buildTripInfoCard(bookingGroup),
            const SizedBox(height: 20),

            // Booking Details
            _buildBookingDetailsCard(bookingGroup),
            const SizedBox(height: 20),

            // Payment Information
            _buildPaymentCard(bookingGroup),
            const SizedBox(height: 20),

            // Multiple Bookings Section (if applicable)
            if (bookingGroup.bookings.length > 1) ...[
              _buildMultipleBookingsCard(bookingGroup),
              const SizedBox(height: 20),
            ],

            // Actions
            _buildActionButtons(bookingGroup),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BookingModel booking) {
    final statusColor = _getStatusColor(booking.status);
    final statusIcon = _getStatusIcon(booking.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'booking_status'.tr,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.status.name.capitalizeFirst!,
                  style: AppTextStyles.heading.copyWith(
                    color: statusColor,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getStatusText(booking.status),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfoCard(BookingGroup bookingGroup) {
    final formattedDate = DateFormat('EEEE, MMMM dd, yyyy').format(bookingGroup.tripDateTime);
    final formattedTime = DateFormat('hh:mm a').format(bookingGroup.tripDateTime);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trip_origin, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'trip_information'.tr,
                style: AppTextStyles.heading.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Route Visualization
          _buildRouteVisualization(bookingGroup),
          const SizedBox(height: 16),

          // Trip Details
          Row(
            children: [
              _buildTripDetailItem(
                icon: Icons.calendar_today,
                label: 'date'.tr,
                value: formattedDate,
                color: Colors.blue,
              ),
              _buildTripDetailItem(
                icon: Icons.access_time,
                label: 'time'.tr,
                value: formattedTime,
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Vehicle Information
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getVehicleIcon(bookingGroup.vehicleType),
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${bookingGroup.vehicle.brand} ${bookingGroup.vehicle.model}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${bookingGroup.vehicleType} • ${bookingGroup.vehicle.plate}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
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

  Widget _buildRouteVisualization(BookingGroup bookingGroup) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // From location
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(7),
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookingGroup.fromCity,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (bookingGroup.departurePoint.isNotEmpty)
                      Text(
                        bookingGroup.departurePoint,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Connecting line
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 6),
                Container(
                  width: 2,
                  height: 20,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.only(left: 6),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_downward, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
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
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(7),
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookingGroup.destinationCity,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (bookingGroup.arrivalPoint.isNotEmpty)
                      Text(
                        bookingGroup.arrivalPoint,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
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

  Widget _buildTripDetailItem({required IconData icon, required String label, required String value, required Color color}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsCard(BookingGroup bookingGroup) {
    final primaryBooking = bookingGroup.bookings.first;
    final formattedCreatedAt = DateFormat('MMM dd, yyyy • hh:mm a').format(primaryBooking.createdAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.confirmation_number, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'booking_details'.tr,
                style: AppTextStyles.heading.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Booking ID and Trip ID
          _buildDetailRow('booking_id'.tr, primaryBooking.id.substring(0, 8)),
          _buildDetailRow('trip_id'.tr, primaryBooking.tripId.substring(0, 8)),

          const SizedBox(height: 12),

          // Seats Information
          Row(
            children: [
              Expanded(
                child: _buildDetailCard(
                  icon: Icons.event_seat,
                  label: 'seats_booked'.tr,
                  value: bookingGroup.totalSeats.toString(),
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailCard(
                  icon: Icons.numbers,
                  label: 'seat_numbers'.tr,
                  value: bookingGroup.bookings.expand((b) => b.seatNumbers).join(", "),
                  color: Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Booking Date
          _buildDetailRow('booked_on'.tr, formattedCreatedAt),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(BookingGroup bookingGroup) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'payment_information'.tr,
                style: AppTextStyles.heading.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Total Amount (always accurate)
          Row(
            children: [
              Expanded(
                child: _buildDetailCard(
                  icon: Icons.attach_money,
                  label: 'total_amount'.tr,
                  value: CurrencyService.instance.formatPrice(bookingGroup.totalPrice),
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              // Payment Method - shows appropriate info based on multiple methods
              Expanded(
                child: _buildPaymentMethodCard(bookingGroup),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Payment Status - handles mixed payment statuses
          _buildPaymentStatusRow(bookingGroup),

          // Show payment breakdown if multiple payment methods used
          if (bookingGroup.paymentMethodsUsed.length > 1)
            _buildPaymentBreakdown(bookingGroup),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(BookingGroup bookingGroup) {
    if (bookingGroup.hasSinglePaymentMethod) {
      // Single payment method - show normally
      final paymentMethod = bookingGroup.paymentMethodsUsed.first;
      return _buildDetailCard(
        icon: _getPaymentIcon(paymentMethod.name),
        label: 'payment_method'.tr,
        value: _getPaymentMethodDisplayName(paymentMethod.name),
        color: _getPaymentColor(paymentMethod.name),
      );
    } else {
      // Multiple payment methods - show summary
      return _buildDetailCard(
        icon: Icons.payment,
        label: 'payment_methods'.tr,
        value: '${bookingGroup.paymentMethodsUsed.length} ${'methods'.tr}',
        color: AppColors.primary,
        showInfo: true,
        onInfoTap: () => _showPaymentMethodsDialog(bookingGroup),
      );
    }
  }

  Widget _buildPaymentStatusRow(BookingGroup bookingGroup) {
    Color statusColor;
    String statusText;

    if (bookingGroup.allPaid) {
      statusColor = Colors.green;
      statusText = 'paid'.tr;
    } else if (bookingGroup.somePaid) {
      statusColor = Colors.orange;
      statusText = 'partially_paid'.tr;
    } else {
      statusColor = Colors.red;
      statusText = 'pending_payment'.tr;
    }

    return Row(
      children: [
        Text(
          'payment_status'.tr,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor),
          ),
          child: Row(
            children: [
              Icon(
                bookingGroup.allPaid ? Icons.check_circle :
                bookingGroup.somePaid ? Icons.pending : Icons.schedule,
                color: statusColor,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentBreakdown(BookingGroup bookingGroup) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'payment_breakdown'.tr,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...bookingGroup.paymentBreakdown.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    _getPaymentIcon(entry.key.name),
                    color: _getPaymentColor(entry.key.name),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getPaymentMethodDisplayName(entry.key.name),
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                  Text(
                    CurrencyService.instance.formatPrice(entry.value),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

// Helper method to show payment methods dialog
  void _showPaymentMethodsDialog(BookingGroup bookingGroup) {
    Get.dialog(
      AlertDialog(
        title: Text('payment_methods_used'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...bookingGroup.paymentBreakdown.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      _getPaymentIcon(entry.key.name),
                      color: _getPaymentColor(entry.key.name),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getPaymentMethodDisplayName(entry.key.name),
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    Text(
                      CurrencyService.instance.formatPrice(entry.value),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('close'.tr),
          ),
        ],
      ),
    );
  }

// Helper method for payment method display names
  String _getPaymentMethodDisplayName(String method) {
    switch (method) {
      case 'stripeCard': return 'credit_card'.tr;
      case 'googlePay': return 'google_pay'.tr;
      case 'jazzCash': return 'jazz_cash'.tr;
      case 'easyPaisa': return 'easy_paisa'.tr;
      case 'cash': return 'cash'.tr;
      case 'wallet': return 'wallet'.tr;
      default: return method.capitalizeFirst ?? method;
    }
  }

  Widget _buildMultipleBookingsCard(BookingGroup bookingGroup) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.group, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'multiple_bookings'.tr,
                style: AppTextStyles.heading.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            '${'total_bookings'.tr}: ${bookingGroup.bookings.length}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          ...bookingGroup.bookings.asMap().entries.map((entry) {
            final index = entry.key;
            final booking = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Text(
                    '${index + 1}.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${booking.seatsBooked} ${'seats'.tr} • ${CurrencyService.instance.formatPrice(booking.price)}',
                          style: AppTextStyles.bodyMedium,
                        ),
                        Text(
                          'Seats: ${booking.seatNumbers.join(", ")}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      booking.status.name.capitalizeFirst!,
                      style: TextStyle(
                        color: _getStatusColor(booking.status),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BookingGroup bookingGroup) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.share),
            label: Text('share'.tr),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: AppColors.primary),
            ),
            onPressed: () => _shareBookingDetails(bookingGroup),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.download),
            label: Text('download_ticket'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _downloadTicket(bookingGroup),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDetailCard({required IconData icon, required String label, required String value, required Color color, bool showInfo = false, VoidCallback? onInfoTap}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              if (showInfo) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onInfoTap,
                  child: Icon(Icons.info_outline, color: color, size: 14),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getStatusColor(BookingStatus status) {
    switch (status) {
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

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.pending;
      case BookingStatus.confirmed:
        return Icons.check_circle;
      case BookingStatus.completed:
        return Icons.done_all;
      case BookingStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.confirmation_number;
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'pending'.tr;
      case BookingStatus.confirmed:
        return 'confirmed'.tr;
      case BookingStatus.completed:
        return 'completed'.tr;
      case BookingStatus.cancelled:
        return 'cancelled'.tr;
      default:
        return 'unknown'.tr;
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

  IconData _getPaymentIcon(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'card':
        return Icons.credit_card;
      case 'wallet':
        return Icons.wallet;
      default:
        return Icons.payment;
    }
  }

  void _shareBookingDetails(BookingGroup bookingGroup) {
    try {
      BookingShareService.shareBookingDetails(bookingGroup);
    } catch (e) {
      Get.snackbar(
        'share_failed'.tr,
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _contactSupport() {
    // Implement contact support functionality
    Get.snackbar('support'.tr, 'contacting_support'.tr);
  }

  void _downloadTicket(BookingGroup bookingGroup) async {
    try {
      // Show loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      await BookingShareService.downloadTicket(bookingGroup,);

      // Close loading
      Get.back();

      // Show success message
      Get.snackbar(
        'download_success'.tr,
        'ticket_downloaded'.tr, // Update your translation key
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      // Close loading
      Get.back();

      Get.snackbar(
        'download_failed'.tr,
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

}