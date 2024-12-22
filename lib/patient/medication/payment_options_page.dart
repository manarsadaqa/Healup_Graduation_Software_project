import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'paymentCard.dart';
import 'cart.dart';
import 'cardinfo.dart';
import 'map.dart';

class PaymentOptionsPage extends StatefulWidget {
  final double totalPrice;
  final String patientId;
  final List<Map<String, dynamic>> cart;

  PaymentOptionsPage({
    Key? key,
    required this.totalPrice,
    required this.patientId,
    required this.cart,
  }) : super(key: key);

  @override
  _PaymentOptionsPageState createState() => _PaymentOptionsPageState();
}

class _PaymentOptionsPageState extends State<PaymentOptionsPage> {
  late String patientAddress;
  bool isLoading = true;
  final TextEditingController _addressController = TextEditingController(); // Controller for user input

  // Create a GlobalKey for CartPage to access the CartPage state
  final GlobalKey<CartPageState> cartPageKey = GlobalKey<CartPageState>();

  @override
  void initState() {
    super.initState();
    fetchPatientDetails();
  }

  Future<void> fetchPatientDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/healup/patients/getPatientById/${widget.patientId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          patientAddress = data['address'] ?? 'Address not available';
          isLoading = false;
        });
      } else {
        setState(() {
          patientAddress = 'Address not available';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        patientAddress = 'Error fetching address';
        isLoading = false;
      });
    }
  }

  // Method to show dialog for changing the pickup location
  void _showChangeLocationDialog() {
    _addressController.text = patientAddress; // Pre-fill the current address

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Change Pickup Location"),
          content: TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: "Enter new address",
            ),
            keyboardType: TextInputType.streetAddress,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Save"),
              onPressed: () {
                setState(() {
                  patientAddress = _addressController.text; // Update address
                });
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm order"),
        backgroundColor: const Color(0xff2f9a8f),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/back.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              width: 400,
              height: 600,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Your Pickup location : ",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  isLoading
                      ? CircularProgressIndicator()
                      : Text(
                    patientAddress,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: _showChangeLocationDialog, // Show dialog when pressed
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    child: const Text(
                      "Change Pickup Location",
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xff2f9a8f), // Use the desired color for the text
                      ),
                    ),
                  ),
                  const Text(
                    " ",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8), // حشو داخل الحافة
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFFB0B0B0), // لون الحدود الأسود الفاتح (رمادي غامق)

                        //color: Colors.black, // اللون الأسود للحدود
                        width: 1, // سمك الحدود (رفيع)
                      ),
                      borderRadius: BorderRadius.circular(4), // حواف دائرية خفيفة (اختياري)
                    ),
                    child: const Text(
                      "Delivery fees \$5",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // const Text(
                  //   " Delivery fees \$10",
                  //   style: TextStyle(
                  //     fontSize: 20,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.black,
                  //   ),
                  // ),

                  ElevatedButton(
                    onPressed: () {
                      // الانتقال إلى صفحة OrderTrackingPage وتمرير عنوان المريض
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderTrackingPage(patientAddress: patientAddress), // تم تمرير العنوان
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2f9a8f),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    child: const Text(
                      "map",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),

                  // ElevatedButton(
                  //   onPressed: () {
                  //     // الانتقال إلى صفحة OrderTrackingPage
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => const OrderTrackingPage(), // انتقل إلى OrderTrackingPage
                  //       ),
                  //     );
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: const Color(0xff2f9a8f),
                  //     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  //   ),
                  //   child: const Text(
                  //     "map",
                  //     style: TextStyle(fontSize: 18, color: Colors.white),
                  //   ),
                  // ),

                  // ElevatedButton(
                  //   onPressed: () {
                  //     // Navigate to the Test widget (Map screen) and pass patientAddress
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => Test(
                  //           patientAddress: patientAddress, // Pass the address here
                  //         ),
                  //       ),
                  //     );
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: const Color(0xff2f9a8f),
                  //     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  //   ),
                  //   child: const Text(
                  //     "map",
                  //     style: TextStyle(fontSize: 18, color: Colors.white),
                  //   ),
                  // ),


                  // ElevatedButton(
                  //   onPressed: () {
                  //     // Navigate to the Test widget (Map screen)
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => const Test()),
                  //     );
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: const Color(0xff2f9a8f),
                  //     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  //   ),
                  //   child: const Text(
                  //     "map",
                  //     style: TextStyle(fontSize: 18, color: Colors.white),
                  //   ),
                  // ),
                  // const Text(
                  //   " ",
                  //   style: TextStyle(
                  //     fontSize: 20,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.black,
                  //   ),
                  // ),
                  //                   const SizedBox(height: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center, // لضبط المحاذاة إلى اليسار
                    children: [
                      const Text(
                        "Choose Payment Method",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // توزيع المسافة بالتساوي بين الأزرار
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentPage(
                                    cart: widget.cart,
                                    patientId: widget.patientId,
                                    totalPrice: widget.totalPrice,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff2f9a8f),
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            ),
                            child: const Text(
                              "Pay with Card",
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 20), // إضافة مسافة بين الأزرار
                          ElevatedButton(
                            onPressed: () async {
                              // Access the CartPage state and call addOrderWithCash
                              final cartPageState = cartPageKey.currentState;
                              if (cartPageState != null) {
                                await cartPageState.addOrderWithCash(
                                    context, widget.patientId, widget.totalPrice, widget.cart
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('CartPage state not found!'))
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff2f9a8f),
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            ),
                            child: const Text(
                              "Pay with Cash",
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // إضافة مسافة بين الأزرار
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



