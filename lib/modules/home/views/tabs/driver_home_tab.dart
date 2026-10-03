import 'package:elbabor/app/routes/app_routes.dart';
import 'package:elbabor/app/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_colors.dart';
import '../../../../app/themes/app_text_styles.dart';
import '../../../../app/widgets/custom_button.dart';
import '../../../../data/services/firebase_service.dart';
import '../../../driver/trip_managment/viewmodels/trip_management_viewmodel.dart';

class DriverHomeTab extends StatelessWidget {
  const DriverHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.put(TripManagementViewModel());
    final driverId = FirebaseService.currentUserId;

    if (driverId == null) {
      return CustomLoader(message: "driver_not_logged".tr);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!vm.hasLoaded) {
        vm.fetchDriverTrips(driverId);
      }
    });

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "driver_home_title".tr,
              style: AppTextStyles.heading.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 20),

            /// --- Create Trip Button ---
            CustomButton(
              text: "+ ${'create_trip'.tr}",
              onPressed: () {
                Get.toNamed(Routes.DRIVER_CREATE_TRIP);
              },
            ),
            const SizedBox(height: 24),

            /// --- Active Trips Card List (Placeholder) ---
            Text("active_trips".tr, style: AppTextStyles.subheading),
            const SizedBox(height: 12),

            Expanded(
              child: Obx(() {
                if (vm.isLoading.value) {
                  return CustomLoader();
                }
                final trips = vm.activeTrips.take(3).toList();
                if (trips.isEmpty) {
                  return Center(child: Text("no_active_trips".tr));
                }
                return ListView.builder(
                  itemCount: trips.length,
                  itemBuilder: (_, index) {
                    final trip = trips[index];
                    IconData vehicleIcon;
                    Color vehicleColor;

                    switch (trip.vehicleType.toLowerCase()) {
                      case 'ferry':
                        vehicleIcon = Icons.directions_boat;
                        vehicleColor = Colors.blueAccent;
                        break;
                      case 'bus':
                        vehicleIcon = Icons.directions_bus;
                        vehicleColor = Colors.orangeAccent;
                        break;
                      case 'train':
                        vehicleIcon = Icons.train;
                        vehicleColor = Colors.green;
                        break;
                      case 'airplane':
                        vehicleIcon = Icons.flight_takeoff;
                        vehicleColor = Colors.purple;
                        break;
                      default:
                        vehicleIcon = Icons.directions_car;
                        vehicleColor = AppColors.primary;
                    }
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading:  Icon(vehicleIcon,color: vehicleColor,),
                        title: Text(
                          "${trip.fromCity} → ${trip.destinationCity}",
                        ),
                        subtitle: Text(
                          "${trip.vehicleType} | ${trip.seatsAvailable} seats",
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap:
                            () {
                            if(trip.status=='draft') {
                              Get.toNamed(
                              Routes.TRIP_PREVIEW,
                              arguments: trip,
                            );
                            } else if (trip.status=='active'){
                              Get.toNamed(
                                Routes.TRIP_DETAIL,
                                arguments: trip,
                              );
                            }
                            },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
