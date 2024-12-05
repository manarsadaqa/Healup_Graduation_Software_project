import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'homeTab.dart'; // Ensure this file defines HomeTab
import 'searchTab.dart';
import 'patProfile.dart';
import 'chatBot.dart';
import 'ScheduleScreen.dart';


class PatientPage extends StatefulWidget {
  const PatientPage({super.key});

  @override
  _PatientPageState createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  int _selectedIndex = 0;
  List<Widget>? _pages; // Use nullable List until data is initialized
  final List<Map<String, dynamic>> appointments = [];
  String userName = "";
  String patientId = ""; // Add a variable to store the patient ID
  final FlutterSecureStorage _storage = FlutterSecureStorage(); // Declare the storage instance


  /// Fetch userName and patientId, then initialize the pages
  @override
  void initState() {
    super.initState();
    _getPatientId();
    _getUserName();
  }

  Future<void> _getPatientId() async {
    String? id = await _storage.read(key: 'patient_id');
    debugPrint("Fetched patient ID from storage: $id");
    setState(() {
      patientId = id ?? "";
      _pages = [
        HomeTab(
          userName: userName,
          onAppointmentBooked: _onAppointmentBooked,
          onAppointmentCanceled: _onAppointmentCanceled,
          onPatientIdReceived: _onPatientIdReceived,
        ),
        ChatBot(patientId: patientId),
        const SearchMedicinePage(),
        ScheduleScreen(patientId: patientId), // Pass patientId to ScheduleScreen
        PatProfile(patientId: patientId),
      ];
    });
  }





  Future<void> _getUserName() async {
    String? name = await _storage.read(key: 'patient_name');
    setState(() {
      userName = name ?? "Patient"; // Use default "Patient" if name is null
    });
  }


  void _onAppointmentBooked(Map<String, dynamic> newAppointment) {
    setState(() {
      appointments.add(newAppointment);
    });
  }

  void _onAppointmentCanceled(Map<String, dynamic> appointment) {
    setState(() {
      appointments.remove(appointment);
    });
  }

  void _onPatientIdReceived(String id) {
    setState(() {
      patientId = id;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator until `_pages` is initialized
    if (_pages == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: _pages![_selectedIndex],
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Icon(Icons.home, size: 35),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Icon(Icons.chat, size: 30),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: SizedBox.shrink(),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Icon(Icons.calendar_today, size: 30),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Icon(Icons.account_circle_outlined, size: 32),
                ),
                label: '',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            backgroundColor: const Color(0xff6be4d7),
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
          Positioned(
            bottom: 5,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 2; // Switch to Search screen
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                height: 70,
                width: 70,
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(Icons.search, size: 35, color: Color(0xff6be4d7)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
