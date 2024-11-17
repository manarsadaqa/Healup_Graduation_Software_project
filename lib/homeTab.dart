import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import the package
import 'patApp.dart'; // Import the PatApp page
import 'package:http/http.dart' as http;
import 'dart:convert'; // For parsing the JSON response
import 'AllDoctorsPage.dart';

class HomeTab extends StatefulWidget {
  final Function(Map<String, dynamic>) onAppointmentBooked;
  final Function(Map<String, dynamic>) onAppointmentCanceled;

  const HomeTab({
    super.key,
    required this.onAppointmentBooked,
    required this.onAppointmentCanceled,
  });

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<Map<String, dynamic>> doctors = [];

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  // Fetch doctors from the backend
  Future<void> fetchDoctors() async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/healup/doctors/doctors'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        // Sort doctors by reviews in descending order and limit to 5
        doctors = data.map((doctor) => {
          'name': doctor['name'],
          'photo': doctor['photo'],
          'hospital': doctor['hospital'],
          'specialization': doctor['specialization'],
          'reviews': doctor['reviews'],
          'rating': doctor['rating'],
        }).toList()
          ..sort((a, b) => b['reviews'].compareTo(a['reviews'])) // Sort by reviews (descending)
          ..take(5); // Limit to top 5 doctors
      });
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  @override
  Widget build(BuildContext context) {
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
              'images/pat.jpg', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hi, Dana!',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'How are you today?',
                          style:
                          TextStyle(fontSize: 18, color: Colors.grey[800]),
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

                // Image section
                ClipRRect(
                  borderRadius: BorderRadius.circular(80),
                  child: Image.asset(
                    'images/med.png', // Path to your image
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.fitWidth,
                  ),
                ),

                // Specialties section
                const Text(
                  'Doctor Speciality',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      DoctorSpecialityCard(
                        icon: Icons.medical_services,
                        title: 'General',
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.brain,
                        title: 'Neurologic',
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.baby,
                        title: 'Pediatric',
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.xRay,
                        title: 'Radiology',
                      ),
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
                        // Navigate to the AllDoctorsPage
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
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: doctors.length > 5 ? 5 : doctors.length, // Show up to 5 doctors
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
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
              ],
            ),
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

class DoctorSpecialityCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const DoctorSpecialityCard({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
