import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart.dart';
import 'MedicineDetailPage.dart';
import 'medicine.dart';  // Import the shared Medicine model

// Medicine model class


class SearchMedicinePage extends StatefulWidget {
  const SearchMedicinePage({super.key});

  @override
  _MedicinePageState createState() => _MedicinePageState();
}

class _MedicinePageState extends State<SearchMedicinePage> {
  String _searchText = "";
  String _selectedCategory = "All";
  List<Medicine> medicines = [];
  bool _isLoading = false;

  static List<Map<String, dynamic>> cart = [];

  @override
  void initState() {
    super.initState();
    _fetchOTCMedications();
  }

  Future<void> _fetchOTCMedications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/healup/medication/otcmedication'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          medicines = (data['medications'] as List)
              .map((medicine) => Medicine.fromJson(medicine))
              .toList();
        });
      } else {
        throw Exception('Failed to load medications');
      }
    } catch (error) {
      print("Error fetching OTC medications: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Medicine> _filterMedicines() {
    List<Medicine> filteredList = medicines;

    if (_searchText.isNotEmpty) {
      filteredList = filteredList.where((medicine) {
        return medicine.medication_name
            .toLowerCase()
            .contains(_searchText.toLowerCase());
      }).toList();
    }

    if (_selectedCategory.isNotEmpty && _selectedCategory != "All") {
      filteredList = filteredList.where((medicine) {
        return medicine.type == _selectedCategory;
      }).toList();
    }

    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    List<Medicine> filteredMedicines = _filterMedicines();

    // Provided types list
    List<String> types = [
      "All",
      "ALLERGY & CONGESTION",
      "ANTACIDS & ACID REDUCERS",
      "ANTIBACTERIALS, TOPICAL",
      "COUGH & COLD",
      "DIABETES - INSULINS",
      "DIABETES - SUPPLIES",
      "EYE CARE",
      "GAS RELIEVERS, LAXATIVES & STOOL SOFTENERS",
      "ANTIDIARRHEALS",
      "ANTIEMETIC",
      "ANTIFUNGALS, TOPICAL",
      "ANTIFUNGALS, VAGINAL",
      "ANTI-ITCH LOTIONS & CREAMS",
      "CONTRACEPTIVES",
      "CONTRACEPTIVES - EMERGENCY",
      "MEDICAL SUPPLIES",
      "OVERACTIVE BLADDER",
      "PAIN & INFLAMMATION",
      "TOPICAL, MISCELLANEOUS",
      "VITAMINS/MINERALS",
      "MISCELLANEOUS"
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Medicine"),
        backgroundColor: const Color(0xff6be4d7),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(cart: cart),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/pat.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search for medicine",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () {
                        print('Camera search clicked!');
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: types.map((type) {
                    bool isSelected = type == _selectedCategory;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = type;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : const Color(0xff2f9a8f),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xff2f9a8f), width: 2),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                child: ListView.builder(
                  itemCount: filteredMedicines.length,
                  itemBuilder: (context, index) {
                    Medicine medicine = filteredMedicines[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: medicine.image.isNotEmpty
                            ? Image.network(
                          medicine.image,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                            : Image.asset(
                          'images/default_medicine.png',
                          width: 50,
                          height: 50,
                        ),
                        title: Text(
                          medicine.medication_name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(medicine.description),
                            Text(
                              "₪${medicine.price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              cart.add({
                                'name': medicine.medication_name,
                                'image': medicine.image,
                                'price': medicine.price,
                                'quantity': 1,
                              });
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${medicine.medication_name} added to cart."),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0C969C),
                          ),
                          child: const Text(
                            "Add",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MedicineDetailPage(
                                medicine: medicine, // Pass the entire Medicine object here
                                cart: cart, // Pass the shared cart
                              ),
                            ),
                          );
                        },

                      ),

                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}