import 'package:elbabor/data/models/passenger_model.dart';
import 'package:elbabor/data/services/booking_share_service.dart';
import 'package:elbabor/data/services/currency_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../app/themes/app_colors.dart';
import '../../../../../app/themes/app_text_styles.dart';
import '../../../../../app/widgets/custom_button.dart';
import '../../../../../app/widgets/custom_loader.dart';
import 'package:elbabor/app/routes/app_routes.dart';
import '../../../../data/models/rating_model.dart';
import '../../../../data/models/trip_segment_model.dart';
import '../../../passenger/viewmodels/passenger_info_viewmodel.dart';
import '../../../../data/models/trip_model.dart';
import '../viewmodels/trip_detail_viewmodel.dart';
import '../widget/passenger_item_widget.dart';

class TripDetailView extends GetView<TripDetailViewModel> {
  const TripDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final TripModel trip = Get.arguments;
    controller.setTrip(trip);
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text("trip_details".tr, style: AppTextStyles.heading.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        leading: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () { Get.back(); })),
        actions: [Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: IconButton(icon: const Icon(Icons.share_outlined, size: 22, color: Colors.white), onPressed: () => _shareTrip(trip), tooltip: "share_trip".tr))],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return CustomLoader(message: "loading_trip_details".tr);
        return Column(children: [Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [_buildTripHeader(trip, dateFormat, timeFormat), const SizedBox(height: 24), _buildSegmentsCard(trip), const SizedBox(height: 20), _buildTripDetailsCard(trip, dateFormat, timeFormat), const SizedBox(height: 20), _buildRatingsCard(), const SizedBox(height: 20), _buildVehiclesInfoCard(trip), const SizedBox(height: 20), _buildPassengersCard(trip), const SizedBox(height: 32)]))), _buildActionButtons(trip)]);
      }),
    );
  }

  Widget _buildTripHeader(TripModel trip, DateFormat dateFormat, DateFormat timeFormat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.05)]), borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle), child: Icon(trip.hasMultipleSegments ? Icons.connecting_airports : _getVehicleIcon(trip.vehicleType), color: AppColors.primary, size: 28)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("${trip.fromCity} → ${trip.destinationCity}", style: AppTextStyles.heading.copyWith(fontSize: 18, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text("${dateFormat.format(trip.dateTime)} • ${timeFormat.format(trip.dateTime)}", style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        ])),
      ]),
    );
  }

  Widget _buildSegmentsCard(TripModel trip) {
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(Icons.route_outlined, color: AppColors.primary, size: 20), const SizedBox(width: 8), Text(trip.hasMultipleSegments ? "trip_segments".tr : "route_details".tr, style: AppTextStyles.subheading.copyWith(fontWeight: FontWeight.w600))]), const SizedBox(height: 20), if (trip.hasMultipleSegments) _buildSegmentsTimeline(trip) else _buildSingleSegmentRoute(trip)]));
  }

  Widget _buildSegmentsTimeline(TripModel trip) {
    return Column(children: trip.segments.asMap().entries.map((entry) {
      final index = entry.key;
      final segment = entry.value;
      final isLast = index == trip.segments.length - 1;
      return Column(children: [_buildSegmentItem(segment, index + 1), if (!isLast) _buildSegmentConnector()]);
    }).toList());
  }

  Widget _buildSegmentItem(TripSegment segment, int segmentNumber) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.scaffoldBackground, borderRadius: BorderRadius.circular(12)), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle), child: Icon(_getVehicleIcon(segment.vehicleType), color: AppColors.primary, size: 20)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("${"segment".tr} $segmentNumber", style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500)), const SizedBox(height: 8), Text(CurrencyService.instance.formatPrice(segment.price), style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600))]))]));
  }

  Widget _buildSegmentConnector() {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [const SizedBox(width: 36), Container(width: 2, height: 20, color: AppColors.primary.withOpacity(0.3)), const SizedBox(width: 12), Icon(Icons.arrow_downward, color: AppColors.primary.withOpacity(0.5), size: 16)]));
  }

  Widget _buildSingleSegmentRoute(TripModel trip) {
    return Column(children: [_buildRouteVisualization(trip), const SizedBox(height: 16), _buildPointsSection(trip)]);
  }

  Widget _buildRouteVisualization(TripModel trip) {
    final segment = trip.segments.first;
    return Container(padding: const EdgeInsets.symmetric(vertical: 16), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(segment.fromCity, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)), Text(segment.fromPoint, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary))])), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(segment.toCity, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.end), Text(segment.toPoint, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.end)]))]));
  }

  Widget _buildPointsSection(TripModel trip) {
    final segment = trip.segments.first;
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.scaffoldBackground, borderRadius: BorderRadius.circular(12)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("departure_from".tr, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)), const SizedBox(height: 4), Text(segment.fromPoint, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600))])), Container(width: 1, height: 40, color: AppColors.border), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text("arrival_at".tr, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)), const SizedBox(height: 4), Text(segment.toPoint, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.end)]))]));
  }

  Widget _buildTripDetailsCard(TripModel trip, DateFormat dateFormat, DateFormat timeFormat) {
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("trip_details".tr, style: AppTextStyles.subheading.copyWith(fontWeight: FontWeight.w600)), const SizedBox(height: 16), _buildDetailItem(icon: Icons.calendar_today_outlined, label: "date".tr, value: dateFormat.format(trip.dateTime)), _buildDetailItem(icon: Icons.access_time_outlined, label: "time".tr, value: timeFormat.format(trip.dateTime)), _buildDetailItem(icon: Icons.event_seat_outlined, label: "seats_available".tr, value: "${trip.seatsAvailable} ${'seats'.tr}"), _buildDetailItem(icon: Icons.attach_money_outlined, label: "total_price".tr, value: CurrencyService.instance.formatPrice(trip.totalPrice))]));
  }

  Widget _buildVehiclesInfoCard(TripModel trip) {
    final vehicleSegments = trip.segments.where((segment) => segment.vehicle != null).toList();
    if (vehicleSegments.isEmpty) return const SizedBox.shrink();
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(children: vehicleSegments.map((s) => _buildVehicleDetailItem("vehicle_type".tr, s.vehicleType)).toList()));
  }

  Widget _buildPassengersCard(TripModel trip) {
    return Obx(() => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("passengers".tr, style: AppTextStyles.subheading.copyWith(fontWeight: FontWeight.w600)), const SizedBox(height: 16), if (controller.passengers.isEmpty) Text("no_passengers_yet".tr) else Column(children: controller.passengers.map((p) => _buildPassengerItem(p)).toList())])));
  }

  Widget _buildPassengerItem(PassengerModel passenger) {
    return PassengerItem(passenger: passenger, controller: controller, messagePassenger: _messagePassenger, viewPassengerProfile: _viewPassengerProfile);
  }

  Widget _buildActionButtons(TripModel trip) {
    return Obx(() {
      final canComplete = controller.canCompleteTrip;
      final isCompleted = trip.isCompleted;
      final isCompleting = controller.isCompleting.value;
      return Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))]), child: Column(children: [Row(children: [if (trip.status == 'draft') Expanded(child: CustomButton(text: "edit_trip".tr, onPressed: () => _editTrip(trip), type: ButtonType.outlined, icon: Icons.edit_outlined)), if (trip.status == 'active' && canComplete) Expanded(child: CustomButton(text: isCompleting ? "completing".tr : "complete_trip".tr, onPressed: isCompleting ? null : () => _completeTrip(), isLoading: isCompleting, icon: Icons.check_circle_outline, type: ButtonType.primary)), if (trip.status == 'active' && !canComplete) Expanded(child: CustomButton(text: "manage_trip".tr, onPressed: () => _manageTrip(trip), icon: Icons.manage_accounts_outlined, type: ButtonType.primary)), if (isCompleted) Expanded(child: CustomButton(text: "trip_completed".tr, onPressed: () => _viewCompletedTrip(trip), icon: Icons.visibility_outlined, type: ButtonType.outlined))])]));
    });
  }

  void _completeTrip() {
    Get.dialog(AlertDialog(title: Text("complete_trip".tr), content: Text("confirm_complete_trip".tr), actions: [TextButton(onPressed: () => Get.back(), child: Text("cancel".tr)), ElevatedButton(onPressed: () { Get.back(); controller.completeTrip(); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: Text("confirm".tr))]));
  }

  void _manageTrip(TripModel trip) {
    Get.bottomSheet(Container(padding: const EdgeInsets.all(24), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))), child: Column(mainAxisSize: MainAxisSize.min, children: [Text("manage_trip".tr, style: AppTextStyles.heading.copyWith(fontSize: 18)), const SizedBox(height: 20), ListTile(leading: const Icon(Icons.edit_outlined, color: AppColors.primary), title: Text("edit_trip".tr), onTap: () { Get.back(); Get.toNamed(Routes.DRIVER_CREATE_TRIP, arguments: trip); }), ListTile(leading: const Icon(Icons.delete_outline, color: AppColors.error), title: Text("delete_trip".tr, style: const TextStyle(color: AppColors.error)), onTap: () { Get.back(); _confirmDeleteTrip(); }), const SizedBox(height: 10), CustomButton(text: "cancel".tr, onPressed: () => Get.back(), type: ButtonType.outlined)])));
  }

  void _confirmDeleteTrip() {
    Get.dialog(AlertDialog(title: Text("delete_trip".tr), content: Text("confirm_delete_trip".tr), actions: [TextButton(onPressed: () => Get.back(), child: Text("cancel".tr)), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), onPressed: () { Get.back(); Get.snackbar('Info', 'Delete a implementer', snackPosition: SnackPosition.BOTTOM); }, child: Text("delete".tr))]));
  }

  void _viewCompletedTrip(TripModel trip) {
    Get.snackbar("trip_completed".tr, "this_trip_has_been_completed".tr, snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.success.withOpacity(0.9), colorText: Colors.white);
  }

  Widget _buildDetailItem({required IconData icon, required String label, required String value, TextStyle? valueStyle}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Row(children: [Icon(icon, color: AppColors.primary, size: 18), const SizedBox(width: 12), Expanded(child: Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary))), Text(value, style: valueStyle ?? AppTextStyles.body.copyWith(fontWeight: FontWeight.w600))]));
  }

  Widget _buildVehicleDetailItem(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Row(children: [Expanded(child: Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary))), Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600))]));
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'ferry': return Icons.directions_boat;
      case 'bus': return Icons.directions_bus;
      default: return Icons.directions_car;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft': case 'pending': return AppColors.warning;
      case 'active': case 'confirmed': return AppColors.success;
      case 'scheduled': return AppColors.info;
      case 'completed': return AppColors.primary;
      case 'cancelled': return AppColors.error;
      default: return AppColors.grey;
    }
  }

  void _shareTrip(TripModel trip) { BookingShareService.shareTripDetails(trip); }
  void _messagePassenger(PassengerModel passenger) { PassengerInfoViewModel.messagePassengerDirectly(passenger); }
  void _viewPassengerProfile(PassengerModel passenger) { Get.toNamed(Routes.PASSENGER_INFO, arguments: passenger); }
  void _editTrip(TripModel trip) { Get.toNamed(Routes.DRIVER_CREATE_TRIP, arguments: trip); }

  Widget _buildRatingsCard() {
    return Obx(() => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("trip_ratings".tr, style: AppTextStyles.subheading.copyWith(fontWeight: FontWeight.w600)), const SizedBox(height: 16), if (controller.isLoadingRatings.value) const Center(child: CircularProgressIndicator()) else if (!controller.hasRatings) Text("no_ratings_yet".tr) else _buildRatingsContent(controller)])));
  }

  Widget _buildRatingsContent(TripDetailViewModel controller) {
    return Column(children: [_buildAverageRating(controller), const SizedBox(height: 20), _buildRatingDistribution(controller), const SizedBox(height: 20), _buildRecentRatings(controller)]);
  }

  Widget _buildAverageRating(TripDetailViewModel controller) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(Icons.star_rounded, size: 40, color: AppColors.warning), const SizedBox(width: 20), Expanded(child: Text(controller.averageTripRating.value.toStringAsFixed(1), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)))]));
  }

  Widget _buildStarRatingBar(double rating) {
    return Row(children: List.generate(5, (index) { final starIndex = index + 1; return Icon(starIndex <= rating ? Icons.star_rounded : (starIndex - 0.5 <= rating ? Icons.star_half_rounded : Icons.star_border_rounded), size: 16, color: AppColors.warning); }));
  }

  Widget _buildRatingDistribution(TripDetailViewModel controller) {
    return Column(children: [5, 4, 3, 2, 1].map((stars) { final percentage = controller.getRatingPercentage(stars); final count = controller.ratingDistribution[stars] ?? 0; return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [Text("$stars"), Expanded(child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: percentage / 100, child: Container(color: AppColors.warning, height: 8))), Text("${percentage.toStringAsFixed(0)}% ($count)")])) ; }).toList());
  }

  Widget _buildRecentRatings(TripDetailViewModel controller) {
    final recentRatings = controller.tripRatings.take(3).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("recent_ratings".tr, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)), const SizedBox(height: 12), Column(children: recentRatings.map((r) => _buildRatingItem(r)).toList())]);
  }

  Widget _buildRatingItem(RatingModel rating) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: AppColors.scaffoldBackground, borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(rating.passengerName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)), if (rating.comment != null && rating.comment!.isNotEmpty) Text(rating.comment!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)), Text(dateFormat.format(rating.createdAt), style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary))]));
  }

  void _showAllRatings() {
    Get.dialog(AlertDialog(title: Text("all_ratings".tr), content: SizedBox(width: double.maxFinite, child: ListView.builder(shrinkWrap: true, itemCount: controller.tripRatings.length, itemBuilder: (context, index) => _buildRatingItem(controller.tripRatings[index]))), actions: [TextButton(onPressed: () => Get.back(), child: Text("close".tr))]));
  }
}
