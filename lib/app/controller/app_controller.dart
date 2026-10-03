import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import '../config/stripe_config.dart';

class AppController extends GetxController {
  @override
  void onInit() {
    _initializeStripe();
    super.onInit();
  }

  void _initializeStripe() {
    Stripe.publishableKey = StripeConfig.publishableKey;
    Stripe.merchantIdentifier = 'merchant.flutter.stripe.e2e';
    Stripe.urlScheme = 'flutterstripe';
  }
}