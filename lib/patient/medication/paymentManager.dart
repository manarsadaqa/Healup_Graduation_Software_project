import 'package:dio/dio.dart';
import 'package:first/patient/medication/stripe_keys.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

abstract class PaymentManager {
  static Future<void> makePayment(int amount, String currency) async {
    try {
      // Get the client secret from Stripe
      String clientSecret = await _getClientSecret((amount * 100).toString(), currency);

      // Initialize payment sheet with the client secret
      await _initializePaymentSheet(clientSecret);

      // Present the payment sheet
      await Stripe.instance.presentPaymentSheet();
    } catch (error) {
      print("Payment error: $error");
      throw Exception(error.toString());
    }
  }

  static Future<void> _initializePaymentSheet(String clientSecret) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: "manar", // Merchant name
        ),
      );
    } catch (error) {
      print("Error initializing payment sheet: $error");
      throw Exception(error.toString());
    }
  }

  static Future<String> _getClientSecret(String amount, String currency) async {
    Dio dio = Dio();
    try {
      // Sending POST request to Stripe API to create a PaymentIntent
      var response = await dio.post(
        'https://api.stripe.com/v1/payment_intents',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiKeys.secretKey}', // Ensure this is set correctly
            'Content-Type': 'application/x-www-form-urlencoded', // Fixed typo here
          },
        ),
        data: {
          'amount': amount,
          'currency': currency,
        },
      );

      // Ensure that the response contains the client_secret field
      if (response.data != null && response.data["client_secret"] != null) {
        return response.data["client_secret"];
      } else {
        throw Exception("Stripe API did not return a client secret.");
      }
    } catch (e) {
      print("Error getting client secret: $e");
      throw Exception("Failed to get client secret: ${e.toString()}");
    }
  }
}

// import 'package:dio/dio.dart';
// import 'package:first/patient/medication/stripe_keys.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
//
// abstract class PaymentManager {
//   static Future<void>makePayment(int amount , String currency)async{
//     try{
//       String clientSecret=await _getClintSecret((amount*100).toString(), currency);
//       await _initializePaymentSheet(clientSecret);
//       await Stripe.instance.presentPaymentSheet();
//     } catch(error){
//       throw Exception(error.toString());
//     }
//   }
//
//   static Future<void>_initializePaymentSheet(String clientSecret)async{
//     await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: clientSecret,
//           merchantDisplayName: "manar",
//         ),
//     );
//   }
//
//   static Future<String> _getClintSecret(String amount ,String currency)async{
//     Dio dio = Dio();
//     var response = await dio.post(
//     'http://api.stripe.com/v1/payment_intents',
//       options: Options(
//         headers: {
//           'Authorization': 'Bearer ${ApiKeys.secretKey}',
//           'Content_Type': 'application/x-www-form-urlencoded'
//
//         },
//       ),
//       data: {
//         'amount': amount,
//         'currency': currency,
//       },
//     );
//     return response.data["client_secret"];
//
//   }
// }