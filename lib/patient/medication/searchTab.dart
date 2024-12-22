import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'medicine.dart';
import 'cart.dart';
import 'MedicineDetailPage.dart';
import 'medicine.dart';

class SearchMedicinePage extends StatefulWidget {
  final String patientId; // Added patientId

  const SearchMedicinePage({super.key, required this.patientId}); // Receive patientId

  @override
  _SearchMedicinePageState createState() => _SearchMedicinePageState();
}

class _SearchMedicinePageState extends State<SearchMedicinePage> {
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
        Uri.parse('http://10.0.2.2:5000/api/healup/medication/otcmedication'),
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

  void _selectQuantity(Medicine medicine) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuantitySelectionPage(
          medicine: medicine,
          patientId: widget.patientId,  // Pass patientId here
        ),
      ),
    );

    if (result != null && result is int) {
      setState(() {
        cart.add({
          'name': medicine.medication_name,
          'image': medicine.image,
          'price': medicine.price,
          'quantity': result,
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${medicine.medication_name} added to cart."),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Medicine> filteredMedicines = _filterMedicines();

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
                  builder: (context) => CartPage(
                    cart: cart,
                    patientId: widget.patientId, // Pass patientId
                  ),
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
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search for medicine",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.7),
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
                      elevation: 5,
                      shadowColor: Colors.black.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MedicineDetailPage(
                                medicine: medicine,
                                cart: cart, // Pass the cart here
                                patientId: widget.patientId, // Pass patientId
                              ),
                            ),
                          );
                        },
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
                        subtitle: Text(
                          "₪${medicine.price.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _selectQuantity(medicine),
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
class QuantitySelectionPage extends StatefulWidget {
  final Medicine medicine;
  final String patientId;  // Added patientId

  const QuantitySelectionPage({Key? key, required this.medicine, required this.patientId}) : super(key: key);

  @override
  _QuantitySelectionPageState createState() => _QuantitySelectionPageState();
}

class _QuantitySelectionPageState extends State<QuantitySelectionPage> {
  int _quantity = 1;
  bool _isLoading = false;


  Future<void> _addToCart() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Check if the medication exists in the cart
      final medicationName = widget.medicine.medication_name;

      final getIdResponse = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/healup/cart/medication-id/$medicationName'),
      );

      if (getIdResponse.statusCode == 200) {
        // Medication found, get the cart ID, medication ID, and current quantity from the response
        final responseJson = json.decode(getIdResponse.body);
        final cartId = responseJson['cartId'];  // Get the cart ID
        final existingQuantity = responseJson['quantity'] ?? 0;  // Get existing quantity if available

        // Step 2: Calculate the new total quantity
        final newQuantity = existingQuantity + _quantity;  // Add existing and new quantity

        // Step 3: Update the cart with the new quantity using the cartId
        final updateResponse = await http.put(
          Uri.parse('http://10.0.2.2:5000/api/healup/cart/update/$cartId'),  // Use cartId instead of medicationId
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'quantity': newQuantity,  // Use the new calculated quantity
          }),
        );

        if (updateResponse.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('The medicine quantity has been updated in the cart'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, _quantity);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update medicine: ${updateResponse.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // If medication is not found in the cart, add it
        final addResponse = await http.post(
          Uri.parse('http://10.0.2.2:5000/api/healup/cart/add'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'medication_id': widget.medicine.id,  // Pass the medication id
            'medication_name': widget.medicine.medication_name,
            'image': widget.medicine.image,
            'price': widget.medicine.price,
            'quantity': _quantity,  // Add the quantity the user selected
          }),
        );

        if (addResponse.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('The medicine has been successfully added to the cart'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, _quantity);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add medicine: ${addResponse.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while adding. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Quantity"),
        backgroundColor: const Color(0xff6be4d7),
      ),
      body: Stack(
        children: [
          // خلفية الصفحة
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/pat.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              width: 300,
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Select quantity for ${widget.medicine.medication_name}",
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (_quantity > 1) _quantity--;
                          });
                        },
                      ),
                      Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            _quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff0C969C),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _addToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff0C969C),
                        ),
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
