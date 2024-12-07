import 'package:flutter/material.dart';

class EHRPage extends StatelessWidget {
  final Map<String, dynamic> ehrData;

  EHRPage({required this.ehrData});

  @override
  Widget build(BuildContext context) {
    List<String> allergies = List<String>.from(ehrData['allergies']);
    return Scaffold(
      appBar: AppBar(
        title: Text('Electronic Health Record'),
        backgroundColor: Color(0xff2f9a8f),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Doctor: ${ehrData['doctor_name']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Patient: ${ehrData['patient_name']} (Age: ${ehrData['patient_age']})',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Medical History: ${ehrData['medical_history']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Allergies:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...allergies.map((allergy) {
              return ListTile(
                title: Text(allergy),
              );
            }).toList(),
            SizedBox(height: 16),
            Text(
              'Result: ${ehrData['result']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Created At: ${ehrData['createdAt']}',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              'Updated At: ${ehrData['updatedAt']}',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
