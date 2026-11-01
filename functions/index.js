const functions = require('firebase-functions');
const stripe = require('stripe')('sk_test_51SISsgHMKEbilT7Hz67mOrZCFtY37TPc1zEhDTDQz99TwBxdKDxElNon8Icdg41gsGPf7hSLXOM4IrGePH47MZzf00V3o0SqDD');
const cors = require('cors')({origin: true});

exports.createPaymentIntent = functions.https.onRequest(async (req, res) => {
  // Enable CORS
  cors(req, res, async () => {
    try {
      const { amount, currency, metadata } = req.body;

      // Create payment intent
      const paymentIntent = await stripe.paymentIntents.create({
        amount: Math.round(amount), // Amount in cents
        currency: currency || 'pkr',
        automatic_payment_methods: {
          enabled: true,
        },
        metadata: metadata || {},
      });

      res.status(200).json({
        clientSecret: paymentIntent.client_secret,
        id: paymentIntent.id,
      });
    } catch (error) {
      console.error('Error creating payment intent:', error);
      res.status(400).json({
        error: error.message
      });
    }
  });
});