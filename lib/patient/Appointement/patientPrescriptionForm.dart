import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw; // For PDF generation
import 'dart:io'; // For file operations
import 'package:path_provider/path_provider.dart'; // To save files
import 'package:permission_handler/permission_handler.dart';

class PrescriptionPage extends StatefulWidget {
  final String doctorSpecialization;
  final String doctorName;
  final String doctorPhone;
  final String doctorHospital;
  final String patientName;
  final String patientAge;
  final String date;
  final List<Map<String, String>> medications;

  PrescriptionPage({
    required this.doctorSpecialization,
    required this.doctorName,
    required this.doctorPhone,
    required this.doctorHospital,
    required this.patientName,
    required this.patientAge,
    required this.date,
    required this.medications,
  });

  @override
  _PrescriptionPageState createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {

  Future<void> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isDenied) {
        // Request Manage External Storage Permission
        await Permission.manageExternalStorage.request();
      }
    }
  }

  Future<void> savePrescriptionAsPdf() async {
    final pdf = pw.Document();

    // Build PDF content
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title
              pw.Text(
                "Prescription Details",
                style: pw.TextStyle(
                  fontSize: 40, // Increased font size for title
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20), // Space after title
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
                        pw.Text("Doctor Name: ${widget.doctorName}", style: pw.TextStyle(fontSize: 22)),
                        pw.Text('Specialization: ${widget.doctorSpecialization}', style: pw.TextStyle(fontSize: 22)),
                        pw.Text('Phone: ${widget.doctorPhone}', style: pw.TextStyle(fontSize: 22)),
                        pw.Text('Hospital: ${widget.doctorHospital}', style: pw.TextStyle(fontSize: 22)),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  // Patient's Details
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Patient Information", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 8),
                        pw.Text('Patient Name: ${widget.patientName}', style: pw.TextStyle(fontSize: 22)),
                        pw.Text("Age: ${widget.patientAge}", style: pw.TextStyle(fontSize: 22)),
                        pw.Text('Prescription Date: ${widget.date}', style: pw.TextStyle(fontSize: 22)),
                      ],
                    ),
                  ),
                ],
              ),
              // Doctor and Patient Information Section (Two Columns)

              pw.SizedBox(height: 20), // Space between sections

              // Medications Section
              pw.Text(
                "Medications:",
                style: pw.TextStyle(
                  fontSize: 24, // Increased font size for label
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              ...widget.medications.map((med) {
                return pw.Text(
                  "${med['name']}, Dosage: ${med['dosage']}, Quantity: ${med['quantity']}",
                  style: pw.TextStyle(fontSize: 20),
                );
              }).toList(),
            ],
          );
        },
      ),
    );




    // Request Storage Permission
    await requestStoragePermission();

    if (await Permission.manageExternalStorage.isGranted || await Permission.storage.isGranted) {
      try {
        final directory = Directory('/storage/emulated/0/Download');
        if (!directory.existsSync()) {
          await directory.create(recursive: true);
        }

        final file = File("${directory.path}/prescription_${DateTime.now().millisecondsSinceEpoch}.pdf");
        await file.writeAsBytes(await pdf.save());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✔ Prescription saved Successfully")),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prescription Details"),
        backgroundColor: const Color(0xff6be4d7),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: savePrescriptionAsPdf,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor and Patient Information Section
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
                      Text("Doctor Name: ${widget.doctorName}", style: TextStyle(fontSize: 16)),
                      Text('Specialization: ${widget.doctorSpecialization}', style: TextStyle(fontSize: 16)),
                      Text('Phone: ${widget.doctorPhone}', style: TextStyle(fontSize: 16)),
                      Text('Hospital: ${widget.doctorHospital}', style: TextStyle(fontSize: 16)),
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
                      Text('Patient Name: ${widget.patientName}', style: TextStyle(fontSize: 16)),
                      Text("Age: ${widget.patientAge}", style: TextStyle(fontSize: 16)),
                      Text('Prescription Date: ${widget.date}', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(color: Colors.black, thickness: 2),
            SizedBox(height: 20),
            Text("Medications:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...widget.medications.map((med) {
              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    "Name: ${med['name']}\nQuantity: ${med['quantity']}\nDosage: ${med['dosage']}",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
