import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScheduleScreen extends StatefulWidget {
  final String patientId;

  ScheduleScreen({required this.patientId});

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;
  Map<String, String> doctorPhotos = {}; // To store doctor photos
  List<String> availableTimeSlots = [];
  List<String> bookedTimeSlots = [];  // Track booked slots for validation
  static const String baseUrl = "http://localhost:5000/";

  @override
  void initState() {
    super.initState();
    fetchAppointments();
    fetchAllDoctors();
  }

  Future<void> fetchAppointments() async {
    if (widget.patientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Patient ID is not available.")),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    final apiUrl = "http://localhost:5000/api/healup/appointments/patient/${widget.patientId}";
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final appointmentData = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        setState(() {
          appointments = appointmentData;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch appointments.");
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching appointments: $error")),
      );
    }
  }


// Fetch all doctors' data
  Future<void> fetchAllDoctors() async {
    final apiUrl = "http://localhost:5000/api/healup/doctors/doctors";
    try {
      print("Fetching doctors...");  // Check if the function is being called
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        print("Response from doctors API: ${response.body}");  // Print the raw response
        final doctorsData = List<Map<String, dynamic>>.from(jsonDecode(response.body));

        // Print out the fetched doctor data for debugging
        print("Fetched doctors data: $doctorsData");

        // Map doctors' photo URLs by doctorId
        for (var doctor in doctorsData) {
          final doctorId = doctor['_id'];
          String photoUrl = doctor['photo'];

          // Print the doctor photo URL and ID for debugging
          print("Doctor ID: $doctorId, Photo URL: $photoUrl");

          // Store the doctor photo URL, or use a placeholder if it's empty
          doctorPhotos[doctorId] = photoUrl.isNotEmpty ? photoUrl : 'https://example.com/placeholder.jpg'; // Default placeholder
        }
      } else {
        print("Failed to fetch doctors. Status code: ${response.statusCode}");
        throw Exception("Failed to fetch doctors.");
      }
    } catch (error) {
      print("Error fetching doctors: $error");
    }
  }



  Future<void> fetchDoctorAvailableSlots(String doctorId, String date) async {
    final apiUrl = "http://localhost:5000/api/healup/appointments/doctor/$doctorId/available-slots/$date";
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          availableTimeSlots = List<String>.from(data['availableSlots']);
          bookedTimeSlots = List<String>.from(data['bookedSlots']);  // Track booked slots
        });

        // Check for any duplicate appointments before allowing the user to proceed
        if (bookedTimeSlots.isEmpty) {
          // Handle no booked slots case
          print("No appointments are booked for this doctor.");
        } else {
          // If there are any booked slots, validate if the slot the user picks is not in booked slots.
          print("Booked time slots: $bookedTimeSlots");
        }
      } else {
        throw Exception("Failed to fetch available time slots.");
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PLease choose from the available slots")),
      );
    }
  }


// Check if the new selected slot is already booked
  Future<void> updateAppointmentDate(String appointmentId, String newAppDate) async {
    // Check if the selected time slot is already booked
    if (bookedTimeSlots.contains(newAppDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selected time slot is already booked. Please choose another one.")),
      );
      return; // Don't proceed with updating the appointment if the slot is taken
    }

    final apiUrl = "http://localhost:5000/api/healup/appointments/update-date/${widget.patientId}";

    try {
      final response = await http.patch(
        Uri.parse(apiUrl),
        body: jsonEncode({
          'appointment_id': appointmentId,  // Add appointment_id to the body
          'new_app_date': newAppDate,       // Add new appointment date to the body
        }),
        headers: {
          'Content-Type': 'application/json',  // Set the content type to JSON
        },
      );

      if (response.statusCode == 200) {
        final updatedAppointment = jsonDecode(response.body);

        setState(() {
          var index = appointments.indexWhere((a) => a['_id'] == appointmentId);
          if (index != -1) {
            appointments[index]['app_date'] = updatedAppointment['appointment']['app_date'];
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Appointment date updated successfully")),
        );
      } else {
        throw Exception("Failed to update appointment.");
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating appointment: $error")),
      );
    }
  }

  void _showDateTimePicker(String appointmentId, String doctorId) async {
    // Step 1: Pick a new date using a date picker
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // default to today's date
      firstDate: DateTime.now(),   // Ensure users can't pick a date in the past
      lastDate: DateTime(2100),    // Limit to future dates
    );

    if (selectedDate != null) {
      final formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

      // Step 2: Fetch available time slots for the doctor on the selected date
      await fetchDoctorAvailableSlots(doctorId, formattedDate);

      if (availableTimeSlots.isNotEmpty) {
        // Step 3: Show a dialog with available time slots
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Select New Appointment Time"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: availableTimeSlots.map((slot) {
                    bool isSlotBooked = bookedTimeSlots.contains(slot);

                    return ListTile(
                      title: Text(slot),
                      onTap: isSlotBooked
                          ? null // Disable slot if booked
                          : () {
                        // If the slot is booked already, prevent update
                        if (bookedTimeSlots.contains(slot)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Slot already booked! Please pick another slot.")),
                          );
                          return;
                        }

                        updateAppointmentDate(appointmentId, "$formattedDate $slot");
                        Navigator.of(context).pop();  // Close the dialog
                      },
                      tileColor: isSlotBooked ? Colors.grey : null,  // Change color if booked
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No available time slots for this doctor.")),
        );
      }
    }
  }


  Future<void> deleteAppointment(String appointmentId) async {
    final apiUrl = "http://localhost:5000/api/healup/appointments/delete/$appointmentId";
    try {
      final response = await http.delete(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          appointments.removeWhere((appointment) => appointment['_id'] == appointmentId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Appointment deleted successfully")),
        );
      } else {
        throw Exception("Failed to delete appointment.");
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting appointment: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.patientId.isEmpty) {
      return Center(
        child: Text("Error: Patient ID is not available."),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Appointments"),
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
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : appointments.isEmpty
              ? const Center(child: Text("No appointments found."))
              : ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              final doctorId = appointment['doctor_id']?['_id'];  // Ensure correct doctor ID access
              final doctorName = appointment['doctor_id']?['name'] ?? 'No name available';
              final doctorSpecialty = appointment['doctor_id']?['specialization'] ?? 'Specialty not available';
              final doctorPhoto = doctorId != null && doctorPhotos.containsKey(doctorId)
                  ? doctorPhotos[doctorId]
                  : null; // Get doctor's photo URL or null

              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 5.0,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  leading: CircleAvatar(
                    radius: 25.0,
                    backgroundImage: (doctorPhoto?.isNotEmpty ?? false)
                        ? NetworkImage(doctorPhoto!) // Display doctor's photo
                        : AssetImage('assets/images/person_icon.png') as ImageProvider,   // Fallback to default image
                    child: (doctorPhoto == null || doctorPhoto!.isEmpty)
                        ? const Icon(Icons.person)  // If no photo URL, show default icon
                        : null,
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctorName,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),),
                      Text(
                        doctorSpecialty,  // Display doctor's specialty here
                        style: TextStyle(fontStyle: FontStyle.normal, color: Colors.grey),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    "${appointment['app_date']} - ${appointment['status']}",
                    style: TextStyle(color: Color(0xff2f9a8f),fontWeight: FontWeight.bold),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          if (doctorId != null) {
                            _showDateTimePicker(appointment['_id'], doctorId);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          deleteAppointment(appointment['_id']);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          )

        ],
      ),
    );
  }
}