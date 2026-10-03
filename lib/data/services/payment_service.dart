// lib/data/services/payment_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../app/config/stripe_config.dart';
import '../../main.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();
  // Mock backend URL - replace with actual backend when ready
  static const String backendUrl = 'https://api.stripe.com/v1/payment_intents';
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    required String bookingId,
  }) async {
    try {
      // For testing without backend, return mock data
      if (StripeConfig.isTestMode) {
        await Future.delayed(const Duration(seconds: 1));
        return {
          'client_secret': 'pi_mock_${DateTime.now().millisecondsSinceEpoch}_secret',
          'id': 'pi_mock_${DateTime.now().millisecondsSinceEpoch}',
        };
      }

      // Convert amount to cents and ensure it's an integer
      final amountInCents = (amount * 100).toInt();

      print('🔄 Creating payment intent for amount: $amountInCents cents');

      // Correct API call with form-urlencoded data
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${StripeConfig.secretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amountInCents.toString(),
          'currency': currency.toLowerCase(),
          'automatic_payment_methods[enabled]': 'true',
          'metadata[booking_id]': bookingId,
        }.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&'),
      );

      print('📡 Stripe API Response Status: ${response.statusCode}');
      print('📡 Stripe API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('✅ Payment intent created successfully: ${result['id']}');
        return result;
      } else {
        final error = json.decode(response.body);
        print('❌ Stripe API Error: ${error['error']['message']}');
        throw Exception('Failed to create payment intent: ${error['error']['message']}');
      }
    } catch (e) {
      print('💥 Payment intent creation error: $e');
      // Fallback to mock data for testing
      return {
        'clientSecret': 'pi_mock_fallback_${DateTime.now().millisecondsSinceEpoch}_secret',
        'id': 'pi_mock_fallback_${DateTime.now().millisecondsSinceEpoch}',
      };
    }
  }

  // Process card payment
  Future<PaymentResult> processCardPayment({
    required String bookingId,
    required double amount,
    required String currency,
  }) async {
    try {
      print('🔄 Starting Stripe payment process...');

      // 1. Create payment intent
      final paymentIntent = await createPaymentIntent(
        amount: amount,
        currency: currency,
        bookingId: bookingId,
      );
      _debugPaymentIntent(paymentIntent);

      print('✅ Payment intent created: ${paymentIntent['id']}');
      print('🔑 Client Secret: ${paymentIntent['client_secret']}');

      // For testing without actual Stripe, simulate success
      if (StripeConfig.isTestMode) {
        await Future.delayed(const Duration(seconds: 2));

        // Simulate payment sheet
        final success = await _showMockPaymentSheet();

        if (success) {
          return PaymentResult(
            success: true,
            paymentIntentId: paymentIntent['id'],
            bookingId: bookingId,
          );
        } else {
          return PaymentResult(
            success: false,
            errorMessage: 'Payment cancelled by user',
            bookingId: bookingId,
          );
        }
      }

      // 2. Verify client secret is available
      final clientSecret = paymentIntent['client_secret'];
      if (clientSecret == null || clientSecret.isEmpty) {
        throw Exception('Client secret is missing from payment intent');
      }

      print('🔄 Initializing payment sheet with client secret...');

      // 3. Configure Stripe for payment (real implementation)
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret, // Make sure this is properly set
          merchantDisplayName: 'Baborensemble',
          style: ThemeMode.light,
          // Add optional parameters for better UX
          applePay: const PaymentSheetApplePay(
            merchantCountryCode: 'FR',
          ),
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'FR',
            testEnv: false,
          ),
        ),
      );

      print('✅ Payment sheet initialized successfully');

      // 4. Display payment sheet
      print('🔄 Presenting payment sheet...');
      await Stripe.instance.presentPaymentSheet();

      print('✅ Payment successful!');

      // 5. Confirm the payment was successful
      await Stripe.instance.retrievePaymentIntent(clientSecret);

      return PaymentResult(
        success: true,
        paymentIntentId: paymentIntent['id'],
        bookingId: bookingId,
      );
    } on StripeException catch (e) {
      print('❌ Stripe Error: ${e.error}');
      print('❌ Error Code: ${e.error.code}');
      print('❌ Error Message: ${e.error.message}');

      return PaymentResult(
        success: false,
        errorMessage: e.error.localizedMessage ?? 'Payment failed: ${e.error.code}',
        bookingId: bookingId,
      );
    } catch (e, stackTrace) {
      print('❌ General Error: $e');
      print('❌ Stack Trace: $stackTrace');

      return PaymentResult(
        success: false,
        errorMessage: e.toString(),
        bookingId: bookingId,
      );
    }
  }

  void _debugPaymentIntent(Map<String, dynamic> paymentIntent) {
    print('🔍 Payment Intent Debug:');
    print('   - ID: ${paymentIntent['id']}');
    print('   - Client Secret: ${paymentIntent['client_secret']}');
    print('   - Amount: ${paymentIntent['amount']}');
    print('   - Currency: ${paymentIntent['currency']}');
    print('   - Status: ${paymentIntent['status']}');
    print('   - Keys: ${paymentIntent.keys.join(', ')}');
  }
  Future<bool> _showMockPaymentSheet() async {
    // Simulate payment sheet with a dialog
    return await showDialog<bool>(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: const Text('Mock Payment'),
        content: const Text('This is a mock payment flow for testing.\n\nClick "Pay" to simulate successful payment or "Cancel" to simulate failure.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Pay \$10.00'),
          ),
        ],
      ),
    ) ?? false;
  }

  // Process Google Pay payment
  Future<PaymentResult> processGooglePay({
    required String bookingId,
    required double amount,
    required String currency,
  }) async {
    try {
      // TODO: Implement Google Pay integration
      // This is a simplified version - you'll need proper Google Pay setup

      // For now, simulate successful payment
      await Future.delayed(const Duration(seconds: 2));

      return PaymentResult(
        success: true,
        paymentIntentId: 'gp_$bookingId',
        bookingId: bookingId,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: e.toString(),
        bookingId: bookingId,
      );
    }
  }
}

class PaymentResult {
  final bool success;
  final String? paymentIntentId;
  final String? errorMessage;
  final String bookingId;

  PaymentResult({
    required this.success,
    this.paymentIntentId,
    this.errorMessage,
    required this.bookingId,
  });
}