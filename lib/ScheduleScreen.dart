import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  final List<Map<String, dynamic>> appointments;
  final Function(Map<String, dynamic>) onAppointmentBooked;
  final Function(Map<String, dynamic>) onAppointmentCanceled;

  const ScheduleScreen({
    super.key,
    required this.appointments,
    required this.onAppointmentBooked,
    required this.onAppointmentCanceled,
  });

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late List<Map<String, dynamic>> _appointments;

  @override
  void initState() {
    super.initState();
    _appointments = List.from(widget.appointments);
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Appointment'),
          content:
              const Text('Are you sure you want to cancel this appointment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                final canceledAppointment = _appointments[index];

                setState(() {
                  _appointments.removeAt(index);
                });

                widget.onAppointmentCanceled(canceledAppointment);

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appointment canceled.')),
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff6be4d7),
        title: const Text('Your Appointments'),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'images/pat.jpg'), // Path to your background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Appointments list
          ListView.builder(
            itemCount: _appointments.length,
            itemBuilder: (context, index) {
              final appointment = _appointments[index];
              final doctorName = appointment['doctorName'];
              final date = appointment['date'];
              final time = appointment['time'];
              final doctorPhoto =
                  appointment['doctorPhoto']; // Get the doctor's photo URL

              return Card(
                margin: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 16), // Add margin for spacing
                elevation: 5, // Elevation to create a shadow effect
                child: Padding(
                  padding: const EdgeInsets.all(
                      20), // Increase padding for a bigger card
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(
                        10), // Add padding inside the ListTile
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          AssetImage(doctorPhoto), // Change to AssetImage
                      backgroundColor:
                          Colors.grey[300], // Fallback background color
                    ),
                    title: Text(doctorName,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)), // Style the title
                    subtitle: Text('Date: $date, Time: $time',
                        style: const TextStyle(
                            fontSize: 16)), // Style the subtitle
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmation(context, index);
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
