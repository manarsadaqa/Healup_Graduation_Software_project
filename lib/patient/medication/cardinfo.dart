// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// class PaymentPage extends StatefulWidget {
//   final List<Map<String, dynamic>> cart; // Cart list
//   final String patientId; // Patient ID passed from the login page
//   final double totalPrice; // Add totalPrice parameter
//
//   const PaymentPage({
//     Key? key,
//     required this.cart,
//     required this.patientId,
//     required this.totalPrice, // Receive totalPrice
//   }) : super(key: key);
//
//   @override
//   _PaymentPageState createState() => _PaymentPageState();
// }
// class _PaymentPageState extends State<PaymentPage> {
//   // Initial selected currency (Shekel)
//   String _selectedCurrency = '₪';
//
//   // List of currencies and their symbols
//   final List<Map<String, String>> currencies = [
//     {'currency': '₪', 'name': 'Israeli Shekel'},
//     {'currency': '\$', 'name': 'US Dollar'},
//     {'currency': '€', 'name': 'Euro'},
//     {'currency': '£', 'name': 'British Pound'},
//     {'currency': '₹', 'name': 'Indian Rupee'},
//     {'currency': '¥', 'name': 'Japanese Yen'},
//     {'currency': '₣', 'name': 'Swiss Franc'},
//     {'currency': '₣', 'name': 'Canadian Dollar'},
//     {'currency': '₣', 'name': 'Australian Dollar'},
//     {'currency': '₺', 'name': 'Turkish Lira'},
//     {'currency': '₽', 'name': 'Russian Ruble'},
//     {'currency': '₴', 'name': 'Ukrainian Hryvnia'},
//     {'currency': '₱', 'name': 'Philippine Peso'},
//     {'currency': 'BRL', 'name': 'Brazilian Real'},
//     {'currency': 'KSh', 'name': 'Kenyan Shilling'},
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Payment Card"),
//         backgroundColor: const Color(0xff2f9a8f),
//       ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('images/back.jpg'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           Center(
//             child: SingleChildScrollView(  // Wrap the entire content with scroll view
//               child: Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 margin: const EdgeInsets.all(16.0),
//                 elevation: 8,
//                 child: Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Center(
//                         child: Text(
//                           "Total Price: ${widget.totalPrice.toStringAsFixed(2)}₪",  // Use widget.totalPrice
//                           style: const TextStyle(
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xff2f9a8f),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Center(
//                         child: Text(
//                           " ",
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         "Select Currency",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       // Currency Dropdown
//                       DropdownButton<String>(
//                         value: _selectedCurrency,
//                         icon: const Icon(Icons.arrow_drop_down),
//                         isExpanded: true,
//                         style: const TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                         ),
//                         onChanged: (String? newValue) {
//                           setState(() {
//                             _selectedCurrency = newValue!;
//                           });
//                         },
//                         items: currencies.map<DropdownMenuItem<String>>((currency) {
//                           return DropdownMenuItem<String>(
//                             value: currency['currency'],
//                             child: Text('${currency['name']} (${currency['currency']})'),
//                           );
//                         }).toList(),
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         "Card Information",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         children: [
//                           Expanded(
//                               flex: 3,
//                               child: TextField(
//                                 keyboardType: TextInputType.number, // نوع المدخلات: أرقام
//                                 inputFormatters: [
//                                   FilteringTextInputFormatter.digitsOnly, // يسمح فقط بالأرقام
//                                 ],
//                                 decoration: InputDecoration(
//                                   hintText: "Number", // نص التلميح الذي يظهر داخل الـ TextField
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10), // تحديد زاوية الحواف
//                                     borderSide: BorderSide(
//                                       color: Color(0xff2f9a8f), // اللون الافتراضي للحدود
//                                     ),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10), // نفس الزاوية للحدود عند التركيز
//                                     borderSide: BorderSide(
//                                       color: Color(0xff2f9a8f), // تغيير لون الحدود عند التركيز
//                                     ),
//                                   ),
//                                 ),
//                               )
//                           ),
//                           const SizedBox(width: 10),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: TextField(
//                               keyboardType: TextInputType.number,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.digitsOnly,
//                               ],
//                               decoration: InputDecoration(
//                                 hintText: "MM/YY",
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff2f9a8f), // Setting border color
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: TextField(
//                               keyboardType: TextInputType.number,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.digitsOnly,
//                               ],
//                               decoration: InputDecoration(
//                                 hintText: "CVC",
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff2f9a8f), // Setting border color
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       Center(
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xff2f9a8f),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 50,
//                               vertical: 15,
//                             ),
//                           ),
//                           onPressed: () {},
//                           child: const Text(
//                             "Pay",
//                             style: TextStyle(
//                               fontSize: 18,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
//



/////////////////////////////////////////

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'paymentCard.dart'; // تأكد من أنك أضفت الاستيراد الصحيح للصفحة الجديدة
//
// class PaymentPage extends StatefulWidget {
//   final List<Map<String, dynamic>> cart; // Cart list
//   final String patientId; // Patient ID passed from the login page
//   final double totalPrice; // Add totalPrice parameter
//
//   const PaymentPage({
//     Key? key,
//     required this.cart,
//     required this.patientId,
//     required this.totalPrice, // Receive totalPrice
//   }) : super(key: key);
//
//   @override
//   _PaymentPageState createState() => _PaymentPageState();
// }
//
// class _PaymentPageState extends State<PaymentPage> {
//   // Initial selected currency (Shekel)
//   String _selectedCurrency = '\$';
//
//   // List of currencies and their symbols
//   final List<Map<String, String>> currencies = [
//     {'currency': '₪', 'name': 'Israeli Shekel'},
//     {'currency': '\$', 'name': 'US Dollar'},
//     {'currency': '€', 'name': 'Euro'},
//     {'currency': '£', 'name': 'British Pound'},
//     {'currency': '₹', 'name': 'Indian Rupee'},
//     {'currency': '¥', 'name': 'Japanese Yen'},
//     {'currency': '₣', 'name': 'Swiss Franc'},
//     {'currency': '₣', 'name': 'Canadian Dollar'},
//     {'currency': '₣', 'name': 'Australian Dollar'},
//     {'currency': '₺', 'name': 'Turkish Lira'},
//     {'currency': '₽', 'name': 'Russian Ruble'},
//     {'currency': '₴', 'name': 'Ukrainian Hryvnia'},
//     {'currency': '₱', 'name': 'Philippine Peso'},
//     {'currency': 'BRL', 'name': 'Brazilian Real'},
//     {'currency': 'KSh', 'name': 'Kenyan Shilling'},
//   ];
//
//   // Exchange rates (you can modify these to reflect real-time rates or use an API)
//   final Map<String, double> exchangeRates = {
//     '₪': 1.0, // Israeli Shekel
//     '\$': 0.27, // US Dollar
//     '€': 0.25, // Euro
//     '£': 0.21, // British Pound
//     '₹': 22.8, // Indian Rupee
//     '¥': 36.0, // Japanese Yen
//     '₣': 0.23, // Swiss Franc
//     '₣': 0.23, // Canadian Dollar
//     '₣': 0.23, // Australian Dollar
//     '₺': 7.5,  // Turkish Lira
//     '₽': 20.0, // Russian Ruble
//     '₴': 7.5,  // Ukrainian Hryvnia
//     '₱': 14.5, // Philippine Peso
//     'BRL': 1.3, // Brazilian Real
//     'KSh': 30.0, // Kenyan Shilling
//   };
//
//   double getConvertedPrice(String currency) {
//     double exchangeRate = exchangeRates[currency] ?? 1.0; // Default to 1.0 if not found
//     double t=widget.totalPrice+5;
//     return t * exchangeRate;
//   }
//
//   // Controllers to capture input text from the fields
//   final TextEditingController cardNumberController = TextEditingController();
//   final TextEditingController expirationDateController = TextEditingController();
//   final TextEditingController cvvController = TextEditingController();
//
//   @override
//   void dispose() {
//     cardNumberController.dispose();
//     expirationDateController.dispose();
//     cvvController.dispose();
//     super.dispose();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double convertedPrice = getConvertedPrice(_selectedCurrency);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Payment Card"),
//         backgroundColor: const Color(0xff2f9a8f),
//       ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('images/back.jpg'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           Center(
//             child: SingleChildScrollView(  // Wrap the entire content with scroll view
//               child: Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 margin: const EdgeInsets.all(16.0),
//                 elevation: 8,
//                 child: Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Center(
//                         child: Text(
//                           "Total Price: ${_selectedCurrency}${convertedPrice.toStringAsFixed(2)}",
//                           style: const TextStyle(
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xff2f9a8f),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const SizedBox(height: 20),
//                       const Text(
//                         "Select Currency",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       // Currency Dropdown
//                       DropdownButton<String>(
//                         value: _selectedCurrency,
//                         icon: const Icon(Icons.arrow_drop_down),
//                         isExpanded: true,
//                         style: const TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                         ),
//                         onChanged: (String? newValue) {
//                           setState(() {
//                             _selectedCurrency = newValue!;
//                           });
//                         },
//                         items: currencies.map<DropdownMenuItem<String>>((currency) {
//                           return DropdownMenuItem<String>(
//                             value: currency['currency'],
//                             child: Text('${currency['name']} (${currency['currency']})'),
//                           );
//                         }).toList(),
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         "Card Information",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         children: [
//                           Expanded(
//                               flex: 3,
//                               child: TextField(
//                                 keyboardType: TextInputType.number, // نوع المدخلات: أرقام
//                                 inputFormatters: [
//                                   FilteringTextInputFormatter.digitsOnly, // يسمح فقط بالأرقام
//                                 ],
//                                 decoration: InputDecoration(
//                                   hintText: "Number", // نص التلميح الذي يظهر داخل الـ TextField
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10), // تحديد زاوية الحواف
//                                     borderSide: BorderSide(
//                                       color: Color(0xff2f9a8f), // اللون الافتراضي للحدود
//                                     ),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10), // نفس الزاوية للحدود عند التركيز
//                                     borderSide: BorderSide(
//                                       color: Color(0xff2f9a8f), // تغيير لون الحدود عند التركيز
//                                     ),
//                                   ),
//                                 ),
//                               )
//                           ),
//                           const SizedBox(width: 10),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: TextField(
//                               controller: expirationDateController,
//                               keyboardType: TextInputType.number,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.digitsOnly,
//                               ],
//                               decoration: InputDecoration(
//                                 hintText: "MM/YY",
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff2f9a8f), // Setting border color
//                                   ),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff2f9a8f), // Focused border color
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: TextField(
//                               controller: cvvController,
//                               keyboardType: TextInputType.number,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.digitsOnly,
//                               ],
//                               decoration: InputDecoration(
//                                 hintText: "CVV",
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff2f9a8f), // Setting border color
//                                   ),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff2f9a8f), // Focused border color
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       Center(
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xff2f9a8f),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 50,
//                               vertical: 15,
//                             ),
//                           ),
//                           onPressed: () {
//                             String currency = "USD"; // Define the currency (you can make it dynamic if needed)
//
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => PayPalPayment(
//                                   totalPrice: widget.totalPrice,
//                                   currency: currency,
//                                 ),
//                               ),
//                             );
//                           },
//                           child: const Text(
//                             "Pay",
//                             style: TextStyle(
//                               fontSize: 18,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'paymentCard.dart'; // تأكد من أنك أضفت الاستيراد الصحيح للصفحة الجديدة

class PaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart; // Cart list
  final String patientId; // Patient ID passed from the login page
  final double totalPrice; // Add totalPrice parameter

  const PaymentPage({
    Key? key,
    required this.cart,
    required this.patientId,
    required this.totalPrice, // Receive totalPrice
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  // Initial selected currency (Shekel)
  String _selectedCurrency = '\$';

  // List of currencies and their symbols
  final List<Map<String, String>> currencies = [
    {'currency': '₪', 'name': 'Israeli Shekel'},
    {'currency': '\$', 'name': 'US Dollar'},
    {'currency': '€', 'name': 'Euro'},
    {'currency': '£', 'name': 'British Pound'},
    {'currency': '₹', 'name': 'Indian Rupee'},
    {'currency': '¥', 'name': 'Japanese Yen'},
    {'currency': '₣', 'name': 'Swiss Franc'},
    {'currency': '₣', 'name': 'Canadian Dollar'},
    {'currency': '₣', 'name': 'Australian Dollar'},
    {'currency': '₺', 'name': 'Turkish Lira'},
    {'currency': '₽', 'name': 'Russian Ruble'},
    {'currency': '₴', 'name': 'Ukrainian Hryvnia'},
    {'currency': '₱', 'name': 'Philippine Peso'},
    {'currency': 'BRL', 'name': 'Brazilian Real'},
    {'currency': 'KSh', 'name': 'Kenyan Shilling'},
  ];

  // Exchange rates (you can modify these to reflect real-time rates or use an API)
  final Map<String, double> exchangeRates = {
    '₪': 1.0, // Israeli Shekel
    '\$': 0.27, // US Dollar
    '€': 0.25, // Euro
    '£': 0.21, // British Pound
    '₹': 22.8, // Indian Rupee
    '¥': 36.0, // Japanese Yen
    '₣': 0.23, // Swiss Franc
    '₣': 0.23, // Canadian Dollar
    '₣': 0.23, // Australian Dollar
    '₺': 7.5,  // Turkish Lira
    '₽': 20.0, // Russian Ruble
    '₴': 7.5,  // Ukrainian Hryvnia
    '₱': 14.5, // Philippine Peso
    'BRL': 1.3, // Brazilian Real
    'KSh': 30.0, // Kenyan Shilling
  };

  double getConvertedPrice(String currency) {
    double exchangeRate = exchangeRates[currency] ?? 1.0; // Default to 1.0 if not found
    double t=widget.totalPrice+5;
    return t * exchangeRate;
  }

  // Controllers to capture input text from the fields
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expirationDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  @override
  void dispose() {
    cardNumberController.dispose();
    expirationDateController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double convertedPrice = getConvertedPrice(_selectedCurrency);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Card"),
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
            child: SingleChildScrollView(  // Wrap the entire content with scroll view
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.all(16.0),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Card Information",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              keyboardType: TextInputType.number, // نوع المدخلات: أرقام
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly, // يسمح فقط بالأرقام
                              ],
                              decoration: InputDecoration(
                                hintText: "Number", // نص التلميح الذي يظهر داخل الـ TextField
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10), // تحديد زاوية الحواف
                                  borderSide: BorderSide(
                                    color: Color(0xff2f9a8f), // اللون الافتراضي للحدود
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10), // نفس الزاوية للحدود عند التركيز
                                  borderSide: BorderSide(
                                    color: Color(0xff2f9a8f), // تغيير لون الحدود عند التركيز
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: expirationDateController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                hintText: "MM/YY",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xff2f9a8f), // Setting border color
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xff2f9a8f), // Focused border color
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: cvvController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                hintText: "CVV",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xff2f9a8f), // Setting border color
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xff2f9a8f), // Focused border color
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),  // Add this line to separate the Center widget properly
                      Center(
                        child: Text(
                          "Total Price: ${_selectedCurrency}${convertedPrice.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff2f9a8f),
                          ),
                        ),
                      ),
                      //const SizedBox(height: 8),
                      const SizedBox(height: 20),
                      const Text(
                        "Select Currency",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Currency Dropdown
                      DropdownButton<String>(
                        value: _selectedCurrency,
                        icon: const Icon(Icons.arrow_drop_down),
                        isExpanded: true,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCurrency = newValue!;
                          });
                        },
                        items: currencies.map<DropdownMenuItem<String>>((currency) {
                          return DropdownMenuItem<String>(
                            value: currency['currency'],
                            child: Text('${currency['name']} (${currency['currency']})'),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff2f9a8f),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 15,
                            ),
                          ),
                          onPressed: () {
                            String currency = "USD"; // Define the currency (you can make it dynamic if needed)

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PayPalPayment(
                                  totalPrice: widget.totalPrice,
                                  currency: currency,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "Pay",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Center(
          //   child: SingleChildScrollView(  // Wrap the entire content with scroll view
          //     child: Card(
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(15),
          //       ),
          //       margin: const EdgeInsets.all(16.0),
          //       elevation: 8,
          //       child: Padding(
          //         padding: const EdgeInsets.all(20.0),
          //         child: Column(
          //           mainAxisSize: MainAxisSize.min,
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             const SizedBox(height: 20),
          //             const Text(
          //               "Card Information",
          //               style: TextStyle(
          //                 fontSize: 18,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //             const SizedBox(height: 10),
          //             Row(
          //               children: [
          //                 Expanded(
          //                     flex: 3,
          //                     child: TextField(
          //                       keyboardType: TextInputType.number, // نوع المدخلات: أرقام
          //                       inputFormatters: [
          //                         FilteringTextInputFormatter.digitsOnly, // يسمح فقط بالأرقام
          //                       ],
          //                       decoration: InputDecoration(
          //                         hintText: "Number", // نص التلميح الذي يظهر داخل الـ TextField
          //                         border: OutlineInputBorder(
          //                           borderRadius: BorderRadius.circular(10), // تحديد زاوية الحواف
          //                           borderSide: BorderSide(
          //                             color: Color(0xff2f9a8f), // اللون الافتراضي للحدود
          //                           ),
          //                         ),
          //                         focusedBorder: OutlineInputBorder(
          //                           borderRadius: BorderRadius.circular(10), // نفس الزاوية للحدود عند التركيز
          //                           borderSide: BorderSide(
          //                             color: Color(0xff2f9a8f), // تغيير لون الحدود عند التركيز
          //                           ),
          //                         ),
          //                       ),
          //                     )
          //                 ),
          //                 const SizedBox(width: 10),
          //               ],
          //             ),
          //             const SizedBox(height: 10),
          //             Row(
          //               children: [
          //                 Expanded(
          //                   child: TextField(
          //                     controller: expirationDateController,
          //                     keyboardType: TextInputType.number,
          //                     inputFormatters: [
          //                       FilteringTextInputFormatter.digitsOnly,
          //                     ],
          //                     decoration: InputDecoration(
          //                       hintText: "MM/YY",
          //                       border: OutlineInputBorder(
          //                         borderRadius: BorderRadius.circular(10),
          //                         borderSide: const BorderSide(
          //                           color: Color(0xff2f9a8f), // Setting border color
          //                         ),
          //                       ),
          //                       focusedBorder: OutlineInputBorder(
          //                         borderRadius: BorderRadius.circular(10),
          //                         borderSide: const BorderSide(
          //                           color: Color(0xff2f9a8f), // Focused border color
          //                         ),
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //                 const SizedBox(width: 10),
          //                 Expanded(
          //                   child: TextField(
          //                     controller: cvvController,
          //                     keyboardType: TextInputType.number,
          //                     inputFormatters: [
          //                       FilteringTextInputFormatter.digitsOnly,
          //                     ],
          //                     decoration: InputDecoration(
          //                       hintText: "CVV",
          //                       border: OutlineInputBorder(
          //                         borderRadius: BorderRadius.circular(10),
          //                         borderSide: const BorderSide(
          //                           color: Color(0xff2f9a8f), // Setting border color
          //                         ),
          //                       ),
          //                       focusedBorder: OutlineInputBorder(
          //                         borderRadius: BorderRadius.circular(10),
          //                         borderSide: const BorderSide(
          //                           color: Color(0xff2f9a8f), // Focused border color
          //                         ),
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //               ],
          //             )
          //             Center(
          //               child: Text(
          //                 "Total Price: ${_selectedCurrency}${convertedPrice.toStringAsFixed(2)}",
          //                 style: const TextStyle(
          //                   fontSize: 32,
          //                   fontWeight: FontWeight.bold,
          //                   color: Color(0xff2f9a8f),
          //                 ),
          //               ),
          //             ),
          //             const SizedBox(height: 8),
          //             const SizedBox(height: 20),
          //             const Text(
          //               "Select Currency",
          //               style: TextStyle(
          //                 fontSize: 18,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //             const SizedBox(height: 10),
          //             // Currency Dropdown
          //             DropdownButton<String>(
          //               value: _selectedCurrency,
          //               icon: const Icon(Icons.arrow_drop_down),
          //               isExpanded: true,
          //               style: const TextStyle(
          //                 color: Colors.black,
          //                 fontSize: 16,
          //               ),
          //               onChanged: (String? newValue) {
          //                 setState(() {
          //                   _selectedCurrency = newValue!;
          //                 });
          //               },
          //               items: currencies.map<DropdownMenuItem<String>>((currency) {
          //                 return DropdownMenuItem<String>(
          //                   value: currency['currency'],
          //                   child: Text('${currency['name']} (${currency['currency']})'),
          //                 );
          //               }).toList(),
          //             ),
          //             // const SizedBox(height: 20),
          //             // const Text(
          //             //   "Card Information",
          //             //   style: TextStyle(
          //             //     fontSize: 18,
          //             //     fontWeight: FontWeight.bold,
          //             //   ),
          //             // ),
          //             // const SizedBox(height: 10),
          //             // Row(
          //             //   children: [
          //             //     Expanded(
          //             //         flex: 3,
          //             //         child: TextField(
          //             //           keyboardType: TextInputType.number, // نوع المدخلات: أرقام
          //             //           inputFormatters: [
          //             //             FilteringTextInputFormatter.digitsOnly, // يسمح فقط بالأرقام
          //             //           ],
          //             //           decoration: InputDecoration(
          //             //             hintText: "Number", // نص التلميح الذي يظهر داخل الـ TextField
          //             //             border: OutlineInputBorder(
          //             //               borderRadius: BorderRadius.circular(10), // تحديد زاوية الحواف
          //             //               borderSide: BorderSide(
          //             //                 color: Color(0xff2f9a8f), // اللون الافتراضي للحدود
          //             //               ),
          //             //             ),
          //             //             focusedBorder: OutlineInputBorder(
          //             //               borderRadius: BorderRadius.circular(10), // نفس الزاوية للحدود عند التركيز
          //             //               borderSide: BorderSide(
          //             //                 color: Color(0xff2f9a8f), // تغيير لون الحدود عند التركيز
          //             //               ),
          //             //             ),
          //             //           ),
          //             //         )
          //             //     ),
          //             //     const SizedBox(width: 10),
          //             //   ],
          //             // ),
          //             // const SizedBox(height: 10),
          //             // Row(
          //             //   children: [
          //             //     Expanded(
          //             //       child: TextField(
          //             //         controller: expirationDateController,
          //             //         keyboardType: TextInputType.number,
          //             //         inputFormatters: [
          //             //           FilteringTextInputFormatter.digitsOnly,
          //             //         ],
          //             //         decoration: InputDecoration(
          //             //           hintText: "MM/YY",
          //             //           border: OutlineInputBorder(
          //             //             borderRadius: BorderRadius.circular(10),
          //             //             borderSide: const BorderSide(
          //             //               color: Color(0xff2f9a8f), // Setting border color
          //             //             ),
          //             //           ),
          //             //           focusedBorder: OutlineInputBorder(
          //             //             borderRadius: BorderRadius.circular(10),
          //             //             borderSide: const BorderSide(
          //             //               color: Color(0xff2f9a8f), // Focused border color
          //             //             ),
          //             //           ),
          //             //         ),
          //             //       ),
          //             //     ),
          //             //     const SizedBox(width: 10),
          //             //     Expanded(
          //             //       child: TextField(
          //             //         controller: cvvController,
          //             //         keyboardType: TextInputType.number,
          //             //         inputFormatters: [
          //             //           FilteringTextInputFormatter.digitsOnly,
          //             //         ],
          //             //         decoration: InputDecoration(
          //             //           hintText: "CVV",
          //             //           border: OutlineInputBorder(
          //             //             borderRadius: BorderRadius.circular(10),
          //             //             borderSide: const BorderSide(
          //             //               color: Color(0xff2f9a8f), // Setting border color
          //             //             ),
          //             //           ),
          //             //           focusedBorder: OutlineInputBorder(
          //             //             borderRadius: BorderRadius.circular(10),
          //             //             borderSide: const BorderSide(
          //             //               color: Color(0xff2f9a8f), // Focused border color
          //             //             ),
          //             //           ),
          //             //         ),
          //             //       ),
          //             //     ),
          //             //   ],
          //             // ),
          //             const SizedBox(height: 20),
          //             Center(
          //
          //               child: ElevatedButton(
          //                 style: ElevatedButton.styleFrom(
          //                   backgroundColor: const Color(0xff2f9a8f),
          //                   shape: RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(10),
          //                   ),
          //                   padding: const EdgeInsets.symmetric(
          //                     horizontal: 50,
          //                     vertical: 15,
          //                   ),
          //                 ),
          //                 onPressed: () {
          //                   String currency = "USD"; // Define the currency (you can make it dynamic if needed)
          //
          //                   Navigator.push(
          //                     context,
          //                     MaterialPageRoute(
          //                       builder: (context) => PayPalPayment(
          //                         totalPrice: widget.totalPrice,
          //                         currency: currency,
          //                       ),
          //                     ),
          //                   );
          //                 },
          //                 child: const Text(
          //                   "Pay",
          //                   style: TextStyle(
          //                     fontSize: 18,
          //                     color: Colors.white,
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
