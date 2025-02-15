import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../patient/managementMainPage.dart';
import 'AddMedicationPage.dart'; // Import the new page to add medication
import '../doctor/doctorList.dart';
import '../order/orderList.dart';
import '../managements/managementList.dart';
import 'EditMedicationPage.dart';
import 'medicationDetailPage.dart';

class MedicationListPage extends StatefulWidget {
  @override
  _MedicationListPageState createState() => _MedicationListPageState();
}
class _MedicationListPageState extends State<MedicationListPage> {
  List<Map<String, dynamic>> medications = [];
  List<Map<String, dynamic>> filteredMedications = [];
  int _currentIndex = 2; // Set to index 2 for "Medication"
  String _searchText = '';
  String selectedCategory = 'All'; // Default category

  // Fetch medications from the API
  Future<void> fetchMedications() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:5000/api/healup/medication/"),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        // Modify this section in the 'fetchMedications' method
        setState(() {
          medications = data.map((medication) {
            return {
              'id': medication['_id'],
              'name': medication['scientific_name'] ?? 'No name provided',
              'medication_name': medication['medication_name'] ?? 'No name provided',
              'stock_quantity': medication['stock_quantity'].toString(), // Ensure it's a string
              'type': medication['type'] ?? 'All',
              'pic': medication['image'] ?? 'images/default_medication.png', // Default if no image

              //'pic': medication['photo'] ?? 'images/default_medication.png',
            };
          }).toList();
          filteredMedications = List.from(medications);
        });

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch medications: ${response.reasonPhrase}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $error")),
      );
    }
  }

  // Fetch OTC medications
  Future<void> fetchOTCMedications() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:5000/api/healup/medication/otcmedication"),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data['medications'] != null) {
          List<dynamic> medicationsData = data['medications'];
          setState(() {
            medications = medicationsData.map((medication) {
              return {
                'id': medication['_id'],
                'name': medication['scientific_name'] ?? 'No name provided',
                'medication_name': medication['medication_name'] ?? 'No name provided',
                'stock_quantity': medication['stock_quantity'].toString(), // Ensure it's a string

                //'stock_quantity': medication['stock_quantity'] ?? 'No quantity provided',
                'type': 'OTC', // Ensure that all these medications are classified as OTC
                'pic': medication['image'] ?? 'images/default_medication.png', // Default if no image

                //'pic': medication['photo'] ?? 'images/default_medication.png',
              };
            }).toList();
            filteredMedications = List.from(medications);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No OTC medications found.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch OTC medications: ${response.reasonPhrase}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred while fetching OTC medications: $error")),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    fetchMedications();
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigate based on index
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicationListPage(),
        ),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderListPage(),
        ),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ManagementListPage(),
        ),
      );
    }
  }
  void _filterMedications() {
    setState(() {
      if (_searchText.isEmpty && selectedCategory == 'All') {
        filteredMedications = List.from(medications);
      } else {
        filteredMedications = medications.where((medication) {
          final matchesSearch = medication['name']
              .toLowerCase()
              .contains(_searchText.toLowerCase());

          // فلتر حسب الفئة المختارة (All أو OTC)
          final matchesCategory = selectedCategory == 'All' ||
              (selectedCategory == 'OTC Medication' && medication['type'] == 'OTC');

          return matchesSearch && matchesCategory;
        }).toList();
      }
    });
  }

  void _deleteMedication(String medicationId) async {
    try {
      final response = await http.delete(
        Uri.parse("http://10.0.2.2:5000/api/healup/medication/delete/$medicationId"),
      );

      if (response.statusCode == 200) {
        setState(() {
          filteredMedications.removeWhere((medication) => medication['id'] == medicationId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Medication deleted successfully.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete medication: ${response.reasonPhrase}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $error")),
      );
    }
  }

  void _showDeleteDialog(String medicationId, String medicationName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete $medicationName?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xff2f9a8f),
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                _deleteMedication(medicationId); // Delete medication
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
          "Medication List",
          style: TextStyle(
            fontSize: 24,  // زيادة حجم الخط
            fontWeight: FontWeight.bold,  // جعل الخط عريض
          ),
        ),
        backgroundColor: const Color(0xff2f9a8f),

        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMedicationPage(),
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
                  _filterMedications();
                },
                decoration: InputDecoration(
                  hintText: "Search for medication",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
            // Category Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory = 'All';
                      });
                      fetchMedications(); // Fetch medications based on the category
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedCategory == 'All'
                          ? Colors.white
                          : const Color(0xff2f9a8f),
                      foregroundColor: selectedCategory == 'All'
                          ? Colors.black
                          : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: BorderSide(
                          color: selectedCategory == 'All'
                              ? const Color(0xff2f9a8f)  // Change border color when selectedCategory is 'All'
                              : Colors.transparent,  // Make border transparent when not selected
                          width: 4.0,  // Adjust border width as needed
                        ),
                      ),
                      minimumSize: Size(150, 60), // Increase the size of the button (width x height)
                    ),
                    child: const Text(
                      'All',
                      style: TextStyle(
                        fontSize: 22,  // Increase the font size
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory = 'OTC Medication';
                      });
                      fetchOTCMedications(); // Fetch OTC medications
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedCategory == 'OTC Medication'
                          ? Colors.white
                          : const Color(0xff2f9a8f),
                      foregroundColor: selectedCategory == 'OTC Medication'
                          ? Colors.black
                          : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: BorderSide(
                          color: selectedCategory == 'OTC Medication'
                              ? const Color(0xff2f9a8f)  // Keep border color when 'OTC Medication' is selected
                              : Colors.transparent,  // Make border transparent when not selected
                          width: 4.0,  // Adjust the border width as needed
                        ),
                      ),
                      minimumSize: Size(150, 60), // Increase the size of the button (width x height)
                    ),
                    child: const Text(
                      'OTC Medication',
                      style: TextStyle(
                        fontSize: 22,  // Increase the font size
                      ),
                    ),
                  ),

                  // ElevatedButton(

                ],
              ),
            ),
            medications.isEmpty
                ? const Center(
              child: Text(
                "No medications found.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: filteredMedications.length,
                itemBuilder: (context, index) {
                  final medication = filteredMedications[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MedicationDetailsPage(medicationId: medication['id']),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundImage: AssetImage(medication['pic']),
                            ),

                            // CircleAvatar(
                            //   radius: 35,
                            //   backgroundImage: AssetImage(medication['pic']),
                            // ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    medication['name'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "name: ${medication['medication_name']}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "stock_quantity: ${medication['stock_quantity'].toString()}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [

                                // Edit Icon
                                // Inside the ListView.builder of MedicationListPage
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.yellowAccent),
                                  onPressed: () {
                                    // Navigate to the EditMedicationPage and pass medication id
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditMedicationPage(
                                          medicationId: medication['id'], // Pass the medication ID
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // Delete Icon
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _showDeleteDialog(medication['id'], medication['name']);
                                  },
                                ),
                              ],
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

