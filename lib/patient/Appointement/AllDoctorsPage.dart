import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For parsing the JSON response
import 'patApp.dart';
class AllDoctorsPage extends StatefulWidget {
  final String? initialSpecialty; // Accept an optional initial specialty
  final String patientId; // Add this field to accept the patientId

  const AllDoctorsPage({Key? key,
  required this.patientId, // Accept patientId in the constructor
  this.initialSpecialty}) : super(key: key);

  @override
  _AllDoctorsPageState createState() => _AllDoctorsPageState();
}

class _AllDoctorsPageState extends State<AllDoctorsPage> {
  List<Map<String, dynamic>> allDoctors = [];
  List<String> specialties = ['All', 'General', 'Cardiology', 'Pediatrics', 'Neurology', 'Orthopedics', 'Dermatology'];
  String selectedSpecialty = 'All';
  String searchText = '';

  @override
  void initState() {
    super.initState();
    fetchAllDoctors();
    if (widget.initialSpecialty != null) {
      setState(() {
        selectedSpecialty = widget.initialSpecialty!;
      });
    }
  }

  Future<void> fetchAllDoctors() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/healup/doctors/doctors'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        allDoctors = data
            .map((doctor) => {
          '_id': doctor['_id'],  // Include doctor ID
          'name': doctor['name'],
          'photo': doctor['photo'],
          'hospital': doctor['hospital'],
          'specialization': doctor['specialization'],
          'reviews': int.parse(doctor['reviews'].toString()),
          'rating': double.parse(doctor['rating'].toString()),
          'price': double.parse(doctor['pricePerHour'].toString()),
          'yearExperience': int.parse(doctor['yearExperience'].toString()),
          'availability': doctor['availability'],
          'address': doctor['address'],
        })
            .toList()
          ..sort((a, b) => b['reviews'].compareTo(a['reviews'])) // Sort by reviews (descending)
          ..take(5); // Show up to 5 doctors
      });
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  List<Map<String, dynamic>> getFilteredDoctors() {
    List<Map<String, dynamic>> filteredDoctors = allDoctors;

    if (searchText.isNotEmpty) {
      filteredDoctors = filteredDoctors.where((doctor) {
        return doctor['name'].toLowerCase().contains(searchText.toLowerCase());
      }).toList();
    }

    if (selectedSpecialty != 'All') {
      filteredDoctors = filteredDoctors.where((doctor) {
        return doctor['specialization'] == selectedSpecialty;
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
                      doctor_id: doctor['_id'],
                      name: doctor['name'],
                      photo: doctor['photo'],
                      address:doctor['address'],
                      hospital: doctor['hospital'],
                      specialization: doctor['specialization'],
                      availability: doctor['availability'],
                      price: doctor['price'],
                      reviews: doctor['reviews'],
                      rating: doctor['rating'],
                      yearsOfExperience: doctor['yearExperience'],
                      patientId: widget.patientId,  // Pass patientId to DoctorCard
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
  final String doctor_id;
  final String name;
  final String photo;
  final String address;
  final String hospital;
  final String specialization;
  final String availability;
  final int reviews;
  final double price;
  final int yearsOfExperience;
  final double rating;
  final String patientId;  // Add patientId parameter

  const DoctorCard({
    super.key,
    required this.doctor_id,
    required this.name,
    required this.photo,
    required this.address,
    required this.hospital,
    required this.specialization,
    required this.availability,
    required this.reviews,
    required this.price,
    required this.yearsOfExperience,
    required this.rating,
    required this.patientId,  // Include patientId in the constructor
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to PatApp when doctor card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatApp(
              name: name,
              specialization: specialization,
              photo: photo,
              address:address,
              hospital: hospital,  // You might want to pass hospital as address
              availability: availability,  // You can customize this part as per your data
              yearsOfExperience: yearsOfExperience,  // You can also pass the actual years of experience if available
              price: price,  // Price for consultation, update as per your data
              patientId: patientId,  // Pass patientId to PatApp
              doctorId: doctor_id,  // You should replace with the actual doctor id
              onAppointmentBooked: (appointmentDetails) {
                // Handle appointment booking if needed
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(photo.isEmpty ? 'default-image-url' : photo),  // Handle empty photo
            radius: 25,
          ),
          title: Text(
            name.isNotEmpty ? name : 'No Name',  // Default if name is empty
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
                    hospital.isNotEmpty ? hospital : 'No Hospital',  // Default if hospital is empty
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
      ),
    );
  }
}
