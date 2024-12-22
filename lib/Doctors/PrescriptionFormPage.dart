import 'package:flutter/material.dart';
import 'PrescriptionForm.dart'; // Import the form widget

class PrescriptionFormPage extends StatelessWidget {
  final String doctorId;
  final String patientId;
  final String appointmentId;
  final String doctorName;
  final String doctorSpeclization;
  final String doctorPhone;
  final String doctorHospital;
  final String patientName;
  final int patientAge;
  final String appDate;

  const PrescriptionFormPage({
    required this.doctorId,
    required this.patientId,
    required this.appointmentId,
    required this.doctorName,
    required this.doctorSpeclization,
    required this.doctorPhone,
    required this.doctorHospital,
    required this.patientName,
    required this.patientAge,
    required this.appDate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert the patientAge to int

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PrescriptionForm(
          doctorId: doctorId,
          doctorName: doctorName, // Pass doctorName here
          doctorSpeclization:doctorSpeclization,
          doctorPhone:doctorPhone,
          doctorHospital:doctorHospital,
          patientId: patientId,
          patientName: patientName,  // Pass patientName here
          patientAge: patientAge,  // Pass patientAge here
          appointmentId: appointmentId,
          appointmentDate: appDate,  // Pass appDate here
        ),
      ),
    );
  }
}
