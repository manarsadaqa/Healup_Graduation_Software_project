import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_screen.dart';
import 'ScheduleScreen.dart';
import 'package:intl/intl.dart';

class PatApp extends StatefulWidget {
  final String doctorName;
  final String doctorSpecialization;
  final String doctorPhoto; // This will be the local asset path
  final Function(Map<String, String>) onAppointmentBooked;
  final Function(Map<String, String>) onAppointmentCanceled;

  const PatApp({
    super.key,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.doctorPhoto, // Expecting the asset path for local images
    required this.onAppointmentBooked,
    required this.onAppointmentCanceled,
  });

  @override
  _PatAppState createState() => _PatAppState();
}

class _PatAppState extends State<PatApp> {
  String? selectedDate;
  String? selectedTime;
  final Map<String, Set<String>> reservedTimesByDate = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doctorName),
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
                          backgroundImage: AssetImage(
                              widget.doctorPhoto), // Change to AssetImage
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.doctorName,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              widget.doctorSpecialization,
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.grey),
                            ),
                            const Text(
                              '14 years Experience',
                              style: TextStyle(fontSize: 16),
                            ),
                            const Text(
                              '2456 Patients',
                              style: TextStyle(fontSize: 16),
                            ),
                            const Text(
                              '\$20/hr',
                              style: TextStyle(
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
                              builder: (context) => const MapScreen(
                                address: '123 Health St, Ramallah, Palestine',
                                location: LatLng(31.9022, 35.2034),
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          '123 Health St, Ramallah, Palestine',
                          style: TextStyle(
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
                    children: [
                      _buildTimeButton('8:00 AM'),
                      _buildTimeButton('8:30 AM'),
                      _buildTimeButton('8:45 AM'),
                      _buildTimeButton('9:00 AM'),
                      _buildTimeButton('9:30 AM'),
                      _buildTimeButton('10:00 AM'),
                    ],
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

  void _bookAppointment(BuildContext context) {
    final appointment = {
      'doctorName': widget.doctorName,
      'date': selectedDate!,
      'time': selectedTime!,
      'doctorPhoto': widget.doctorPhoto, // Save doctor's photo URL here
    };

    widget.onAppointmentBooked(appointment);

    setState(() {
      reservedTimesByDate
          .putIfAbsent(selectedDate!, () => {})
          .add(selectedTime!);
      selectedTime = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              "Appointment booked on $selectedDate at $selectedTime with Dr. ${widget.doctorName}")),
    );
  }

  void _onAppointmentCanceled(Map<String, dynamic> appointment) {
    final canceledDate = appointment['date'];
    final canceledTime = appointment['time'];

    setState(() {
      reservedTimesByDate[canceledDate]?.remove(canceledTime);
      if (reservedTimesByDate[canceledDate]?.isEmpty ?? false) {
        reservedTimesByDate.remove(canceledDate);
      }
    });
  }

  int _daysInMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1)).day;
  }

  Widget _buildDateButton(String day, String date) {
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
              day,
              style: TextStyle(
                fontSize: 18,
                color: isSelected ? const Color(0xff6be4d7) : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
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
    final isReserved =
        reservedTimesByDate[selectedDate]?.contains(time) ?? false;
    final isSelected = selectedTime == time && !isReserved;

    return GestureDetector(
      onTap: !isReserved
          ? () {
              setState(() {
                selectedTime = time;
              });
            }
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isReserved
              ? Colors.grey
              : (isSelected ? const Color(0xff6be4d7) : Colors.transparent),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isReserved ? Colors.grey : Colors.grey),
        ),
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Text(
            time,
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  isReserved || isSelected ? FontWeight.bold : FontWeight.w400,
              color: isReserved ? Colors.black45 : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
