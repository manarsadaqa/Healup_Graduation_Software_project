// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:url_launcher/url_launcher.dart';
//
// class PayPalPayment extends StatefulWidget {
//   final double totalPrice;
//   final String currency;
//
//   const PayPalPayment({
//     Key? key,
//     required this.totalPrice,
//     required this.currency,
//   }) : super(key: key);
//
//   @override
//   _PayPalPaymentState createState() => _PayPalPaymentState();
// }
//
//
// class _PayPalPaymentState extends State<PayPalPayment> {
//   final String clientId = "AWl8BrcC_9CMymu9yJyWKNfvqCEtFZaJ2BVNstPBO75aacWOGx9kkcTZEP66RQXfWkiefPxx9Oe25rPC";
//   final String secretKey = "EAP5UXYTrQTtLczOUnN2QjzQQgB0_ovdgcJZ6qqEHAHwPQJwKEcsG8jybtJ4QaNFTbWM-6UqhfRkdNnu";
//   final String returnURL = "success.snippetcoder.com";
//   final String cancelURL = "cancel.snippetcoder.com";
//
//   // دالة لإنشاء الطلب
//   Future<String> createOrder() async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://10.0.2.2:5000/api/healup/paypal/create-order'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'amount': widget.totalPrice.toStringAsFixed(2), // Dynamic total price
//           'currency': widget.currency,                  // Dynamic currency
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         final String approvalUrl = responseData['approvalUrl'];
//
//         if (await canLaunch(approvalUrl)) {
//           await launch(approvalUrl); // Open approval URL in browser
//         } else {
//           throw Exception('Could not launch approval URL');
//         }
//         return responseData['id'];
//       } else {
//         throw Exception('Failed to create order');
//       }
//     } catch (e) {
//       throw Exception('Error: $e');
//     }
//   }
//
//
//   // دالة لالتقاط الدفع
//   Future<void> capturePayment(String orderId) async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://10.0.2.2:5000/api/healup/paypal/capture-order'), // استبدل بعنوان IP الخاص بك
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'orderId': orderId}),
//       );
//
//       if (response.statusCode == 200) {
//         print('Payment captured: ${response.body}');
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: Text('Payment Successful'),
//             content: Text('The payment was successfully captured.'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           ),
//         );
//       } else {
//         print('Failed to capture payment: ${response.body}');
//         throw Exception('Payment capture failed');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//   // دالة لبدء الدفع
//   Future<void> startPayment() async {
//     try {
//       String orderId = await createOrder();
//       // بعد تأكيد المشتري على الدفع عبر PayPal، قم بالاتصال بهذا الكود لالتقاط الدفع
//       // لاحظ أن هذا سيحدث بعد أن يتم تأكيد الدفع من قبل المستخدم عبر المتصفح.
//     } catch (e) {
//       print('Payment error: $e');
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Payment Failed'),
//           content: Text('There was an error with the payment process: $e'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK'),
//             ),
//           ],
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PayPal Payment'),
//         backgroundColor: const Color(0xff2f9a8f),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: startPayment,
//           child: const Text('Pay with PayPal'),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Color(0xff2f9a8f),
//             foregroundColor: Colors.white,
//             padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             textStyle: TextStyle(fontSize: 18),
//           ),
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class PayPalPayment extends StatefulWidget {
  final double totalPrice;
  final String currency;

  const PayPalPayment({
    Key? key,
    required this.totalPrice,
    required this.currency,
  }) : super(key: key);

  @override
  _PayPalPaymentState createState() => _PayPalPaymentState();
}

class _PayPalPaymentState extends State<PayPalPayment> {
  final String clientId = "AWl8BrcC_9CMymu9yJyWKNfvqCEtFZaJ2BVNstPBO75aacWOGx9kkcTZEP66RQXfWkiefPxx9Oe25rPC";
  final String secretKey = "EAP5UXYTrQTtLczOUnN2QjzQQgB0_ovdgcJZ6qqEHAHwPQJwKEcsG8jybtJ4QaNFTbWM-6UqhfRkdNnu";
  final String returnURL = "success.snippetcoder.com";
  final String cancelURL = "cancel.snippetcoder.com";

  Future<String> createOrder() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/healup/paypal/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': widget.totalPrice.toStringAsFixed(2),
          'currency': widget.currency,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String approvalUrl = responseData['approvalUrl'];

        // Redirect to PayPal for approval
        if (await canLaunch(approvalUrl)) {
          await launch(approvalUrl);
        } else {
          throw Exception('Could not launch approval URL');
        }

        return responseData['id']; // Return the order ID
      } else {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }




  Future<void> capturePayment(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/healup/paypal/capture-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'orderId': orderId}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Payment captured successfully: ${responseData}');
        _showDialog('Payment Successful', 'The payment was successfully captured.', true);
      } else {
        print('Failed to capture payment: ${response.body}');
        throw Exception('Payment capture failed');
      }
    } catch (e) {
      _showDialog('Payment Failed', 'Error: $e', false);
    }
  }


  void _showDialog(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(isSuccess); // Return to previous page
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> startPayment() async {
    try {
      String orderId = await createOrder();
      await capturePayment(orderId);
    } catch (e) {
      _showDialog('Payment Failed', 'Error: $e', false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayPal Payment'),
        backgroundColor: const Color(0xff2f9a8f),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: startPayment,
          child: const Text('Pay with PayPal'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xff2f9a8f),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
