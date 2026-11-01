import 'package:elbabor/data/services/currency_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../app/themes/app_colors.dart';
import '../../../../../app/themes/app_text_styles.dart';
import '../../../../../app/widgets/custom_button.dart';
import '../../../viewmodels/search_trip_viewmodel.dart';

class TripFilterDialog extends StatefulWidget {
  final Function({
  required double minP,
  required double maxP,
  required int seats,
  required double rating,
  }) onApplyFilters;

  const TripFilterDialog({
    super.key,
    required this.onApplyFilters,
  });

  @override
  State<TripFilterDialog> createState() => _TripFilterDialogState();
}

class _TripFilterDialogState extends State<TripFilterDialog> {
  double _minPrice = 0;
  double _maxPrice = 5000;
  int _seats = 1;
  double _minRating = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 24),

          // Price Range Section
          _buildPriceRangeSection(),
          const SizedBox(height: 24),

          // Seats Section
          _buildSeatsSection(),
          const SizedBox(height: 24),

          // Rating Section
          _buildRatingSection(),
          const SizedBox(height: 32),

          // Action Buttons
          _buildActionButtons(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Drag Handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'filters'.tr,
              style: AppTextStyles.heading.copyWith(fontSize: 22),
            ),
            GestureDetector(
              onTap: _resetFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'reset_all'.tr,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.attach_money, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'price_range'.tr,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'select_price_range'.tr,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        RangeSlider(
          values: RangeValues(_minPrice, _maxPrice),
          min: 0,
          max: 10000,
          divisions: 100,
          activeColor: AppColors.primary,
          inactiveColor: Colors.grey.shade300,
          labels: RangeLabels(
            CurrencyService.instance.formatPrice(_minPrice),
            CurrencyService.instance.formatPrice(_maxPrice),
          ),
          onChanged: (values) {
            setState(() {
              _minPrice = values.start;
              _maxPrice = values.end;
            });
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPriceChip('${'min'.tr}: ${CurrencyService.instance.formatPrice(_minPrice)}'),
            _buildPriceChip('${'max'.tr}: ${CurrencyService.instance.formatPrice(_maxPrice)}'),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSeatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.event_seat, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'minimum_seats'.tr,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'select_minimum_seats'.tr,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Slider(
          value: _seats.toDouble(),
          min: 1,
          max: 8,
          divisions: 7,
          activeColor: AppColors.primary,
          inactiveColor: Colors.grey.shade300,
          label: '$_seats ${'seats'.tr}',
          onChanged: (value) {
            setState(() => _seats = value.toInt());
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_seats ${'seats'.tr}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.star, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'minimum_rating'.tr,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'select_minimum_rating'.tr,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Slider(
          value: _minRating,
          min: 0,
          max: 5,
          divisions: 10,
          activeColor: AppColors.primary,
          inactiveColor: Colors.grey.shade300,
          label: _minRating.toStringAsFixed(1),
          onChanged: (value) {
            setState(() => _minRating = value);
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _minRating.toStringAsFixed(1),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'apply_filters'.tr,
            onPressed: _applyFilters,
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
            height: 50,
            borderRadius: 12,
            hasShadow: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: 'cancel'.tr,
            onPressed: () => Get.back(),
            type: ButtonType.outlined,
            height: 50,
            borderRadius: 12,
          ),
        ),
      ],
    );
  }

  void _applyFilters() {
    widget.onApplyFilters(
      minP: _minPrice,
      maxP: _maxPrice,
      seats: _seats,
      rating: _minRating,
    );
    Get.back();
  }

  void _resetFilters() {
    setState(() {
      _minPrice = 0;
      _maxPrice = 5000;
      _seats = 1;
      _minRating = 0;
    });

    widget.onApplyFilters(
      minP: 0,
      maxP: 5000,
      seats: 1,
      rating: 0,
    );

    Get.back();
  }
}