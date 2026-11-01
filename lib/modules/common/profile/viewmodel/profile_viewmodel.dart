import 'package:elbabor/app/translations/language_service.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/theme_service.dart';
import '../../../../data/models/driver_model.dart';
import '../../../../data/services/firebase_service.dart';
import '../../../driver/home/repository/driver_home_repository.dart';

class ProfileViewModel extends GetxController {
  final user = Rxn<Map<String, dynamic>>();
  final driverStats = Rxn<Map<String, dynamic>>(); // Changed from DriverModel to Map
  final isDarkMode = false.obs;
  final currentLanguage = ''.obs;
  final isLoadingStats = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
    isDarkMode.value = ThemeService().isDarkMode;
    currentLanguage.value = LanguageService().getCurrentLang();
  }

  Future<void> _loadUser() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseService.firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        user.value = doc.data();

        // Load accurate driver stats if user is a driver
        if (user.value?['role'] == 'Driver') {
          await _loadDriverStats(uid);
        }
      }
    } catch (e) {
      print("❌ Error loading user: $e");
    }
  }

  Future<void> _loadDriverStats(String driverId) async {
    try {
      isLoadingStats.value = true;
      final realTimeStats = await DriverHomeRepository.getDriverRealTimeStats(driverId);
      driverStats.value = realTimeStats;
      print('✅ Loaded real-time driver stats: $realTimeStats');
    } catch (e) {
      print("❌ Error loading driver stats: $e");
    } finally {
      isLoadingStats.value = false;
    }
  }

  // Refresh stats (call this when trips are updated)
  Future<void> refreshDriverStats() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && user.value?['role'] == 'Driver') {
      await _loadDriverStats(uid);
    }
  }

  // Convert user map to DriverModel (for edit profile)
  DriverModel toDriverModel(Map<String, dynamic> map) {
    return DriverModel.fromMap(map);
  }

  // Refresh user locally (after edit)
  void refreshUser(Map<String, dynamic> updatedMap) {
    user.value = updatedMap;
    update(); // ensures UI refresh
  }

  void toggleTheme() {
    ThemeService().switchTheme();
    isDarkMode.value = ThemeService().isDarkMode;
  }

  void changeLanguage(String langCode) {
    LanguageService().changeLocale(langCode);
    currentLanguage.value = langCode;
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    Get.offAllNamed(Routes.SIGNIN);
  }

  String getCurrentLanguageName() {
    switch (currentLanguage.value) {
      case 'en_US':
        return 'English';
      case 'fr_FR':
        return 'Français';
      case 'ar_AR':
        return 'العربية';
      default:
        return 'English';
    }
  }

  // Get accurate stats for display from real-time data
  int get totalTrips => driverStats.value?['totalTrips'] ?? user.value?['totalTrips'] ?? 0;
  int get completedTrips => driverStats.value?['completedTrips'] ?? user.value?['completedTrips'] ?? 0;
  int get cancelledTrips => driverStats.value?['cancelledTrips'] ?? user.value?['cancelledTrips'] ?? 0;
  int get activeTrips => driverStats.value?['activeTrips'] ?? 0;
  int get expiredTrips => driverStats.value?['expiredTrips'] ?? 0;
  double get rating => user.value?['rating'] ?? 0.0;
  double get successRate => driverStats.value?['successRate']?.toDouble() ??
      (totalTrips > 0 ? (completedTrips / totalTrips * 100) : 0);

  // Get formatted success rate for display
  String get formattedSuccessRate => '${successRate.toStringAsFixed(1)}%';

  // Check if stats are loaded
  bool get areStatsLoaded => driverStats.value != null;

  // Get stats summary for quick display
  Map<String, dynamic> get statsSummary {
    return {
      'total': totalTrips,
      'completed': completedTrips,
      'cancelled': cancelledTrips,
      'active': activeTrips,
      'successRate': successRate,
      'rating': rating,
    };
  }
}