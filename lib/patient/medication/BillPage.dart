import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BillPage extends StatelessWidget {
  final String billingId;

  BillPage({required this.billingId});

  // Fetch Billing Details
  Future<Map<String, dynamic>> fetchBillingDetails(String id) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/healup/billing/$id'),
      );

      print('Response: ${response.body}'); // Debugging
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['billing']; // Extract billing details
      } else {
        throw Exception('Failed to load billing details: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error: ${error.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bill Details"),
        backgroundColor: const Color(0xff2f9a8f),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchBillingDetails(billingId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No billing details available.'));
          }

          final billing = snapshot.data!;
          final medicationList = billing['medicationList'] as List<dynamic>? ?? [];
          final totalAmount = billing['amount'] ?? 0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title - healup
                Center(
                  child: Text(
                    'healup',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Billing Date on the left
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      ' Date: ${billing['billingDate'] ?? "N/A"}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Divider to separate the Billing Date and Medications section
                const Divider(
                  color: Colors.black,  // Color of the line
                  thickness: 1,         // Thickness of the line
                  indent: 0,            // Indentation from the start
                  endIndent: 0,         // Indentation from the end
                ),

                const SizedBox(height: 10),

                // Medications Section - White Card Style
                Center(
                  child: Text(
                    'Medications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Display medications as cards
                medicationList.isEmpty
                    ? const Text('No medications found.')
                    : Column(
                  children: medicationList.map((med) {
                    final medicationName = med['medicationName'] ?? 'Unknown';
                    final quantity = med['quantity'] ?? 0;
                    final price = med.containsKey('price')
                        ? (med['price'] * quantity).toStringAsFixed(2)
                        : 'N/A';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Removed the image section, no longer showing image
                            const SizedBox(width: 16),

                            // Medication info on the right
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    medicationName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Quantity: $quantity",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    "Price: ₪$price",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                const Divider(),

                // Total Amount in a Box at the Bottom
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xff2f9a8f),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Total Amount: ₪${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}



