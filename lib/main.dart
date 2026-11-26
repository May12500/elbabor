import 'package:elbabor/app/bindings/splash_binding.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/config/stripe_config.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/themes/theme_service.dart';
import 'app/translations/language_service.dart';
import 'data/services/currency_service.dart';
import 'data/services/notification_service.dart';
import 'firebase_options.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialisation des notifications Push (FCM)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService.init();

  await GetStorage.init();
  Get.put(CurrencyService());
  await LanguageService.init();

  // Initialize Stripe
  Stripe.publishableKey = StripeConfig.publishableKey;
  Stripe.merchantIdentifier = 'merchant.flutter.stripe.e2e';
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();
  print('Stripe initialized with key: ${StripeConfig.publishableKey}');

  final themeService = ThemeService();
  final languageService = LanguageService();

  runApp(TravelTogetherApp(
    themeService: themeService,
    languageService: languageService,
  ));
}

class TravelTogetherApp extends StatelessWidget {
  final ThemeService themeService;
  final LanguageService languageService;

  const TravelTogetherApp({
    Key? key,
    required this.themeService,
    required this.languageService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Elbabor',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      translations: LanguageService(),
      locale: LanguageService.getLocale(),
      fallbackLocale: const Locale('en', 'US'),
      theme: ThemeService.getLightTheme(),
      darkTheme: ThemeService.getDarkTheme(),
      themeMode: ThemeService().theme,
      getPages: AppPages.routes,
      initialRoute: Routes.SPLASH,
    );
  }
}