import 'package:elbabor/app/widgets/appbar_icon_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../app/widgets/custom_button.dart';
import '../viewmodel/rating_viewmodel.dart';

class RatingView extends GetView<RatingViewModel> {
  const RatingView({
    super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("rate_trip".tr,style: AppTextStyles.heading.copyWith(fontSize: 20,color: Colors.white),),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: AppBarIconButton(icon: Icons.arrow_back_ios, onPressed: () => Get.back())
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.star_rate_rounded,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "how_was_your_trip".tr,
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "share_your_experience".tr,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Star Rating
            Obx(() => Column(
              children: [
                Text(
                  "tap_to_rate".tr,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return GestureDetector(
                      onTap: () => controller.setRating(starIndex),
                      child: Icon(
                        starIndex <= controller.selectedRating.value
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 48,
                        color: starIndex <= controller.selectedRating.value
                            ? AppColors.warning
                            : AppColors.grey,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  _getRatingText(controller.selectedRating.value),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            )),
            const SizedBox(height: 32),

            // Comment Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "optional_feedback".tr,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "share_your_experience_details".tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Action Buttons
            Obx(() => Column(
              children: [
                CustomButton(
                  text: "submit_rating".tr,
                  onPressed: controller.isLoading.value ? null : controller.submitRating,
                  isLoading: controller.isLoading.value,
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                  height: 56,
                  borderRadius: 16,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: controller.isLoading.value ? null : controller.skipRating,
                  child: Text(
                    "skip_for_now".tr,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1: return "poor".tr;
      case 2: return "fair".tr;
      case 3: return "good".tr;
      case 4: return "very_good".tr;
      case 5: return "excellent".tr;
      default: return "tap_stars_to_rate".tr;
    }
  }
}