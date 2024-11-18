import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'map_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PatApp extends StatefulWidget {
  final String name;
  final String specialization;
  final String photo;
  final String address;
  final String availability;
  final int yearsOfExperience;
  final double price;
  final String patientId;
  final String doctorId;
  final Function(Map<String, String>) onAppointmentBooked;

  const PatApp({
    Key? key,
    required this.name,
    required this.specialization,
    required this.photo,
    required this.address,
    required this.availability,
    required this.yearsOfExperience,
    required this.price,
    required this.patientId,
    required this.doctorId,
    required this.onAppointmentBooked,
  }) : super(key: key);

  @override
  _PatAppState createState() => _PatAppState();
}

class _PatAppState extends State<PatApp> {
  String? selectedDate;
  String? selectedTime;
  final Map<String, Set<String>> reservedTimesByDate = {};

  // Generate time intervals (30-minute slots)
  List<String> generateTimeIntervals(String availability) {
    final parts = availability.split(' - ');
    if (parts.length != 2) {
      return [];
    }

    DateTime start = _parseTime(parts[0].trim());
    DateTime end = _parseTime(parts[1].trim());

    List<String> intervals = [];
    DateTime current = start;

    while (current.isBefore(end)) {
      DateTime next = current.add(const Duration(minutes: 30));  // 30-minute slots
      intervals.add("${_formatTime(current)} - ${_formatTime(next)}");
      current = next;
    }

    return intervals;
  }

  DateTime _parseTime(String timeStr) {
    int hour = int.parse(timeStr.split(":")[0].trim());
    int minute = int.parse(timeStr.split(":")[1].split(" ")[0].trim());
    String period = timeStr.split(" ")[1].trim().toUpperCase();

    if (period == "PM" && hour < 12) {
      hour += 12;
    } else if (period == "AM" && hour == 12) {
      hour = 0;
    }

    return DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, hour, minute);
  }

  String _formatTime(DateTime time) {
    return DateFormat.jm().format(time);  // e.g., "10:00 AM"
  }

  Future<void> bookAppointmentToBackend(String date, String time) async {
    final apiUrl = "http://localhost:5000/api/healup/appointments/book";
    try {
      final day = date.split(' ')[0];
      final formattedDate = "$day/${DateTime.now().month.toString().padLeft(2, '0')}";

      final appointmentDateTime = "$formattedDate $time";

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "patient_id": widget.patientId,
          "doctor_id": widget.doctorId,
          "app_date": appointmentDateTime,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Appointment successfully booked!")),
        );
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData["message"] ?? "Failed to book appointment.");
      }
    } catch (error) {
      print("Error booking appointment: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Unable to book appointment.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: const Color(0xff6be4d7),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/back.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Container(
              color: Colors.white.withOpacity(0.6),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.09),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(widget.photo),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              widget.specialization,
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.grey),
                            ),
                            Text(
                              '${widget.yearsOfExperience} years Experience',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Text(
                              '2456 Patients',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              '\$${widget.price}/hr',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff2f9a8f)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.red, size: 30),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MapScreen(
                                    address: widget.address,
                                    location: LatLng(
                                        31.9022, 35.2034), // Dummy coordinates
                                  ),
                            ),
                          );
                        },
                        child: Text(
                          widget.address,
                          style: const TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Schedules',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _daysInMonth(),
                      itemBuilder: (context, index) {
                        final date = DateTime(DateTime.now().year,
                            DateTime.now().month, index + 1);
                        final dayName = DateFormat('EEE').format(date);
                        final dayNumber = DateFormat('d').format(date);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _buildDateButton(dayName, dayNumber),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Time',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: generateTimeIntervals(widget.availability)
                        .map((time) => _buildTimeButton(time))
                        .toList(),
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: selectedDate != null && selectedTime != null
                        ? () {
                      _bookAppointment(context);
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff6be4d7),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Center(
                      child: Text(
                        'Book Now',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(String dayName, String dayNumber) {
    final date = "$dayNumber"; // Combine day name and number for date representation
    final isSelected = selectedDate == date;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = date;
        });
      },
      child: Container(
        width: 60,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? const Color(0xff6be4d7) : Colors.grey,
            width: 4,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: TextStyle(
                fontSize: 18,
                color: isSelected ? const Color(0xff6be4d7) : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayNumber,
              style: TextStyle(
                fontSize: 18,
                color: isSelected ? const Color(0xff6be4d7) : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeButton(String time) {
    final isReserved = reservedTimesByDate[selectedDate]?.contains(time) ?? false;
    final isSelected = selectedTime == time && !isReserved;

    return GestureDetector(
      onTap: !isReserved
          ? () {
        setState(() {
          selectedTime = time; // Set the selected time when tapped
        });
      }
          : null, // Don't allow selection if the time is reserved
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isReserved
              ? Colors.grey // Reserved times are greyed out
              : (isSelected ? const Color(0xff6be4d7) : Colors.transparent), // Selected times are highlighted
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isReserved ? Colors.grey : Colors.grey), // Border color
        ),
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Text(
            time,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isReserved || isSelected ? FontWeight.bold : FontWeight.w400,
              color: isReserved ? Colors.black45 : Colors.black, // Text color based on state
            ),
          ),
        ),
      ),
    );
  }

  int _daysInMonth() {
    return DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
  }

  void _bookAppointment(BuildContext context) {
    if (selectedDate != null && selectedTime != null) {
      bookAppointmentToBackend(selectedDate!, selectedTime!);
    }
  }
}
