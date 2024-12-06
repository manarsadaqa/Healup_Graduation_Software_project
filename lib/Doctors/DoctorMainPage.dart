import 'package:flutter/material.dart';
import 'DoctorAppointmentManagement.dart';
import 'DoctorProfilePage.dart';


class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedPageIndex = 0;

  // Define page options
  final List<Widget> _pages = [
    DoctorProfilePage(),
    AppointmentManagementPage(),
  ];

  // Function to switch pages
  void _onPageSelected(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedPageIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xff6be4d7),
        currentIndex: _selectedPageIndex,
        onTap: _onPageSelected,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Appointments",
          ),
        ],
      ),
    );

  }
}
