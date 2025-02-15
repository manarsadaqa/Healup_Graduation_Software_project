import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../patient/managementMainPage.dart';
import '../medication/medicationList.dart';
import 'orderDetailPage.dart';
import '../managements/managementList.dart';
import '../doctor/doctorList.dart';

class OrderListPage extends StatefulWidget {
  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> filteredOrders = [];
  int _currentIndex = 3;
  String _searchText = '';



  Future<void> fetchOrders() async {
    try {
      final response = await http.get(
          Uri.parse("http://10.0.2.2:5000/api/healup/orders/"));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          orders = data.map((order) {
            return {
              'id': order['_id'],
              'patient': order['patient_id']['username'] ?? 'Not provided',
              'medications': (order['medications'] as List<dynamic>?)
                  ?.map((med) {
                // Add null checks for medication_id and medication_name
                return med['medication_id'] != null
                    ? med['medication_id']['medication_name'] ?? 'Unknown medication'
                    : 'Unknown medication';
              })
                  .join(", ") ?? 'No medications',
              'order_date': order['order_date'] ?? 'Not provided',
              'serial_counter': order['serial_counter'] ?? 'Not provided',
            };
          }).toList();
          filteredOrders = List.from(orders);
        });
        print(data);  // طباعة البيانات لتفقد محتوياتها

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch orders: ${response.reasonPhrase}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $error")),
      );
    }
  }
  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ManagementMainPage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DoctorListPage()),
      );
    } else if (index == 2) {
      // Navigate to Medication page (assuming you have one)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicationListPage(),
        ),
      );
    } else if (index == 3) {
      // Navigate to Order page (assuming you have one)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderListPage(),
        ),
      );
    } else if (index == 4) {
      // Navigate to Management page (if necessary)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ManagementListPage(),
        ),
      );
    }
  }

  void _filterOrders() {
    setState(() {
      if (_searchText.isEmpty) {
        filteredOrders = List.from(orders);
      } else {
        filteredOrders = orders.where((order) {
          return order['patient']
              .toLowerCase()
              .contains(_searchText.toLowerCase());
        }).toList();
      }
    });
  }

  void _deleteOrder(String orderId) async {
    try {
      final response = await http.delete(
        Uri.parse("http://10.0.2.2:5000/api/healup/orders/delete/$orderId"),
      );
      if (response.statusCode == 200) {
        setState(() {
          filteredOrders.removeWhere((order) => order['id'] == orderId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Order deleted successfully.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete order: ${response.reasonPhrase}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $error")),
      );
    }
  }

  void _showDeleteDialog(String orderId, String patientName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete the order for $patientName?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xff2f9a8f),
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();  // Close the dialog
                _deleteOrder(orderId);  // Delete order
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2f9a8f),
              ),
              child: const Text("Delete"),
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
        automaticallyImplyLeading: false,  // لإزالة سهم التراجع
        title: const Text(
          "Order List",
          style: TextStyle(
            fontSize: 24,  // زيادة حجم الخط
            fontWeight: FontWeight.bold,  // جعل الخط عريض
          ),
        ),
        backgroundColor: const Color(0xff2f9a8f),

      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/back.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                  _filterOrders();
                },
                decoration: InputDecoration(
                  hintText: "Search for patient",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
            orders.isEmpty
                ? const Center(
              child: Text(
                "No orders found.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderDetailsPage(orderId: order['id']),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.shopping_cart, color: Colors.black45),
                              onPressed: () {
                               // _showDeleteDialog(order['id'], order['patient']);
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Display "Order ID" text in one line
                                  Text(
                                    "Order #${order['serial_counter'] ?? 'N/A'}",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  // Display Patient Name below Order ID
                                  Text(
                                    "Patient: ${order['patient']}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "Order Date: ${order['order_date']}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // IconButton(
                            //   icon: const Icon(Icons.delete, color: Colors.red),
                            //   onPressed: () {
                            //     _showDeleteDialog(order['id'], order['patient']);
                            //   },
                            // ),
                          ],
                        ),
                      ),

                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        backgroundColor: const Color(0xff2f9a8f),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Patient",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: "Doctor",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_pharmacy),
            label: "Medication",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Order",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: "Management",
          ),
        ],
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// //import 'orderDetailPage.dart';  // Page to display details of a specific order
// import '../patient/managementMainPage.dart';
// import 'AddOrderPage.dart';  // Import page to add a new order (assuming it's created)
// import '../medication/medicationList.dart';
//
// class OrderListPage extends StatefulWidget {
//   @override
//   _OrderListPageState createState() => _OrderListPageState();
// }
//
// class _OrderListPageState extends State<OrderListPage> {
//   List<Map<String, dynamic>> orders = [];
//   List<Map<String, dynamic>> filteredOrders = [];
//   int _currentIndex = 1;
//   String _searchText = '';
//
//   Future<void> fetchOrders() async {
//     try {
//       final response = await http.get(
//           Uri.parse("http://10.0.2.2:5000/api/healup/orders/"));
//       if (response.statusCode == 200) {
//         List<dynamic> data = jsonDecode(response.body);
//         setState(() {
//           orders = data.map((order) {
//             return {
//               'id': order['_id'],
//               'patient': order['patient_id']['username'] ?? 'Not provided',
//               'medications': order['medications']
//                   .map((med) => med['medication_id']['medication_name'])
//                   .join(", "),
//               'status': order['status'] ?? 'Not provided',
//             };
//           }).toList();
//           filteredOrders = List.from(orders);
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to fetch orders: ${response.reasonPhrase}")),
//         );
//       }
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("An error occurred: $error")),
//       );
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     fetchOrders();
//   }
//
//   void onTabTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//
//     if (index == 0) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => ManagementMainPage()),
//       );
//     } else if (index == 1) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => OrderListPage()),
//       );
//     } else if (index == 2) {
//       //Navigate to Medication page (assuming you have one)
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => MedicationListPage(),
//         ),
//       );
//     } else if (index == 3) {
//       //Navigate to Order page (assuming you have one)
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => OrderListPage(),
//         ),
//       );
//     } else if (index == 4) {
//       // Navigate to Management page (if necessary)
//       // Navigator.push(
//       //   context,
//       //   MaterialPageRoute(
//       //     builder: (context) => ManagementPage(),
//       //   ),
//       // );
//     }
//   }
//
//   void _filterOrders() {
//     setState(() {
//       if (_searchText.isEmpty) {
//         filteredOrders = List.from(orders);
//       } else {
//         filteredOrders = orders.where((order) {
//           return order['patient']
//               .toLowerCase()
//               .contains(_searchText.toLowerCase());
//         }).toList();
//       }
//     });
//   }
//
//   void _deleteOrder(String orderId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse("http://10.0.2.2:5000/api/healup/orders/delete/$orderId"),
//       );
//       if (response.statusCode == 200) {
//         setState(() {
//           filteredOrders.removeWhere((order) => order['id'] == orderId);
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Order deleted successfully.")),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to delete order: ${response.reasonPhrase}")),
//         );
//       }
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("An error occurred: $error")),
//       );
//     }
//   }
//
//   void _showDeleteDialog(String orderId, String patientName) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Confirm Delete"),
//           content: Text("Are you sure you want to delete the order for $patientName?"),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();  // Close the dialog
//               },
//               style: TextButton.styleFrom(
//                 backgroundColor: const Color(0xff2f9a8f),
//               ),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.of(context).pop();  // Close the dialog
//                 _deleteOrder(orderId);  // Delete order
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xff2f9a8f),
//               ),
//               child: const Text("Delete"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Order List"),
//         backgroundColor: const Color(0xff2f9a8f),
//         automaticallyImplyLeading: false,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => ManagementMainPage()),
//             );
//           },
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () {
//               // Navigator.push(
//               //   context,
//               //   MaterialPageRoute(
//               //     builder: (context) => AddOrderPage(),  // Page to add a new order
//               //   ),
//               // );
//             },
//           ),
//         ],
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
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: TextField(
//                 onChanged: (value) {
//                   setState(() {
//                     _searchText = value;
//                   });
//                   _filterOrders();
//                 },
//                 decoration: InputDecoration(
//                   hintText: "Search for patient",
//                   prefixIcon: const Icon(Icons.search),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(25.0),
//                   ),
//                   filled: true,
//                   fillColor: Colors.white.withOpacity(0.7),
//                 ),
//               ),
//             ),
//             orders.isEmpty
//                 ? const Center(
//               child: Text(
//                 "No orders found.",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//             )
//                 : Expanded(
//               child: ListView.builder(
//                 itemCount: filteredOrders.length,
//                 itemBuilder: (context, index) {
//                   final order = filteredOrders[index];
//                   return GestureDetector(
//                     onTap: () {
//                       // Navigator.push(
//                       //   context,
//                       //   MaterialPageRoute(
//                       //     builder: (context) =>
//                       //         OrderDetailsPage(orderId: order['id']),
//                       //   ),
//                       // );
//                     },
//                     child: Card(
//                       margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12.0),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "Patient: ${order['patient']}",
//                                     style: const TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   Text(
//                                     "Medications: ${order['medications']}",
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                   Text(
//                                     "Status: ${order['status']}",
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.delete, color: Colors.red),
//                               onPressed: () {
//                                 _showDeleteDialog(order['id'], order['patient']);
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _currentIndex,
//         onTap: onTabTapped,
//         backgroundColor: const Color(0xff2f9a8f),
//         selectedItemColor: Colors.white,
//         unselectedItemColor: Colors.black54,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: "Patient",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.medical_services),
//             label: "Doctor",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.local_pharmacy),
//             label: "Medication",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.shopping_cart),
//             label: "Order",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: "Management",
//           ),
//         ],
//       ),
//     );
//   }
// }
