import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class CurrencyService extends GetxController {
  static CurrencyService get instance => Get.find<CurrencyService>();

  final RxString selectedCurrency = 'USD'.obs;
  final RxMap<String, double> exchangeRates = <String, double>{}.obs;
  final RxBool isLoadingRates = false.obs;

  // Our supported currencies
  final List<String> supportedCurrencies = ['USD', 'AED', 'EUR', 'GBP'];
  final String apiUrl = 'https://api.frankfurter.app/latest?from=USD';

  @override
  void onInit() {
    super.onInit();
    _loadSavedCurrency();
    _fetchExchangeRates();
  }

  void _loadSavedCurrency() {
    final savedCurrency = GetStorage().read('selected_currency') ?? 'USD';
    // Ensure saved currency is in our supported list
    selectedCurrency.value = supportedCurrencies.contains(savedCurrency) ? savedCurrency : 'USD';
    print('💰 Loaded saved currency: ${selectedCurrency.value}');
  }

  void setCurrency(String currency) {
    if (supportedCurrencies.contains(currency)) {
      selectedCurrency.value = currency;
      GetStorage().write('selected_currency', currency);
      print('💰 Currency changed to: $currency');
      update();
    } else {
      print('❌ Currency $currency not supported');
    }
  }

  Future<void> _fetchExchangeRates() async {
    isLoadingRates.value = true;
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rawRates = data['rates'] as Map<String, dynamic>;

        final rates = <String, double>{};

        // Only add rates for our supported currencies
        supportedCurrencies.forEach((currency) {
          if (rawRates.containsKey(currency)) {
            final value = rawRates[currency];
            if (value is int) {
              rates[currency] = value.toDouble();
            } else if (value is double) {
              rates[currency] = value;
            } else if (value is String) {
              rates[currency] = double.tryParse(value) ?? _getFallbackRate(currency);
            }
          } else {
            // Use fallback if currency not in API response
            rates[currency] = _getFallbackRate(currency);
          }
        });

        // Ensure USD is always 1.0 as base currency
        rates['USD'] = 1.0;

        exchangeRates.value = rates;

        await GetStorage().write('exchange_rates', rates);
        await GetStorage().write('rates_last_updated', DateTime.now().toString());

        print('✅ Exchange rates updated for: ${rates.keys.join(', ')}');
        update();
      } else {
        throw Exception('API returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Failed to fetch exchange rates: $e');
      _loadCachedRates();
    } finally {
      isLoadingRates.value = false;
    }
  }

  double _getFallbackRate(String currency) {
    switch (currency) {
      case 'USD': return 1.0;
      case 'AED': return 3.67;
      case 'EUR': return 0.92;
      case 'GBP': return 0.79;
      default: return 1.0;
    }
  }

  void _loadCachedRates() {
    final cachedRates = GetStorage().read('exchange_rates');
    final lastUpdated = GetStorage().read('rates_last_updated');

    if (cachedRates != null && lastUpdated != null) {
      final lastUpdate = DateTime.parse(lastUpdated);
      final hoursSinceUpdate = DateTime.now().difference(lastUpdate).inHours;

      if (hoursSinceUpdate < 24) {
        exchangeRates.value = Map<String, double>.from(cachedRates);
        print('📦 Using cached exchange rates');
        update();
        return;
      }
    }

    // Fallback to our supported currencies only
    exchangeRates.value = {
      'USD': 1.0,
      'AED': 3.67,
      'EUR': 0.92,
      'GBP': 0.79,
    };
    print('⚠️ Using fallback exchange rates');
    update();
  }

  double convertFromUSD(double usdAmount) {
    if (selectedCurrency.value == 'USD') return usdAmount;

    final rate = exchangeRates[selectedCurrency.value];
    if (rate == null) {
      print('❌ No exchange rate for ${selectedCurrency.value}');
      return usdAmount;
    }

    return usdAmount * rate;
  }

  double convertToUSD(double amount) {
    if (selectedCurrency.value == 'USD') return amount;

    final rate = exchangeRates[selectedCurrency.value];
    if (rate == null) {
      print('❌ No exchange rate for ${selectedCurrency.value}');
      return amount;
    }

    return amount / rate;
  }

  String formatPrice(double usdPrice) {
    final convertedPrice = convertFromUSD(usdPrice);
    final symbol = getCurrencySymbol(selectedCurrency.value);

    // Format based on currency
    switch (selectedCurrency.value) {
      case 'AED':
        return '$symbol${convertedPrice.toStringAsFixed(2)}';
      case 'EUR':
        return '$symbol${convertedPrice.toStringAsFixed(2)}';
      case 'GBP':
        return '$symbol${convertedPrice.toStringAsFixed(2)}';
      case 'USD':
      default:
        return '$symbol${convertedPrice.toStringAsFixed(2)}';
    }
  }

  String getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD': return '\$';
      case 'AED': return 'AED ';
      case 'EUR': return '€';
      case 'GBP': return '£';
      default: return '\$';
    }
  }
  String formatPriceWithCurrency(double usdPrice) {
    final convertedPrice = convertFromUSD(usdPrice);
    final symbol = getCurrencyDisplayName(selectedCurrency.value);

    // Format based on currency
    switch (selectedCurrency.value) {
      case 'AED':
        return '${convertedPrice.toStringAsFixed(2)} $symbol';
      case 'EUR':
        return '${convertedPrice.toStringAsFixed(2)} $symbol';
      case 'GBP':
        return '${convertedPrice.toStringAsFixed(2)} $symbol';
      case 'USD':
      default:
        return '${convertedPrice.toStringAsFixed(2)} $symbol';
    }
  }
  String getCurrencyDisplayName(String currency) {
    switch (currency) {
      case 'USD': return 'US Dollar';
      case 'AED': return 'UAE Dirham';
      case 'EUR': return 'Euro';
      case 'GBP': return 'British Pound';
      default: return currency;
    }
  }

  Future<void> refreshRates() async {
    await _fetchExchangeRates();
  }

  bool get areRatesStale {
    final lastUpdated = GetStorage().read('rates_last_updated');
    if (lastUpdated == null) return true;

    final lastUpdate = DateTime.parse(lastUpdated);
    return DateTime.now().difference(lastUpdate).inHours > 24;
  }
}