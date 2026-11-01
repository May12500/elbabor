// lib/data/services/payment_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get_storage/get_storage.dart';
import '../../app/config/stripe_config.dart';
import '../../main.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();
  
  // URL de ta fonction déployée sur my-baborensemble-app
  static const String backendUrl = 'https://us-central1-my-baborensemble-app.cloudfunctions.net/createPaymentIntent';

  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    required String bookingId,
  }) async {
    final amountInCents = (amount * 100).toInt();
    final response = await http.post(
      Uri.parse(backendUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'amount': amountInCents,
        'currency': currency.toLowerCase(),
        'booking_id': bookingId,
      }),
    ).timeout(const Duration(seconds: 15));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create payment intent: ${response.body}');
    }
  }

  Future<PaymentResult> processCardPayment({
    required String bookingId,
    required double amount,
    required String currency,
  }) async {
    try {
      final cleanAmount = _parseAmount(amount);
      final paymentIntent = await createPaymentIntent(
        amount: cleanAmount,
        currency: currency,
        bookingId: bookingId,
      );

      final clientSecret = paymentIntent['client_secret'] ?? paymentIntent['clientSecret'];
      if (clientSecret == null || clientSecret.toString().isEmpty) {
        throw Exception('Client secret is missing');
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Baborensemble',
          style: ThemeMode.light,
          applePay: const PaymentSheetApplePay(merchantCountryCode: 'FR'),
          googlePay: const PaymentSheetGooglePay(merchantCountryCode: 'FR', testEnv: false),
        ),
      );
      
      await Stripe.instance.presentPaymentSheet();
      final result = await Stripe.instance.retrievePaymentIntent(clientSecret);
      
      if (result.status == PaymentIntentsStatus.Succeeded) {
        _savePaymentMethod('card');
      }

      return PaymentResult(
        success: result.status == PaymentIntentsStatus.Succeeded,
        paymentIntentId: paymentIntent['id'],
        bookingId: bookingId,
        paymentMethod: 'card',
        transactionId: paymentIntent['id'],
      );
    } on StripeException catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: e.error.localizedMessage ?? 'Payment failed: ${e.error.code}',
        bookingId: bookingId,
        paymentMethod: 'card',
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: 'Erreur de paiement: $e',
        bookingId: bookingId,
        paymentMethod: 'card',
      );
    }
  }

  double _parseAmount(dynamic amount) {
    if (amount is double) return amount;
    if (amount is int) return amount.toDouble();
    if (amount is String) {
      final clean = amount.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(clean) ?? 0.0;
    }
    return 0.0;
  }

  void _savePaymentMethod(String method) {
    final box = GetStorage();
    box.write('last_payment_method', method);
    box.write('last_payment_date', DateTime.now().toIso8601String());
  }

  String? getLastPaymentMethod() {
    return GetStorage().read('last_payment_method');
  }

  Future<PaymentResult> processGooglePay({
    required String bookingId,
    required double amount,
    required String currency,
  }) async {
    return PaymentResult(
      success: true,
      paymentIntentId: 'gp_$bookingId',
      bookingId: bookingId,
      paymentMethod: 'google_pay',
      transactionId: 'gp_$bookingId',
    );
  }
}

class PaymentResult {
  final bool success;
  final String? paymentIntentId;
  final String? errorMessage;
  final String bookingId;
  final String? paymentMethod;
  final String? transactionId;

  PaymentResult({
    required this.success,
    this.paymentIntentId,
    this.errorMessage,
    required this.bookingId,
    this.paymentMethod = 'card',
    this.transactionId,
  });
}
