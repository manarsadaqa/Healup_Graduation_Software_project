import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../patient/managementMainPage.dart';
import '../medication/medicationList.dart';
import '../order/orderList.dart';
import '../doctor/doctorList.dart';
import 'managementDetailPage.dart';
import 'AddManagementPage.dart';
import '../managementLogin.dart';

class ManagementListPage extends StatefulWidget {
  @override
  _ManagementListPageState createState() => _ManagementListPageState();
}

class _ManagementListPageState extends State<ManagementListPage> {
  List<Map<String, dynamic>> managements = [];
  List<Map<String, dynamic>> filteredManagements = [];
  int _currentIndex = 4;
  String _searchText = '';

  Future<void> fetchManagements() async {
    try {
      final response = await http.get(
          Uri.parse("http://10.0.2.2:5000/api/healup/management/"));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          managements = data.map((management) {
            return {
              'id': management['_id'],
              'name': management['name'],
              'gender': management['gender'] ?? 'Not provided',
              'phone': management['phone'] ?? 'Not provided',
              'address': management['address'] ?? 'Not provided',
              'email': management['email'] ?? 'Not provided',
              'pic': management['photo'] ?? 'images/default_manager.png',
            };
          }).toList();
          filteredManagements = List.from(managements);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch managements: ${response.reasonPhrase}")),
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
    fetchManagements();
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
    }  else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MedicationListPage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OrderListPage()),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ManagementListPage()),
      );
    }
  }

  void _filterManagements() {
    setState(() {
      if (_searchText.isEmpty) {
        filteredManagements = List.from(managements);
      } else {
        filteredManagements = managements.where((management) {
          return management['name']
              .toLowerCase()
              .contains(_searchText.toLowerCase());
        }).toList();
      }
    });
  }

  void _deleteManagement(String managementId) async {
    try {
      final response = await http.delete(
        Uri.parse("http://10.0.2.2:5000/api/healup/management/delete/$managementId"),
      );
      if (response.statusCode == 200) {
        setState(() {
          filteredManagements.removeWhere((management) => management['id'] == managementId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Management data deleted successfully.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete management: ${response.reasonPhrase}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $error")),
      );
    }
  }

  void _showDeleteDialog(String managementId, String managementName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete $managementName?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xff2f9a8f),
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                _deleteManagement(managementId);
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
          "Management List",
          style: TextStyle(
            fontSize: 24,  // زيادة حجم الخط
            fontWeight: FontWeight.bold,  // جعل الخط عريض
          ),
        ),
        backgroundColor: const Color(0xff2f9a8f),

        actions: [
          // أيقونة إضافة (Add)
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddManagementPage(),  // الانتقال لصفحة إضافة الإدارة
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManagementLoginPage(),  // الانتقال لصفحة إضافة الإدارة
                ),
              );
            },
          ),
        ],
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
                  _filterManagements();
                },
                decoration: InputDecoration(
                  hintText: "Search for management",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
            managements.isEmpty
                ? const Center(
              child: Text(
                "No management found.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: filteredManagements.length,
                itemBuilder: (context, index) {
                  final management = filteredManagements[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ManagementDetailsPage(managementId: management['id']),
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
                            // CircleAvatar(
                            //   radius: 35,
                            //   backgroundImage: NetworkImage(management['pic']),
                            // ),
                            //const SizedBox(width: 16.0),
                            IconButton(
                              icon: const Icon(Icons.admin_panel_settings, color: Colors.black45),
                              onPressed: () {
                                // _showDeleteDialog(order['id'], order['patient']);
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    management['name'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Gender: ${management['gender']}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  // Text(
                                  //   "Phone: ${management['phone']}",
                                  //   style: const TextStyle(
                                  //     fontSize: 14,
                                  //     color: Colors.grey,
                                  //   ),
                                  // ),
                                  // Text(
                                  //   "Email: ${management['email']}",
                                  //   style: const TextStyle(
                                  //     fontSize: 14,
                                  //     color: Colors.grey,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteDialog(management['id'], management['name']);
                              },
                            ),
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
// //import 'managementDetailPage.dart';
// import '../patient/managementMainPage.dart';
// //import 'AddManagementPage.dart';  // Import the page for adding new management data
// import '../medication/medicationList.dart';
// import '../order/orderList.dart';
// //import '../managements/managementList.dart';
//
// class ManagementListPage extends StatefulWidget {
//   @override
//   _ManagementListPageState createState() => _ManagementListPageState();
// }
//
// class _ManagementListPageState extends State<ManagementListPage> {
//   List<Map<String, dynamic>> managements = [];
//   List<Map<String, dynamic>> filteredManagements = [];
//   int _currentIndex = 4;
//   String _searchText = '';
//
//   Future<void> fetchManagements() async {
//     try {
//       final response = await http.get(
//           Uri.parse("http://10.0.2.2:5000/api/healup/management/"));
//       if (response.statusCode == 200) {
//         List<dynamic> data = jsonDecode(response.body);
//         setState(() {
//           managements = data.map((management) {
//             return {
//               'id': management['_id'],
//               'name': management['name'],
//               'role': management['role'] ?? 'Not provided',
//               'pic': management['photo'] ?? 'images/default_manager.png',
//             };
//           }).toList();
//           filteredManagements = List.from(managements);
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to fetch managements: ${response.reasonPhrase}")),
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
//     fetchManagements();
//   }
//
//   void onTabTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//
//     // Navigate based on index
//     if (index == 0) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => ManagementMainPage()),
//       );
//     } else if (index == 1) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => ManagementListPage()),
//       );
//     } else if (index == 2) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => MedicationListPage(),
//         ),
//       );
//     } else if (index == 3) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => OrderListPage(),
//         ),
//       );
//     }else if (index == 4) {
//       // Navigate to Management page (if necessary)
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ManagementListPage(),
//         ),
//       );
//     }
//   }
//
//   void _filterManagements() {
//     setState(() {
//       if (_searchText.isEmpty) {
//         filteredManagements = List.from(managements);
//       } else {
//         filteredManagements = managements.where((management) {
//           return management['name']
//               .toLowerCase()
//               .contains(_searchText.toLowerCase());
//         }).toList();
//       }
//     });
//   }
//
//   void _deleteManagement(String managementId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse("http://10.0.2.2:5000/api/healup/management/delete/$managementId"),
//       );
//       if (response.statusCode == 200) {
//         setState(() {
//           filteredManagements.removeWhere((management) => management['id'] == managementId);
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Management data deleted successfully.")),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to delete management: ${response.reasonPhrase}")),
//         );
//       }
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("An error occurred: $error")),
//       );
//     }
//   }
//
//   void _showDeleteDialog(String managementId, String managementName) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Confirm Delete"),
//           content: Text("Are you sure you want to delete $managementName?"),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               style: TextButton.styleFrom(
//                 backgroundColor: const Color(0xff2f9a8f),
//               ),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.of(context).pop(); // Close the dialog
//                 _deleteManagement(managementId); // Delete management
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
//         title: const Text("Management List"),
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
//               //     builder: (context) => AddManagementPage(),
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
//                   _filterManagements();
//                 },
//                 decoration: InputDecoration(
//                   hintText: "Search for management",
//                   prefixIcon: const Icon(Icons.search),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(25.0),
//                   ),
//                   filled: true,
//                   fillColor: Colors.white.withOpacity(0.7),
//                 ),
//               ),
//             ),
//             managements.isEmpty
//                 ? const Center(
//               child: Text(
//                 "No management found.",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//             )
//                 : Expanded(
//               child: ListView.builder(
//                 itemCount: filteredManagements.length,
//                 itemBuilder: (context, index) {
//                   final management = filteredManagements[index];
//                   return GestureDetector(
//                     onTap: () {
//                       // Navigator.push(
//                       //   context,
//                       //   MaterialPageRoute(
//                       //     builder: (context) =>
//                       //         ManagementDetailPage(managementId: management['id']),
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
//                             CircleAvatar(
//                               radius: 35,
//                               backgroundImage: NetworkImage(management['pic']),
//                             ),
//                             const SizedBox(width: 16.0),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     management['name'],
//                                     style: const TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   Text(
//                                     "Role: ${management['role']}",
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.delete, color: Colors.red),
//                               onPressed: () {
//                                 _showDeleteDialog(management['id'], management['name']);
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
