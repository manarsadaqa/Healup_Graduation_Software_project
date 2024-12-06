import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'map_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ScheduleScreen.dart';

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
  DateTime currentMonth = DateTime.now();
  final Map<String, Set<String>> reservedTimesByDate = {};


  // Fetch the reserved time slots for the selected doctor and date
  Future<void> fetchReservedTimes() async {
    if (selectedDate == null) return;

    final apiUrl = "http://localhost:5000/api/healup/appointments/doctor/${widget.doctorId}/available-slots/$selectedDate";
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reservedTimes = data['reservedTimes'] as List;

        setState(() {
          reservedTimesByDate[selectedDate!] = Set.from(reservedTimes.map((e) => e.toString()));
        });
      } else {
        throw Exception("Failed to load reserved times.");
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching reserved times.")),
      );
    }
  }

  // Generate time intervals (60-minute slots)
  List<String> generateTimeIntervals(String availability) {
    final parts = availability.split(' - ');
    if (parts.length != 2) return [];

    DateTime start = _parseTime(parts[0].trim());
    DateTime end = _parseTime(parts[1].trim());

    List<String> intervals = [];
    DateTime current = start;

    while (current.isBefore(end)) {
      DateTime next = current.add(const Duration(minutes: 60));
      intervals.add("${_formatTime(current)} - ${_formatTime(next)}");
      current = next;
    }

    return intervals;
  }

  DateTime _parseTime(String timeStr) {
    int hour = int.parse(timeStr.split(":")[0].trim());
    int minute = int.parse(timeStr.split(":")[1].split(" ")[0].trim());
    String period = timeStr.split(" ")[1].trim().toUpperCase();

    if (period == "PM" && hour < 12) hour += 12;
    if (period == "AM" && hour == 12) hour = 0;

    return DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, hour, minute);
  }

  String _formatTime(DateTime time) {
    return DateFormat.jm().format(time); // e.g., "10:00 AM"
  }

  Future<void> bookAppointmentToBackend(String? date, String? time) async {
    if (date == null || time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a valid date and time.")),
      );
      return;
    }

    final apiUrl = "http://localhost:5000/api/healup/appointments/book";
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "patient_id": widget.patientId,
          "doctor_id": widget.doctorId,
          "app_date": "$date $time",
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          reservedTimesByDate[date] ??= {};
          reservedTimesByDate[date]!.add(time);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Appointment successfully booked!")),
        );
      } else {
        final responseData = jsonDecode(response.body);
        final message = responseData["message"] ?? "Failed to book appointment.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wrong: Unable to book appointment.")),
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
                  // Doctor Info Section
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(widget.photo),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              widget.specialization,
                              style: const TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            Text('${widget.yearsOfExperience} years Experience'),
                            Text('\$${widget.price}/hr', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Month Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: currentMonth.isAfter(DateTime.now())
                            ? () {
                          setState(() {
                            currentMonth = DateTime(
                              currentMonth.year,
                              currentMonth.month - 1,
                            );
                          });
                        }
                            : null,
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(currentMonth),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          setState(() {
                            currentMonth = DateTime(
                              currentMonth.year,
                              currentMonth.month + 1,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Days of the Month
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      childAspectRatio: 1.5, // Adjust for oval shape
                    ),
                    itemCount: _daysInMonth(currentMonth),
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      final date = DateTime(currentMonth.year, currentMonth.month, day);
                      final isPast = date.isBefore(DateTime.now());
                      final isSelected = selectedDate == DateFormat('yyyy-MM-dd').format(date);

                      return GestureDetector(
                        onTap: !isPast
                            ? () {
                          setState(() {
                            selectedDate = DateFormat('yyyy-MM-dd').format(date);
                          });
                        }
                            : null,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xff6be4d7) : Colors.white,
                            borderRadius: BorderRadius.circular(25), // Oval shape
                            border: Border.all(
                              color: isPast ? Colors.grey : Colors.black,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isPast ? Colors.grey : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Time Slots Section
                  Text('Time Slots', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Column(
                    children: generateTimeIntervals(widget.availability)
                        .map((time) => _buildTimeButton(time))
                        .toList(),
                  ),

                  const SizedBox(height: 20),

                  // Book Now Button
                  // Inside the build method of _PatAppState
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                      child: ElevatedButton(
                        onPressed: selectedDate != null && selectedTime != null
                            ? () => bookAppointmentToBackend(selectedDate, selectedTime)
                            : () {
                          // Display Snackbar if date or time is not selected
                          final snackBar = SnackBar(
                            content: Text(
                              selectedDate == null
                                  ? 'Please select a date.'
                                  : 'Please select a time.',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.redAccent,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff6be4d7),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
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

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  Widget _buildTimeButton(String time) {
    final now = DateTime.now();
    final isExpiredToday = selectedDate == DateFormat('yyyy-MM-dd').format(now) &&
        _parseTime(time.split(' - ')[0]).isBefore(now);

    final isSelected = selectedTime == time; // Check if this time is selected
    final isReserved = reservedTimesByDate[selectedDate]?.contains(time) ?? false;

    return GestureDetector(
      onTap: !isExpiredToday && !isReserved
          ? () {
        setState(() {
          selectedTime = time; // Set the selected time
        });
      }
          : null,
      child: Container(
        alignment: Alignment.center, // Center time text
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isExpiredToday
              ? Colors.grey // Grey for expired time slots
              : (isReserved
              ? Color(0xff6BA3BE) // Red for reserved times
              : (isSelected
              ? const Color(0xff6be4d7) // Highlight color for selected time
              : Colors.white)), // Default white for unselected time
          borderRadius: BorderRadius.circular(25), // Oval shape
          border: Border.all(
            color: isReserved ? Color(0xff6be4d7) : (isSelected ? Colors.black : Colors.grey), // Black edges for selected time
            width: isSelected ? 2 : 1, // Thicker edges for selected time
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Text(
          time,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // Bold for selected time
            color: isExpiredToday
                ? Colors.black45 // Greyed out for expired times
                : isReserved
                ? Colors.white // White for reserved times
                : Colors.black, // Black for all other states
          ),
        ),
      ),
    );
  }






}
