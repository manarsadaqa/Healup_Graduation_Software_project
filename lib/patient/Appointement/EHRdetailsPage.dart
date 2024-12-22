import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart' show rootBundle;


class EHRDetailPage extends StatelessWidget {
  final Map<String, dynamic> ehr;

  // Constructor expecting the 'ehr' parameter
  EHRDetailPage({required this.ehr});

  // Request Storage Permission
  Future<void> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isDenied) {
        // Request Manage External Storage Permission
        await Permission.manageExternalStorage.request();
      }
    }


    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
  }

  // Function to save EHR data as PDF
  Future<void> saveEHRDataAsPDF(Map<String, dynamic> ehrData, BuildContext context) async {
    try {
      // Create a PDF document
      final pdf = pw.Document();
      final ttf = await rootBundle.load("fonts/Rockybilly.ttf");
      final sealFont = pw.Font.ttf(ttf);
      // Add a page to the PDF
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "EHR Details",
                  style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold),
                ),

                pw.SizedBox(height: 20),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Doctor's Details
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Doctor Information", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 8),
                          pw.Text("Doctor Name: ${ehr['doctor_name']}", style: pw.TextStyle(fontSize: 22)),
                          pw.Text('Specialization:${ehr['specialization']}', style: pw.TextStyle(fontSize: 22)),
                          pw.Text('Phone:${ehr['phone']} ', style: pw.TextStyle(fontSize: 22)),
                          pw.Text('Hospital: ${ehr['hospital']}', style: pw.TextStyle(fontSize: 22)),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 16),
                    // Patient's Details
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Patient Information", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 8),
                          pw.Text('Patient Name: ${ehr['patient_name']}', style: pw.TextStyle(fontSize: 22)),
                          pw.Text("Age: ${ehr['patient_age']}", style: pw.TextStyle(fontSize: 22)),
                          pw.Text('Appointment Date: ${ehr['appointment_date']}', style: pw.TextStyle(fontSize: 22)),
                        ],
                      ),
                    ),
                  ],
                ),


                pw.SizedBox(height: 20), // Adds space
                pw.Divider( thickness: 2,), // Divider between sections


                pw.SizedBox(height: 20), // Adds space

                // Medical History
                pw.Text('Medical History:', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                ehrData['medical_history'] != null && ehrData['medical_history'].isNotEmpty
                    ? pw.Text('${ehrData['medical_history']}', style: pw.TextStyle(fontSize: 20))
                    : pw.Text('No medical history recorded', style: pw.TextStyle(fontSize: 20, color: PdfColors.grey)),
                pw.SizedBox(height: 20),

                // Allergies
                pw.Text('Allergies:', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                ehrData['allergies'] != null && ehrData['allergies'].isNotEmpty
                    ? pw.Text('${ehrData['allergies'].join(', ')}', style: pw.TextStyle(fontSize: 20))
                    : pw.Text('No allergies recorded', style: pw.TextStyle(fontSize: 20, color: PdfColors.grey)),
                pw.SizedBox(height: 20),

                // Result
                pw.Text('Result:', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                ehrData['result'] != null && ehrData['result'].isNotEmpty
                    ? pw.Text('${ehrData['result']}', style: pw.TextStyle(fontSize: 20))
                    : pw.Text('No result available', style: pw.TextStyle(fontSize: 20, color: PdfColors.grey)),
                pw.SizedBox(height: 20),


                pw.Text(
                  'Signature:',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                ehrData['seal'] != null && ehrData['seal'].isNotEmpty
                    ? pw.Text(
                  '${ehrData['seal']}',
                  style: pw.TextStyle(
                    fontSize: 24,
                    font: sealFont, // Use the loaded custom font here
                    fontWeight: pw.FontWeight.bold,
                  ),
                )
                    : pw.Text(
                  'No seal available',
                  style: pw.TextStyle(fontSize: 20, color: PdfColors.grey),
                ),
              ],
            );
          },
        ),
      );

      // Request storage permission
      await requestStoragePermission();

      if (await Permission.manageExternalStorage.isGranted || await Permission.storage.isGranted) {
        try {
          // Get the Downloads directory path
          final directory = Directory('/storage/emulated/0/Download');
          if (!directory.existsSync()) {
            await directory.create(recursive: true);
          }

          // Set the file name
          final file = File("${directory.path}/ehr_${DateTime.now().millisecondsSinceEpoch}.pdf");

          // Save the PDF file
          await file.writeAsBytes(await pdf.save());

          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✔ EHR saved successfully!")),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to save PDF: $e")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Storage permission is required to save the file.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating PDF: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EHR Details'),
        actions: [
          // Save Button in the AppBar
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              // Call the save function to store EHR data as PDF, passing context
              saveEHRDataAsPDF(ehr, context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // EHR Data
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor's Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Doctor Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text("Doctor Name: ${ehr['doctor_name']}", style: TextStyle(fontSize: 16)),
                      Text('Specialization:${ehr['specialization']}', style: TextStyle(fontSize: 16)),
                      Text('Phone:${ehr['phone']} ', style: TextStyle(fontSize: 16)),
                      Text('Hospital:${ehr['hospital']} ', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                // Patient's Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Patient Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Patient Name: ${ehr['patient_name']}', style: TextStyle(fontSize: 16)),
                      Text("Age: ${ehr['patient_age']}", style: TextStyle(fontSize: 16)),
                      Text('Appointment Date: ${ehr['appointment_date']}', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),


            const SizedBox(height: 20), // Adds space
            Divider(color: Colors.black, thickness: 2,), // Divider between sections

            // Medical History Section
            Text('Medical History:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ehr['medical_history'] != null && ehr['medical_history'].isNotEmpty
                ? Text('${ehr['medical_history']}', style: TextStyle(fontSize: 18))
                : Text('No medical history recorded', style: TextStyle(fontSize: 18, color: Colors.grey)),
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
            ),
          ],
        ),
      ),
    );
  }
}
