import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io'; // Add this import to use SocketException

class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  OrderDetailsPage({required this.orderId});

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  Map<String, dynamic> orderDetails = {};

  Future<void> fetchOrderDetails() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:5000/api/healup/orders/${widget.orderId}"),
      );
      if (response.statusCode == 200) {
        setState(() {
          orderDetails = jsonDecode(response.body);
        });
        print('========================='); // طباعة تفاصيل الطلب

        print('Order Details: $orderDetails'); // طباعة تفاصيل الطلب

        getPaymentByOrderId(widget.orderId);
        getBillingByOrderId(widget.orderId); // Pass the orderId directly here
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch order details")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $error")),
      );
    }
  }

  Future<List<dynamic>?> getPaymentByOrderId(String orderId) async {
    final url = Uri.parse(
        'http://10.0.2.2:5000/api/healup/payment/order/$orderId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        var payments = data is List ? data : data['payments'];

        if (payments != null && payments.isNotEmpty) {
          setState(() {
            orderDetails['payments'] = payments;
          });
        }

        return payments;
      } else {
        throw Exception('Failed to load payments');
      }
    } catch (error) {
      throw Exception("An error occurred while fetching payments");
    }
  }

  Future<void> getBillingByOrderId(String orderId) async {
    final url = 'http://10.0.2.2:5000/api/healup/billing/order/$orderId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> billings = jsonDecode(response.body);

        setState(() {
          orderDetails['billings'] = billings;
        });
      } else {
        print('Failed to load billings');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Widget _buildTextField(String label, dynamic value) {
    String displayValue = value is double
        ? value.toStringAsFixed(2)
        : value is int
        ? value.toString()
        : value ?? "N/A";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: displayValue,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey[400]!,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey[400]!,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false,  // لإزالة سهم التراجع
        title: const Text(
          "Order Details",
          style: TextStyle(
            fontSize: 24,  // زيادة حجم الخط
            //fontWeight: FontWeight.bold,  // جعل الخط عريض
          ),
        ),
        backgroundColor: const Color(0xff2f9a8f),
      ),
      body:
      // Container(
      //   decoration: BoxDecoration(
      //     image: DecorationImage(
      //       image: AssetImage('images/back.jpg'),
      //       fit: BoxFit.cover,
      //       colorFilter: ColorFilter.mode(
      //         Colors.black.withOpacity(0.3),
      //         BlendMode.darken,
      //       ),
      //     ),
      //   ),
      //   child:
        orderDetails.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Details Card
            // Inside the build method of OrderDetailsPage
            _buildCard(
              "Order Details",
              [
                _buildTextField("Order ID", orderDetails['_id']),
                _buildTextField("Patient", orderDetails['patient_id']['username']),
                _buildTextField("Order Date", orderDetails['order_date']),
                _buildTextField(
                    "Medications",
                    orderDetails['medications']?.map((med) {
                      // Ensure med['medication_id'] is not null before accessing medication_name
                      String medicationName = med['medication_id'] != null
                          ? med['medication_id']['medication_name'] ?? 'Unknown medication'
                          : 'Unknown medication';
                      // Ensure quantity is also checked
                      int quantity = med['quantity'] ?? 0;

                      return "$medicationName (x$quantity)";
                    })?.join(", ") ?? "No medications"
                ),
              ],
            ),
            // _buildCard(
            //   "Order Details",
            //   [
            //     _buildTextField("Order ID", orderDetails['_id']),
            //     _buildTextField(
            //         "Patient", orderDetails['patient_id']['username']),
            //     _buildTextField("Order Date", orderDetails['order_date']),
            //     // _buildTextField("Medications", orderDetails['medications']
            //     //     .map((med) =>
            //     // "${med['medication_id']['medication_name']} (x${med['quantity']})")
            //     //     .join(", ")),
            //     _buildTextField("Medications", orderDetails['medications']
            //         .map((med) {
            //       // Ensure med['medication_id'] is not null before accessing medication_name
            //       String medicationName = med['medication_id'] != null
            //           ? med['medication_id']['medication_name'] ?? 'Unknown medication'
            //           : 'Unknown medication';
            //       // Ensure quantity is also checked
            //       int quantity = med['quantity'] ?? 0;
            //
            //       return "$medicationName (x$quantity)";
            //     })
            //         .join(", "))
            //   ],
            // ),
            // Payment Details Card
            if (orderDetails['payments'] != null &&
                orderDetails['payments'].isNotEmpty)
              _buildCard(
                "Payment Details",
                orderDetails['payments'].map<Widget>((payment) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField("Payment ID", payment['_id']),
                      _buildTextField("Amount", payment['amount']),
                      _buildTextField("Payment Method", payment['method']),
                      _buildTextField("Status", payment['status']),
                      _buildTextField("Currency", payment['currency']),
                    ],
                  );
                }).toList(),
              ),
            // Billing Details Card
            if (orderDetails['billings'] != null &&
                orderDetails['billings'].isNotEmpty)
              _buildCard(
                "Billing Details",
                orderDetails['billings'].map<Widget>((billing) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField("Billing ID", billing['_id']),
                      _buildTextField(
                          "Payment Status", billing['paymentStatus']),
                    ],
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    //),
    );
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:io'; // Add this import to use SocketException
//
// class OrderDetailsPage extends StatefulWidget {
//   final String orderId;
//
//   OrderDetailsPage({required this.orderId});
//
//   @override
//   _OrderDetailsPageState createState() => _OrderDetailsPageState();
// }
//
// class _OrderDetailsPageState extends State<OrderDetailsPage> {
//   Map<String, dynamic> orderDetails = {};
//
//   Future<void> fetchOrderDetails() async {
//     try {
//       final response = await http.get(
//         Uri.parse("http://10.0.2.2:5000/api/healup/orders/${widget.orderId}"),
//       );
//       if (response.statusCode == 200) {
//         setState(() {
//           orderDetails = jsonDecode(response.body);
//         });
//         // طباعة رقم الأوردر بعد الحصول على التفاصيل
//         print("Order ID: ${widget.orderId}");
//
//         getPaymentByOrderId(widget.orderId);
//         getBillingByOrderId(widget.orderId); // Pass the orderId directly here
//
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to fetch order details")),
//         );
//       }
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("An error occurred: $error")),
//       );
//     }
//   }
//
//   Future<List<dynamic>?> getPaymentByOrderId(String orderId) async {
//     final url = Uri.parse(
//         'http://10.0.2.2:5000/api/healup/payment/order/$orderId'); // Use the correct IP if necessary
//
//     try {
//       final response = await http.get(url);
//
//       print('Response status: ${response.statusCode}'); // Print status code
//       print('Response body: ${response.body}'); // Print response body
//
//       if (response.statusCode == 200) {
//         var data = json.decode(response.body); // Decoding the response body
//
//         print('Response data: $data'); // Log the data for debugging
//
//         var payments = data is List ? data : data['payments'];
//
//         if (payments != null && payments is List && payments.isNotEmpty) {
//           // Store payments data for later use
//           setState(() {
//             orderDetails['payments'] = payments;
//           });
//           for (var payment in payments) {
//             print('Payment ID: ${payment['_id']}');
//             print('Amount: ${payment['amount']}');
//             print('Payment Method: ${payment['method']}');
//             print('Status: ${payment['status']}');
//             print('Currency: ${payment['currency']}');
//           }
//
//           print("mmmmmmmmmmmmmmm++++++++++++++++");
//           //getBillingByOrderId(widget.orderId);  // Pass the orderId directly here
//
//           // Correct function call without '$'
//           //getBillingByOrderId(orderId);  // Pass the orderId directly here
//         } else {
//           print('No payments found for this order ID.');
//         }
//
//         return payments; // Return the list of payments
//       } else {
//         print("Error: ${response.statusCode}");
//         throw Exception('Failed to load payments');
//       }
//     } catch (error) {
//       print("Error: $error");
//       if (error is SocketException) {
//         print('No internet connection or unable to reach the server.');
//       } else {
//         print('Error details: $error');
//       }
//       throw Exception("An error occurred while fetching payments");
//     }
//   }
//
//   Future<void> getBillingByOrderId(String orderId) async {
//     final url = 'http://10.0.2.2:5000/api/healup/billing/order/$orderId';
//
//     try {
//       // Send GET request
//       final response = await http.get(Uri.parse(url));
//
//       // Check if the response is successful
//       if (response.statusCode == 200) {
//         // Parse the JSON response
//         final List<dynamic> billings = jsonDecode(response.body);
//
//         // Store the billings data for later use
//         setState(() {
//           orderDetails['billings'] = billings;
//         });
//
//         // Print the billing information
//         print('Found ${billings.length} billing(s) for Order ID: $orderId');
//         for (var billing in billings) {
//           print('Billing ID: ${billing['_id']}');
//           print('Payment Status: ${billing['paymentStatus']}');
//         }
//       } else {
//         print('Failed to load billings. Error: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error: $error');
//     }
//   }
//
//
//   // Future<void> getBillingByOrderId(String orderId) async {
//   //   final url = 'http://10.0.2.2:5000/api/healup/billing/order/$orderId';
//   //
//   //   try {
//   //
//   //     // Send GET request
//   //     final response = await http.get(Uri.parse(url));
//   //     print("====================++++++++++++++++");
//   //
//   //     // Check if the response is successful
//   //     if (response.statusCode == 200) {
//   //       // Parse the JSON response
//   //       final List<dynamic> billings = jsonDecode(response.body);
//   //
//   //       // Print the billing information
//   //       print('Found ${billings.length} billing(s) for Order ID: $orderId');
//   //       for (var billing in billings) {
//   //         print('-------------------');
//   //         print('billing ID: ${billing['_id']}');
//   //         print('Patient: ${billing['patientId']['username']}');
//   //         print('Order ID: ${billing['orderId']['_id']}');
//   //         print('Billing Date: ${billing['billingDate']}');
//   //         print('Amount: ${billing['amount']}');
//   //         print('Payment Status: ${billing['paymentStatus']}');
//   //         print('Medications:');
//   //
//   //         for (var medication in billing['medicationList']) {
//   //           print('  Medication: ${medication['medicationName']}');
//   //           print('  Quantity: ${medication['quantity']}');
//   //           print('  Price: ${medication['price']}');
//   //         }
//   //         print('-------------------');
//   //       }
//   //     } else {
//   //       print('Failed to load billings. Error: ${response.statusCode}');
//   //     }
//   //   } catch (error) {
//   //     print('Error: $error');
//   //   }
//   // }
//
//   @override
//   void initState() {
//     super.initState();
//     fetchOrderDetails();
//   }
//
//   Widget _buildTextField(String label, dynamic value) {
//     // Convert values like int or double to String
//     String displayValue = value is double
//         ? value.toStringAsFixed(
//         2) // Convert double to String with 2 decimal places
//         : value is int ? value.toString() : value ??
//         "N/A"; // Convert int to String
//
//     return TextFormField(
//       initialValue: displayValue,
//       readOnly: true, // Ensure the field is read-only for order details
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(
//           color: Colors.grey[900],
//           fontWeight: FontWeight.bold,
//           fontSize: 24,
//         ),
//         floatingLabelBehavior: FloatingLabelBehavior.auto,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(
//             color: Color(0xff2f9a8f),
//             width: 3,
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(
//             color: Color(0xff2f9a8f),
//             width: 3,
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(color: Color(0xff2f9a8f), width: 3),
//         ),
//         fillColor: Colors.white.withOpacity(0.8),
//         filled: true,
//       ),
//       style: TextStyle(
//         color: Color(0xff2f9a8f),
//         fontWeight: FontWeight.bold,
//         fontSize: 20,
//       ),
//     );
//   }
//
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text("Order Details"),
// //         backgroundColor: Color(0xff2f9a8f),
// //       ),
// //       body: Container(
// //         decoration: BoxDecoration(
// //           image: DecorationImage(
// //             image: AssetImage('images/back.jpg'),
// //             fit: BoxFit.cover,
// //             colorFilter: ColorFilter.mode(
// //               Colors.black.withOpacity(0.3),
// //               BlendMode.darken,
// //             ),
// //           ),
// //         ),
// //         child: orderDetails.isEmpty
// //             ? Center(child: CircularProgressIndicator())
// //             : Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: ListView(
// //             children: [
// //               // Display order details
// //               _buildTextField("Order ID", orderDetails['_id']),
// //               const SizedBox(height: 10),
// //               _buildTextField("Patient", orderDetails['patient_id']['username']),
// //               const SizedBox(height: 10),
// //               _buildTextField("Order Date", orderDetails['order_date']),
// //               const SizedBox(height: 10),
// //
// //               // Display medications
// //               _buildTextField("Medications", orderDetails['medications']
// //                   .map((med) => "${med['medication_id']['medication_name']} (x${med['quantity']})")
// //                   .join(", ")),
// //               const SizedBox(height: 10),
// //
// //               // Display serial counter
// //              // _buildTextField("Serial Counter", orderDetails['serial_counter']),
// //               //const SizedBox(height: 20),
// //
// //               // Display payment details (if available)
// //               if (orderDetails['payments'] != null && orderDetails['payments'].isNotEmpty)
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       "Payment Details:",
// //                       style: TextStyle(
// //                         fontSize: 24,
// //                         fontWeight: FontWeight.bold,
// //                         color: Color(0xff2f9a8f),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 10),
// //                     ...orderDetails['payments'].map<Widget>((payment) {
// //                       return Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           _buildTextField("Payment ID", payment['_id']),
// //                           const SizedBox(height: 10),
// //                           _buildTextField("Amount", payment['amount']),
// //                           const SizedBox(height: 10),
// //                           _buildTextField("Payment Method", payment['method']),
// //                           const SizedBox(height: 10),
// //                           _buildTextField("Status", payment['status']),
// //                           const SizedBox(height: 10),
// //                           _buildTextField("Currency", payment['currency']),
// //                           const SizedBox(height: 20),
// //                         ],
// //                       );
// //                     }).toList(),
// //                   ],
// //                 ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Order Details"),
//         backgroundColor: Color(0xff2f9a8f),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('images/back.jpg'),
//             fit: BoxFit.cover,
//             colorFilter: ColorFilter.mode(
//               Colors.black.withOpacity(0.3),
//               BlendMode.darken,
//             ),
//           ),
//         ),
//         child: orderDetails.isEmpty
//             ? Center(child: CircularProgressIndicator())
//             : Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: ListView(
//             children: [
//               Text(
//                 "Order Details:",
//                 style: TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                   //color: Color(0xff2f9a8f),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // Display order details
//               _buildTextField("Order ID", orderDetails['_id']),
//               const SizedBox(height: 10),
//               _buildTextField(
//                   "Patient", orderDetails['patient_id']['username']),
//               const SizedBox(height: 10),
//               _buildTextField("Order Date", orderDetails['order_date']),
//               const SizedBox(height: 10),
//
//               // Display medications
//               _buildTextField("Medications", orderDetails['medications']
//                   .map((
//                   med) => "${med['medication_id']['medication_name']} (x${med['quantity']})")
//                   .join(", ")),
//               const SizedBox(height: 10),
//
//               // Display payment details (if available)
//               if (orderDetails['payments'] != null &&
//                   orderDetails['payments'].isNotEmpty)
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Payment Details:",
//                       style: TextStyle(
//                         fontSize: 26,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                         //color: Color(0xff2f9a8f),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     ...orderDetails['payments'].map<Widget>((payment) {
//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildTextField("Payment ID", payment['_id']),
//                           const SizedBox(height: 10),
//                           _buildTextField("Amount", payment['amount']),
//                           const SizedBox(height: 10),
//                           _buildTextField("Payment Method", payment['method']),
//                           const SizedBox(height: 10),
//                           _buildTextField("Status", payment['status']),
//                           const SizedBox(height: 10),
//                           _buildTextField("Currency", payment['currency']),
//                           const SizedBox(height: 20),
//                         ],
//                       );
//                     }).toList(),
//                   ],
//                 ),
//
//               // Display billing details (if available)
//               if (orderDetails['billings'] != null &&
//                   orderDetails['billings'].isNotEmpty)
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Billing Details:",
//                       style: TextStyle(
//                         fontSize: 26,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                         //color: Color(0xff2f9a8f),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     ...orderDetails['billings'].map<Widget>((billing) {
//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildTextField("Billing ID", billing['_id']),
//                           const SizedBox(height: 10),
//                           _buildTextField(
//                               "Payment Status", billing['paymentStatus']),
//                           const SizedBox(height: 20),
//                         ],
//                       );
//                     }).toList(),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
// }