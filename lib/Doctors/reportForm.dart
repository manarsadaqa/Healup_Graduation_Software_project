import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportFormPage extends StatefulWidget {
  final String appointmentId;
  final String appointmentDate;
  final String doctorName;
  final String doctorSpeclization;
  final String doctorPhone;
  final String doctorHospital;
  final String doctorSeal;
  final String patientName;
  final int patientAge;
  final String medicalHistory;
  final Function(String) onReportSubmitted;  // Add callback


  const ReportFormPage({
    Key? key,
    required this.appointmentId,
    required this.appointmentDate,
    required this.doctorName,
    required this.doctorSpeclization,
    required this.doctorPhone,
    required this.doctorHospital,
    required this.doctorSeal,
    required this.patientName,
    required this.patientAge,
    required this.medicalHistory,
    required this.onReportSubmitted,  // Accept callback

  }) : super(key: key);

  @override
  _ReportFormPageState createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _resultController;
  late TextEditingController _medicalHistoryController;
  late TextEditingController _allergiesController;

  Future<void> submitReport(String appointmentId, String allergies, String result) async {
    const String backendUrl = "http://10.0.2.2:5000/api/healup/ehr/add"; // Replace with your backend URL

    print("im in submit report");

    print("Starting submitReport...");
    print("Appointment ID: $appointmentId");
    print("Allergies: $allergies");
    print("Result: $result");

    try {
      // Convert allergies string to a list (if not empty)
      List<String> allergyList = [];
      if (allergies.isNotEmpty) {
        allergyList = allergies.split(',').map((e) => e.trim()).toList(); // Split by comma and trim spaces
      }

      // Prepare the payload
      final Map<String, dynamic> payload = {
        'appointment_id': appointmentId,
        'allergies': allergyList, // Send as an array
        'result': result,
      };

      // Send POST request
      final http.Response response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print("Response received. Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201) {
        print("Report submitted successfully!");
      } else {
        print("Failed to submit report. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in submitReport: $e");
    }
  }

  void _submitForm() async {
    final String allergies = _allergiesController.text.trim();
    final String result = _resultController.text.trim();

    if (allergies.isEmpty || result.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Allergies and result are required!")),
      );
      return;
    }

    await submitReport(widget.appointmentId, allergies, result);

    // Inform the parent page that the report was submitted
    widget.onReportSubmitted(widget.appointmentId);

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Report submitted successfully!")),
    );

    Navigator.pop(context, true);  // Return to previous screen
  }


  @override
  void initState() {
    super.initState();
    _medicalHistoryController = TextEditingController(text: widget.medicalHistory);
    _resultController = TextEditingController();
    _allergiesController = TextEditingController();
  }

  @override
  void dispose() {
    _resultController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Submission"),
          content: Text("Are you sure you want to submit this report?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _submitForm(); // Call the manual form validation method
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report Form")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Doctor and Patient Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Doctor Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text("Name: ${widget.doctorName}", style: TextStyle(fontSize: 16)),
                        Text("Specialization: ${widget.doctorSpeclization}", style: TextStyle(fontSize: 16)),
                        Text("Phone: ${widget.doctorPhone}", style: TextStyle(fontSize: 16)),
                        Text("Address: ${widget.doctorHospital}", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16), // Space between the columns
                  // Patient Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Patient Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text("Name: ${widget.patientName}", style: TextStyle(fontSize: 16)),
                        Text("Age: ${widget.patientAge}", style: TextStyle(fontSize: 16)),
                        Text("Appointment Date: ${widget.appointmentDate}", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Divider
              const Divider(thickness: 2),

              // Medical History Field
              const SizedBox(height: 16),
              TextFormField(
                controller: _medicalHistoryController,
                decoration: InputDecoration(
                  labelText: "Medical History",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                readOnly: true,
              ),
              const SizedBox(height: 16),

              // Allergies Field
            TextFormField(
              controller: _allergiesController,
              decoration: InputDecoration(
                labelText: "Allergies (comma-separated)",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),


              const SizedBox(height: 16),

              // Result Field
              TextFormField(
                controller: _resultController,
                decoration: InputDecoration(
                  labelText: "Result",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),


              const SizedBox(height: 16),

              // Doctor Seal Field (read-only)
              TextFormField(
                initialValue: widget.doctorSeal,
                decoration: InputDecoration(
                  labelText: "Doctor Seal",
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    height: 10.0,  // Adjust the line height for the label
                  ),
                ),
                style: TextStyle(
                  fontFamily: 'Rockybilly',  // Apply the font family to the text in the field
                  height: 5,  // Adjust the line height for the text inside the field
                ),
                readOnly: true,
              ),

              const SizedBox(height: 24),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: _showConfirmationDialog, // Trigger the confirmation dialog
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff2f9a8f),
                  ),
                  child: const Text(
                    "Submit Report",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
