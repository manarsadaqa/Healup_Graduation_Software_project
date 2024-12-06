import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import the package
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'Appointement/patApp.dart'; // Import the PatApp page
import 'package:http/http.dart' as http;
import 'dart:convert'; // For parsing the JSON response
import 'Appointement/AllDoctorsPage.dart';
import 'Appointement/patApp.dart';
import 'login&signUP/login.dart';
import 'chatBot/chatBot.dart';

class HomeTab extends StatefulWidget {
  final Function(Map<String, dynamic>) onAppointmentBooked;
  final Function(Map<String, dynamic>) onAppointmentCanceled;
  final String userName;
  final Function(String) onPatientIdReceived;

  const HomeTab({
    super.key,
    required this.onAppointmentBooked,
    required this.onAppointmentCanceled,
    required this.userName,
    required this.onPatientIdReceived,
  });

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<Map<String, dynamic>> doctors = [];
  String userName = "";
  String patientId = ""; // Add a variable to store the patient ID
  final FlutterSecureStorage _storage = FlutterSecureStorage(); // Declare the storage instance


  @override
  void initState() {
    super.initState();
    fetchDoctors();
    _getUserName();
    _getPatientId(); // Fetch the patient ID when the screen initializes

  }

  Future<void> _getUserName() async {
    final storage = FlutterSecureStorage();
    String? storedName = await storage.read(key: 'patient_name');
    setState(() {
      userName = storedName ?? "Patient";
    });
  }

  Future<void> _getPatientId() async {
    String? id = await _storage.read(key: 'patient_id');
    setState(() {
      patientId = id ?? "";
    });
    widget.onPatientIdReceived(patientId); // Pass patientId to parent widget
  }


  Future<void> fetchDoctors() async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/healup/doctors/doctors'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        doctors = data
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



  @override
  Widget build(BuildContext context) {
    print("Patient ID in build method: $patientId");  // Debugging line
    if (patientId.isEmpty) {
      return const Center(child: CircularProgressIndicator());  // Or a message for missing patientId
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff6be4d7),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.lightBlue, Colors.lightGreen],
            tileMode: TileMode.clamp,
          ).createShader(bounds),
          child: const Text(
            'HealUp',
            style: TextStyle(
              fontSize: 40,
              fontFamily: 'Hello Valentina',
              fontWeight: FontWeight.bold,
              color: Colors.lightBlue,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/pat.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, $userName!',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'How are you today?',
                          style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications, size: 33),
                      color: Colors.black,
                      onPressed: () {
                        print("Notifications clicked");
                      },
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(80),
                  child: Image.asset(
                    'images/med.png',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                const Text(
                  'Doctor Speciality',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      DoctorSpecialityCard(
                        icon: Icons.medical_services,
                        title: 'General',
                        onTap: () {
                          _navigateToSpecialty('General');
                        },
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.brain,
                        title: 'Neurologic',
                        onTap: () {
                          _navigateToSpecialty('Neurology');
                        },
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.baby,
                        title: 'Pediatrics',
                        onTap: () {
                          _navigateToSpecialty('Pediatrics');
                        },
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.heartPulse,
                        title: 'Cardiology',
                        onTap: () {
                          _navigateToSpecialty('Cardiology');
                        },
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.bone,
                        title: 'Orthopedics',
                        onTap: () {
                          _navigateToSpecialty('Orthopedics');
                        },
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.handSparkles,
                        title: 'Dermatologic',
                        onTap: () {
                          _navigateToSpecialty('Dermatology');
                        },
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Recommended Doctors Section with "See All" button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recommended Doctors',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllDoctorsPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Display doctors list here
                doctors.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    :ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: doctors.length > 5 ? 5 : doctors.length, // Show up to 5 doctors
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];

                    // Print the doctor ID to verify it's being passed
                    print('Doctor ID: ${doctor['_id']}');
                    print('Patent ID: $patientId');

                    return DoctorCard(
                      patientId: patientId,
                      doctorId: doctor['_id'],  // Pass the doctor ID
                      name: doctor['name'],
                      photo: doctor['photo'],
                      hospital: doctor['hospital'],
                      specialization: doctor['specialization'],
                      reviews: doctor['reviews'],
                      rating: doctor['rating'],
                      price: doctor['price'],
                      availability: doctor['availability'],
                      yearExperience: doctor['yearExperience'],
                      address: doctor['address'],
                      onAppointmentBooked: widget.onAppointmentBooked,
                      onAppointmentCanceled: widget.onAppointmentCanceled,
                    );
                  },
                ),
                // Add this inside your HomeTab's build method, perhaps after the Doctor Speciality section
                const SizedBox(height: 20), // Add spacing

              ],
            ),
          ),
        ],
      ),
    );
  }


  void _navigateToSpecialty(String specialty) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AllDoctorsPage(initialSpecialty: specialty),
    ),
  );
}
}

class DoctorCard extends StatelessWidget {
  final String patientId;
  final String doctorId;  // Add the doctorId parameter
  final String name;
  final String photo;
  final String hospital;
  final String specialization;
  final int reviews;
  final double rating;
  final double price;
  final int yearExperience;
  final String availability;
  final String address;
  final Function(Map<String, dynamic>) onAppointmentBooked;
  final Function(Map<String, dynamic>) onAppointmentCanceled;

  const DoctorCard({
    super.key,
    required this.patientId,
    required this.doctorId,  // Add the doctorId to the constructor
    required this.name,
    required this.photo,
    required this.hospital,
    required this.specialization,
    required this.reviews,
    required this.rating,
    required this.price,
    required this.availability,
    required this.yearExperience,
    required this.address,
    required this.onAppointmentBooked,
    required this.onAppointmentCanceled,
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
        onTap: () {
          // Print doctorId to verify it's being passed correctly
          print("Doctor tapped, ID: $doctorId");

          // Pass the doctorId to the next page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatApp(
                name: name,
                specialization: specialization,
                photo: photo,
                address: address,
                availability: availability,
                yearsOfExperience: yearExperience,
                price: price,
                patientId: patientId,
                doctorId: doctorId,  // Pass the doctorId to PatApp
                onAppointmentBooked: onAppointmentBooked,
              ),
            ),
          );
        },
      ),
    );
  }
}






class DoctorSpecialityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap; // Added onTap callback

  const DoctorSpecialityCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Wrap the Container with GestureDetector to handle taps
      child: Container(
        width: 120,
        height: 100,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xffeef7fe),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xff2f9a8f)),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
