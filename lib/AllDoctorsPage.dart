import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For parsing the JSON response

class AllDoctorsPage extends StatefulWidget {
  @override
  _AllDoctorsPageState createState() => _AllDoctorsPageState();
}

class _AllDoctorsPageState extends State<AllDoctorsPage> {
  List<Map<String, dynamic>> allDoctors = [];  // List of all doctors
  List<String> specialties = ['All','General','Cardiology', 'Pediatrics', 'Neurology', 'Orthopedics', 'Dermatology']; // Example specialties
  String selectedSpecialty = 'All'; // Track the selected specialty
  String searchText = ''; // To store search query

  @override
  void initState() {
    super.initState();
    fetchAllDoctors();
  }

  // Fetch all doctors from the backend
  Future<void> fetchAllDoctors() async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/healup/doctors/doctors'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        allDoctors = data.map((doctor) => {
          'name': doctor['name'],
          'photo': doctor['photo'],
          'hospital': doctor['hospital'],
          'specialization': doctor['specialization'],
          'reviews': doctor['reviews'],
          'rating': doctor['rating'],
        }).toList();
      });
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  // Filter doctors based on the selected specialty and search query
  List<Map<String, dynamic>> getFilteredDoctors() {
    List<Map<String, dynamic>> filteredDoctors = allDoctors;

    // Apply search filter
    if (searchText.isNotEmpty) {
      filteredDoctors = filteredDoctors.where((doctor) {
        return doctor['name'].toLowerCase().contains(searchText.toLowerCase());
      }).toList();
    }

    // Apply specialty filter
    if (selectedSpecialty != 'All') {
      filteredDoctors = filteredDoctors.where((doctor) {
        return doctor['specialization'] == selectedSpecialty; // Filter by specialization
      }).toList();
    }

    return filteredDoctors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Doctors'),
        backgroundColor: const Color(0xff6be4d7),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'images/pat.jpg', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          // Content
          Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search for doctors",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),

              // Specialty Slider
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: specialties.map((specialty) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedSpecialty = specialty;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            backgroundColor: selectedSpecialty == specialty
                                ? Color(0xff0C969C) // Highlight selected
                                : Color(0xff6be4d7),
                            foregroundColor: Colors.white,  // Text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                specialty,  // Add specialty text here
                                style: const TextStyle(
                                  fontSize: 16, // Set the font size
                                  fontWeight: FontWeight.bold,  // Bold text
                                ),
                              ),
                              if (selectedSpecialty == specialty)
                                const Icon(Icons.check, color: Colors.white), // Show checkmark if selected
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Doctor List
              Expanded(
                child: getFilteredDoctors().isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: getFilteredDoctors().length,
                  itemBuilder: (context, index) {
                    final doctor = getFilteredDoctors()[index];
                    return DoctorCard(
                      name: doctor['name'],
                      photo: doctor['photo'],
                      hospital: doctor['hospital'],
                      specialization: doctor['specialization'],
                      reviews: doctor['reviews'],
                      rating: doctor['rating'],
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

class DoctorCard extends StatelessWidget {
  final String name;
  final String photo;
  final String hospital;
  final String specialization;
  final int reviews;
  final double rating;

  const DoctorCard({
    super.key,
    required this.name,
    required this.photo,
    required this.hospital,
    required this.specialization,
    required this.reviews,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(photo),
          radius: 25,
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '$specialization | ',
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                Text(
                  hospital,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.star, color: Colors.yellow[700], size: 16),
                Text('$rating ($reviews reviews)'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
