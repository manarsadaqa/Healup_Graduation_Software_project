import 'package:flutter/material.dart';

class PrescriptionPage extends StatelessWidget {
  final Map<String, dynamic> prescription;

  PrescriptionPage({required this.prescription});

  @override
  Widget build(BuildContext context) {
    List<dynamic> medications = prescription['medications'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Prescription'),
        backgroundColor: Color(0xff2f9a8f),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Doctor: ${prescription['doctor_name']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Patient: ${prescription['patient_name']} (Age: ${prescription['patient_age']})',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Appointment Date: ${prescription['appointment_date']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Medications:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...medications.map((med) {
              return ListTile(
                title: Text('${med['name']}'),
                subtitle: Text('Quantity: ${med['quantity']} - Dosage: ${med['dosage']}'),
              );
            }).toList(),
            SizedBox(height: 16),
            Text(
              'Result: ${prescription['result']}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

