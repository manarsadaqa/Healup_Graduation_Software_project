import 'package:flutter/material.dart';
import 'MedicineDetailPage.dart';

class Medicine {
  final String name;
  final String image;
  final String description;
  final double price;
  final String category;

  Medicine({
    required this.name,
    required this.image,
    required this.description,
    required this.price,
    required this.category,
  });
}

class SearchMedicinePage extends StatefulWidget {
  const SearchMedicinePage({super.key});

  @override
  _MedicinePageState createState() => _MedicinePageState();
}

class _MedicinePageState extends State<SearchMedicinePage> {
  String _searchText = "";
  String _selectedCategory = "";

  List<String> categories = [
    "All",
    "Pain Relief",
    "Cold & Flu",
    "Allergy",
    "Vitamins",
    "Digestive Health",
  ];

  List<Medicine> medicines = [
    Medicine(
      name: "Paracetamol",
      image: "images/paracetamol.jpg",
      description: "Pain relief and fever reducer",
      price: 2.50,
      category: "Pain Relief",
    ),
    Medicine(
      name: "Ibuprofen",
      image: "images/Ibuprofen.jpg",
      description: "Anti-inflammatory medication",
      price: 5.00,
      category: "Pain Relief",
    ),
    Medicine(
      name: "Aspirin",
      image: "images/Aspirin.jpg",
      description: "Blood thinner and pain reliever",
      price: 3.00,
      category: "Pain Relief",
    ),
    Medicine(
      name: "Vitamin C",
      image: "images/vitaminC.jpg",
      description: "Boosts immune system",
      price: 10.00,
      category: "Vitamins",
    ),
    Medicine(
      name: "Vitamin D",
      image: "images/VitaminD.jpg",
      description: "Boosts immune system",
      price: 10.00,
      category: "Vitamins",
    ),
    Medicine(
      name: "Rem Vit",
      image: "images/Digestive Health.jpg",
      description: "Relieves heartburn",
      price: 4.50,
      category: "Digestive Health",
    ),
    Medicine(
      name: "Ginger Root",
      image: "images/Digestive Health2.jpg",
      description: "Relieves heartburn",
      price: 4.50,
      category: "Digestive Health",
    ),
    Medicine(
      name: "Day&Night Cold&Flu",
      image: "images/Cold & Flu.jpg",
      description: "Pain relief and fever reducer",
      price: 2.50,
      category: "Cold & Flu",
    ),
    Medicine(
      name: "Codral",
      image: "images/Cold & Flu2.jpg",
      description: "Pain relief and fever reducer",
      price: 2.50,
      category: "Cold & Flu",
    ),
    Medicine(
      name: "Paracetamol",
      image: "images/Allergy.jpg",
      description: "Pain relief and fever reducer",
      price: 2.50,
      category: "Allergy",
    ),
    Medicine(
      name: "Allegra",
      image: "images/Allergy2.jpg",
      description: "Pain relief and fever reducer",
      price: 2.50,
      category: "Allergy",
    ),
  ];

  List<Medicine> _filterMedicines() {
    List<Medicine> filteredList = medicines;

    if (_searchText.isNotEmpty) {
      filteredList = filteredList.where((medicine) {
        return medicine.name.toLowerCase().contains(_searchText.toLowerCase());
      }).toList();
    }

    if (_selectedCategory.isNotEmpty && _selectedCategory != "All") {
      filteredList = filteredList.where((medicine) {
        return medicine.category == _selectedCategory;
      }).toList();
    }

    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    List<Medicine> filteredMedicines = _filterMedicines();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Medicine"),
        backgroundColor: const Color(0xff6be4d7),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/pat.jpg'), // Your background image
                fit: BoxFit.cover, // Cover the entire screen
              ),
            ),
          ),

          // Main content over the background
          Column(
            children: [
              // Search bar with camera icon
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
                        // Handle camera search functionality here
                        print('Camera search clicked!');
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),

              // Categories section (horizontal scrollable)
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    String category = categories[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : "";
                          });
                        },
                        backgroundColor: const Color(0xff0C969C),
                        selectedColor: Color(0xff6be4d7),
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              20), // Set border radius here
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Display list of medicines
              Expanded(
                child: ListView.builder(
                  itemCount: filteredMedicines.length,
                  itemBuilder: (context, index) {
                    final medicine = filteredMedicines[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: Image.asset(
                          medicine.image,
                          width: 50,
                          height: 50,
                        ),
                        title: Text(
                          medicine.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
                            print('Purchased ${medicine.name}');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0C969C),
                          ),
                          child: const Text(
                            "Buy",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MedicineDetailPage(medicine: medicine),
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
