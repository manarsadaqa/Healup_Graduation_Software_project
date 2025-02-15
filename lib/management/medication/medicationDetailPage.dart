import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MedicationDetailsPage extends StatefulWidget {
  final String medicationId;

  MedicationDetailsPage({required this.medicationId});

  @override
  _MedicationDetailsPageState createState() => _MedicationDetailsPageState();
}

class _MedicationDetailsPageState extends State<MedicationDetailsPage> {
  Map<String, dynamic> medicationDetails = {};

  Future<void> fetchMedicationDetails() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:5000/api/healup/medication/${widget.medicationId}"),
      );
      if (response.statusCode == 200) {
        setState(() {
          medicationDetails = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch medication details")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $error")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMedicationDetails();
  }

  Widget _buildTextField(String label, dynamic value) {
    // Convert int or double to String
    String displayValue = value is double
        ? value.toStringAsFixed(2)  // Convert double to String with two decimal points
        : value is int ? value.toString() : value ?? "N/A";  // Convert int to String

    return TextFormField(
      initialValue: displayValue,
      readOnly: true, // Make the field read-only
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[900],
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Color(0xff2f9a8f),
            width: 3,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Color(0xff2f9a8f),
            width: 3,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xff2f9a8f), width: 3),
        ),
        fillColor: Colors.white.withOpacity(0.8),
        filled: true,
      ),
      style: TextStyle(
        color: Color(0xff2f9a8f),
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Medication Details",
          style: TextStyle(
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xff2f9a8f),
      ),
      body:
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/pat.jpg'),

            //image: AssetImage('images/back.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: medicationDetails.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Medication image
              // Medication image
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),  // التأثير نفسه مع الزوايا المدورة
                  child: SizedBox(
                    height: 200,  // تحديد الارتفاع للمربع
                    width: 200,   // تحديد العرض للمربع
                    child: Image.asset(
                      medicationDetails['image'] ?? 'images/default-image.jpg',
                      fit: BoxFit.contain,  // تصغير الصورة داخل المربع دون القص
                    ),
                  ),
                ),
              ),

              // Center(
              //   child: ClipRRect(
              //     borderRadius: BorderRadius.circular(12),  // نفس التأثير في الكود الثاني
              //     child: SizedBox(
              //       height: 200,  // تحديد ارتفاع مشابه للكود الثاني
              //       width: 200,   // تحديد عرض ثابت للصورة
              //       child: Image.asset(
              //         medicationDetails['image'] ?? 'images/default-image.jpg',
              //         fit: BoxFit.cover,  // نفس خيار تكبير الصورة
              //       ),
              //     ),
              //   ),
              // ),
              //const SizedBox(height: 14),  // مسافة بين العناصر

              // Center(
              //   child: Image.asset(
              //     medicationDetails['image'] ?? 'images/default-image.jpg',
              //     width: 120,
              //     height: 120,
              //     fit: BoxFit.cover,
              //   ),
              // ),
              const SizedBox(height: 14),

              // White line under image
              Container(
                height: 3,
                color: Colors.white,
              ),
              const SizedBox(height: 20),

              // Display medication information in text fields
              _buildTextField("Medication Name", medicationDetails['medication_name']),
              const SizedBox(height: 10),
              _buildTextField("Scientific Name", medicationDetails['scientific_name']),
              const SizedBox(height: 10),
              _buildTextField("Stock Quantity", medicationDetails['stock_quantity']),
              const SizedBox(height: 10),
              _buildTextField("Expiration Date", medicationDetails['expiration_date']),
              const SizedBox(height: 10),
              _buildTextField("Description", medicationDetails['description']),
              const SizedBox(height: 10),
              _buildTextField("Type", medicationDetails['type']),
              const SizedBox(height: 10),
              _buildTextField("Price", medicationDetails['price']),
            ],
          ),
        ),
      ),
    );
  }
}
