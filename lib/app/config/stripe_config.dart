class StripeConfig {

  static const String publishableKeyTest = 'pk_test_51SISsgHMKEbilT7HvJ89rx22xyQ3jwPAQpGNU8YoHdPOz0Ii5ovV4GtcXAw6ZWBdLVbG1hUZw9m7XUS2qhyGkB4U00cNs8b0JW'; // Your publishable key
  static const String secretKeyTest = 'sk_test_51SISsgHMKEbilT7Hz67mOrZCFtY37TPc1zEhDTDQz99TwBxdKDxElNon8Icdg41gsGPf7hSLXOM4IrGePH47MZzf00V3o0SqDD'; // Your secret key - FOR BACKEND ONLY

  static const String publishableKey = 'pk_live_51RMNdJ7yeCDO19h6IJnyQFLGl5mSSW32KBR5UQrS5A0js3LeJcPz9LZ8I59JukVGHtRzVGExoUht1PDfM7GkzYkC00EkaOBt6Z'; // Your publishable key
  static const String secretKey = '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'; // Your secret key - FOR BACKEND ONLY

  // static const String publishableKey = 'pk_test_51SISsgHMKEbilT7HvJ89rx22xyQ3jwPAQpGNU8YoHdPOz0Ii5ovV4GtcXAw6ZWBdLVbG1hUZw9m7XUS2qhyGkB4U00cNs8b0JW'; // Your publishable key
  // static const String secretKey = 'sk_test_51SISsgHMKEbilT7Hz67mOrZCFtY37TPc1zEhDTDQz99TwBxdKDxElNon8Icdg41gsGPf7hSLXOM4IrGePH47MZzf00V3o0SqDD'; // Your secret key - FOR BACKEND ONLY

  // Test card numbers for development
  static const Map<String, String> testCards = {
    'success': '4242424242424242',
    'fail': '4000000000009995',
    'requires_authentication': '4000002500003155',
  };

  static const bool isTestMode = false;

}