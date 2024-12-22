import 'package:flutter/material.dart';

class EHRDetailScreen extends StatelessWidget {
  final Map<String, dynamic> ehr;

  EHRDetailScreen({required this.ehr});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('EHR Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient, Doctor, and Appointment Date Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor's Details (Left Side)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Doctor Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("Name: ${ehr['doctor_name']}", style: TextStyle(fontSize: 16)),
                      Text('Doctor Specialization: ${ehr['specialization']}', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(width: 16), // Space between the columns
                // Patient Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Patient Information", style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Patient Name: ${ehr['patient_name']}', style: TextStyle(fontSize: 16)),
                      Text("Age: ${ehr['patient_age']}", style: TextStyle(fontSize: 16)),
                      Text('Appointment Date: ${ehr['appointment_date']}', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),


            const SizedBox(height: 20), // Adds space after the row
            Divider(color: Colors.black,
            thickness: 2,), // Adds a divider after the sections

            SizedBox(height: 20), // Adds space after the divider
            Text('Medical History :', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ehr['medical_history'] != null && ehr['medical_history'].isNotEmpty
                ? Text('${ehr['medical_history']}', style: TextStyle(fontSize: 18))
                : Text('No medical_history recorded', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 20), // Adds space before the next section


            // Allergies Section
            Text('Allergies:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ehr['allergies'] != null && ehr['allergies'].isNotEmpty
                ? Text('${ehr['allergies'].join(', ')}', style: TextStyle(fontSize: 18))
                : Text('No allergies recorded', style: TextStyle(fontSize: 18, color: Colors.grey)),

            SizedBox(height: 20), // Adds space before the next section

            // Result Section
            Text('Result:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ehr['result'] != null && ehr['result'].isNotEmpty
                ? Text('${ehr['result']}', style: TextStyle(fontSize: 18))
                : Text('No result available', style: TextStyle(fontSize: 18, color: Colors.grey)),

            SizedBox(height: 15), // Adds space before the next section

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Signature:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                // Control height between signature and seal
                SizedBox(height: 40), // Adjust this height value as needed

                ehr['seal'] != null && ehr['seal'].isNotEmpty
                    ? Text(
                  '${ehr['seal']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Rockybilly',
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : Text(
                  'No seal available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            )

          ],
        ),
      ),
    );
  }
}
