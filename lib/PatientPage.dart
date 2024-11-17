import 'package:flutter/material.dart';
// Ensure the following imports are present
import 'homeTab.dart'; // Ensure this file defines HomeTab
import 'searchTab.dart';
import 'patProfile.dart';
import 'DiagnosisChat.dart';
import 'ScheduleScreen.dart';

class PatientPage extends StatefulWidget {
  const PatientPage({super.key});

  @override
  _PatientPageState createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  int _selectedIndex = 0;
  late List<Widget> _pages; // Use late modifier to defer initialization

  final List<Map<String, dynamic>> appointments = [];
  final String userName = "John"; // For example, this could be fetched dynamically

  void _onAppointmentBooked(Map<String, dynamic> newAppointment) {
    setState(() {
      appointments.add(newAppointment); // Add new appointment
    });
  }

  void _onAppointmentCanceled(Map<String, dynamic> appointment) {
    setState(() {
      appointments.remove(appointment); // Remove the canceled appointment
    });
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeTab(
        // Pass the userName here
        userName: userName, // Pass the dynamic user name
        onAppointmentBooked: _onAppointmentBooked, // Pass the booking callback
        onAppointmentCanceled: _onAppointmentCanceled, // Pass the cancellation callback
      ),
      const DiagnosisChat(),
      const SearchMedicinePage(),
      ScheduleScreen(
        appointments: appointments,
        onAppointmentBooked: _onAppointmentBooked,
        onAppointmentCanceled: _onAppointmentCanceled, // Pass the same callbacks
      ),
      const PatProfile(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Change selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display selected page
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
                  _selectedIndex = 2; // Switch to Search screen when tapped
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
