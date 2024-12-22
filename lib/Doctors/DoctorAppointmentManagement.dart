import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON parsing
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart'; // For parsing custom date format
import 'PrescriptionFormPage.dart';
import 'reportForm.dart';

class AppointmentManagementPage extends StatefulWidget {
  const AppointmentManagementPage({Key? key}) : super(key: key);

  @override
  _AppointmentManagementPageState createState() =>
      _AppointmentManagementPageState();
}

class _AppointmentManagementPageState extends State<AppointmentManagementPage>
    with TickerProviderStateMixin { // Add this mixin
  final _storage = FlutterSecureStorage();
  List<Map<String, dynamic>> pendingRequests = [];
  List<Map<String, dynamic>> confirmedAppointments = [];
  List<Map<String, dynamic>> pastAppointments = [];
  Map<String, bool> _prescriptionSubmitted = {};
  Set<String> submittedReports = {};


  bool showPending = false;
  bool showConfirmed = false;
  bool showPast = false;
  bool _isPrescriptionSubmitted = false;

  // Animation controllers for each section
  late AnimationController _pendingAnimationController;
  late AnimationController _confirmedAnimationController;
  late AnimationController _pastAnimationController;

  late Animation<double> _pendingFadeAnimation;
  late Animation<double> _confirmedFadeAnimation;
  late Animation<double> _pastFadeAnimation;

  @override
  void initState() {
    super.initState();
    _pendingAnimationController = AnimationController(
      vsync: this, // This now works because TickerProviderStateMixin provides vsync
      duration: const Duration(milliseconds: 400),
    );
    _confirmedAnimationController = AnimationController(
      vsync: this, // This now works because TickerProviderStateMixin provides vsync
      duration: const Duration(milliseconds: 400),
    );
    _pastAnimationController = AnimationController(
      vsync: this, // This now works because TickerProviderStateMixin provides vsync
      duration: const Duration(milliseconds: 400),
    );

    _pendingFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _pendingAnimationController, curve: Curves.easeIn));
    _confirmedFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _confirmedAnimationController, curve: Curves.easeIn));
    _pastFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _pastAnimationController, curve: Curves.easeIn));

    _fetchAppointments();
  }

  // Custom function to parse the date string
  DateTime? _parseCustomDate(String dateStr) {
    try {
      // Sanitize the date string by replacing non-breaking spaces with regular spaces
      dateStr = dateStr.replaceAll(RegExp(r'\u200B'), ' ');

      // Define the custom format of the extracted string
      DateFormat format = DateFormat('yyyy-MM-dd h:mm a');

      // Parse the start date and time
      return format.parse(dateStr);
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }

  // Fetch appointments and categorize them into pending, confirmed, and past
  Future<void> _fetchAppointments() async {
    String? doctorId = await _storage.read(key: 'doctor_id');
    if (doctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Doctor ID not found in secure storage.')),
      );
      return;
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/healup/appointments/doctor/$doctorId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      pendingRequests.clear();
      confirmedAppointments.clear();
      pastAppointments.clear();

      for (var appointment in data) {
        final String status = appointment['status'] ?? 'Unknown';
        final String? appDateStr = appointment['app_date'];
        DateTime? appDate;

        // Parse the date
        if (appDateStr != null) {
          appDate = _parseCustomDate(appDateStr); // Use the custom parser
        }

        if (appDate != null) {
          final DateTime now = DateTime.now();
          if (appDate.isBefore(now)) {
            pastAppointments.add(appointment); // Move to past if the date is in the past
            _updateAppointmentStatus(appointment['_id'], 'Completed');

            // Initialize prescription state for past appointments
            _prescriptionSubmitted[appointment['_id']] = false;
          } else if (status == 'Confirmed') {
            confirmedAppointments.add(appointment);
          } else {
            pendingRequests.add(appointment);
          }
        }

      }

      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load appointments')),
      );
    }
  }


  // Update appointment status
  Future<void> _updateAppointmentStatus(String appointmentId, String newStatus) async {
    final Map<String, dynamic> body = {'status': newStatus};
    final response = await http.patch(
      Uri.parse(
          'http://10.0.2.2:5000/api/healup/appointments/update-status/$appointmentId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      setState(() {
        if (newStatus == 'Confirmed') {
          final updatedAppointment = pendingRequests.firstWhere(
                  (appointment) => appointment['_id'] == appointmentId);
          pendingRequests.removeWhere(
                  (appointment) => appointment['_id'] == appointmentId);
          confirmedAppointments.add(updatedAppointment);
        } else if (newStatus == 'Canceled') {
          pendingRequests.removeWhere(
                  (appointment) => appointment['_id'] == appointmentId);
        }

      });

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update appointment status')),
      );
    }
  }

  @override
  void dispose() {
    _pendingAnimationController.dispose();
    _confirmedAnimationController.dispose();
    _pastAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with a gradient overlay
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/back.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.3), // Semi-transparent overlay
            ),
          ),
          // Appointment Management UI
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCollapsibleSection(
                    "Appointment Requests",
                    showPending,
                        () {
                      setState(() {
                        showPending = !showPending;
                        if (showPending) {
                          _pendingAnimationController.forward();
                        } else {
                          _pendingAnimationController.reverse();
                        }
                      });
                    },
                    pendingRequests,
                    "Pending Approval",
                    true,
                  ),
                  Divider(height: 32, color: Colors.white.withOpacity(0.5)),
                  _buildCollapsibleSection(
                    "Confirmed Appointments",
                    showConfirmed,
                        () {
                      setState(() {
                        showConfirmed = !showConfirmed;
                        if (showConfirmed) {
                          _confirmedAnimationController.forward();
                        } else {
                          _confirmedAnimationController.reverse();
                        }
                      });
                    },
                    confirmedAppointments,
                    "Confirmed",
                    false,
                  ),
                  Divider(height: 32, color: Colors.white.withOpacity(0.5)),
                  _buildCollapsibleSection(
                    "Past Appointments",
                    showPast,
                        () {
                      setState(() {
                        showPast = !showPast;
                        if (showPast) {
                          _pastAnimationController.forward();
                        } else {
                          _pastAnimationController.reverse();
                        }
                      });
                    },
                    pastAppointments,
                    "Completed",
                    false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Collapsible Section with Animation
  Widget _buildCollapsibleSection(
      String title,
      bool isVisible,
      VoidCallback toggleVisibility,
      List<Map<String, dynamic>> appointments,
      String status,
      bool showActions,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: toggleVisibility,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2f9a8f),
                  ),
                ),
                Icon(
                  isVisible
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xff2f9a8f),
                ),
              ],
            ),
          ),
        ),
        if (isVisible) FadeTransition(opacity: _pendingFadeAnimation, child: _buildAppointmentCards(appointments, status, showActions)),
      ],
    );
  }

  Widget _buildAppointmentCards(
      List<Map<String, dynamic>> appointments, String status, bool showActions) {
    if (appointments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "No appointments available.",
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
      );
    }

    return Column(
      children: appointments.map((appointment) {
        final String appointmentId = appointment['_id'];
        final String patientName =
            appointment['patient_id']['username'] ?? 'Unknown';
        final String appDate = appointment['app_date'] ?? 'No Date';
        final String patientImage =
            appointment['patient_id']['pic'] ?? ''; // Patient image URL

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: patientImage.isNotEmpty
                  ? AssetImage(patientImage)
                  : AssetImage('assets/placeholder.png') as ImageProvider,
            ),
            title: Text(
              patientName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("$status - $appDate"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show check and cancel buttons only for "Pending Approval" appointments
                if (status == "Pending Approval") ...[
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () {
                      _updateAppointmentStatus(appointmentId, 'Confirmed');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      _updateAppointmentStatus(appointmentId, 'Canceled');
                    },
                  ),
                ],

                // Show Prescription Icon for "Completed" appointments
                if (status == "Completed") ...[
                  IconButton(
                    icon: Icon(
                      Icons.medical_services,
                      color: _prescriptionSubmitted[appointment['_id']] == true
                          ? Colors.grey // Disabled if prescription submitted
                          : Colors.blue, // Active if prescription not submitted
                    ),
                    onPressed: _prescriptionSubmitted[appointment['_id']] == true
                        ? null // Disable the button if prescription is already submitted
                        : () async {
                      // Navigate to the PrescriptionFormPage
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            // Calculate patient's age from DOB
                            String dob = appointment['patient_id']['DOB'];
                            DateTime birthDate = DateTime.parse(dob);
                            DateTime today = DateTime.now();
                            int age = today.year - birthDate.year;

                            // Adjust if the birthday hasn't occurred yet this year
                            if (today.month < birthDate.month ||
                                (today.month == birthDate.month &&
                                    today.day < birthDate.day)) {
                              age--;
                            }

                            return PrescriptionFormPage(
                              doctorId: appointment['doctor_id']['_id'],
                              doctorName: appointment['doctor_id']['name'],
                              doctorSpeclization: appointment['doctor_id']['specialization'],
                              doctorPhone: appointment['doctor_id']['phone'],
                              doctorHospital: appointment['doctor_id']['hospital'],
                              patientId: appointment['patient_id']['_id'],
                              patientName: appointment['patient_id']['username'],
                              patientAge: age,
                              appDate: appointment['app_date'],
                              appointmentId: appointment['_id'],
                            );
                          },
                        ),
                      );

                      // If the prescription was submitted, update the state
                      if (result == true) {
                        setState(() {
                          _prescriptionSubmitted[appointment['_id']] = true;
                        });
                      }
                    },
                  ),

                  // Show Report Icon for "Completed" appointments
                  IconButton(
                    icon: Icon(
                      Icons.article,
                      color: submittedReports.contains(appointmentId)
                          ? Colors.grey
                          : Colors.yellow,
                    ),
                    onPressed: submittedReports.contains(appointmentId)
                        ? null
                        : () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            String dob = appointment['patient_id']['DOB'];
                            DateTime birthDate = DateTime.parse(dob);
                            DateTime today = DateTime.now();
                            int age = today.year - birthDate.year;

                            if (today.month < birthDate.month ||
                                (today.month == birthDate.month && today.day < birthDate.day)) {
                              age--;
                            }

                            return ReportFormPage(
                              appointmentId: appointment['_id'],
                              appointmentDate: appointment['app_date'],
                              doctorName: appointment['doctor_id']['name'],
                              doctorSpeclization: appointment['doctor_id']['specialization'],
                              doctorPhone: appointment['doctor_id']['phone'],
                              doctorHospital: appointment['doctor_id']['hospital'],
                              doctorSeal: appointment['doctor_id']['seal'],
                              patientName: appointment['patient_id']['username'],
                              patientAge: age,
                              medicalHistory: appointment['patient_id']['medical_history'],
                              onReportSubmitted: (appointmentId) {
                                setState(() {
                                  submittedReports.add(appointmentId);  // Update the state after report submission
                                });
                              },
                            );
                          },
                        ),
                      );

                      if (result == true) {
                        // Handle any other state changes after returning from the ReportFormPage
                      }
                    },
                  ),
                ],
              ],
            ),
          ),


        );
      }).toList(),
    );
  }


}
