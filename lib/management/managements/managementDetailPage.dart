import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ManagementDetailsPage extends StatefulWidget {
  final String managementId;

  ManagementDetailsPage({required this.managementId});

  @override
  _ManagementDetailsPageState createState() => _ManagementDetailsPageState();
}

class _ManagementDetailsPageState extends State<ManagementDetailsPage> {
  Map<String, dynamic> managementDetails = {};

  Future<void> fetchManagementDetails() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:5000/api/healup/management/${widget.managementId}"),
      );
      if (response.statusCode == 200) {
        setState(() {
          managementDetails = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch management details")),
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
    fetchManagementDetails();
  }

  Widget _buildTextField(String label, dynamic value) {
    // Convert int or double values to String
    String displayValue = value is double
        ? value.toStringAsFixed(2)  // Convert double to String with two decimal points
        : value is int ? value.toString() : value ?? "N/A";  // Convert int to String

    return TextFormField(
      initialValue: displayValue,
      readOnly: true, // Ensure the field is read-only for management details
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
        //automaticallyImplyLeading: false,  // لإزالة سهم التراجع
        title: const Text(
          "Management Details",
          style: TextStyle(
            fontSize: 24,  // زيادة حجم الخط
            //fontWeight: FontWeight.bold,  // جعل الخط عريض
          ),
        ),
        backgroundColor: const Color(0xff2f9a8f),
      ),
      // appBar: AppBar(
      //   title: Text("Management Details"),
      //   backgroundColor: Color(0xff2f9a8f),
      // ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/pat.jpg'),

            // image: AssetImage('images/back.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: managementDetails.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Display a placeholder image or profile image
              Center(
                child:
                IconButton(
                  icon: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.black45,
                    size: 80,  // يمكنك تغيير هذا الرقم حسب الحجم المطلوب
                  ),
                  onPressed: () {
                    // _showDeleteDialog(order['id'], order['patient']);
                  },
                ),

                // CircleAvatar(
                //   radius: 60,
                //   backgroundImage: NetworkImage(
                //     'https://icon-library.com/images/anonymous-avatar-icon/anonymous-avatar-icon-25.jpg', // Placeholder image
                //   ),
                // ),
              ),
              const SizedBox(height: 14),

              //White line separator
              Container(
                height: 3,
                color: Colors.white,
              ),
              const SizedBox(height: 20),

              // Display management details in text fields
              // _buildTextField("ID", managementDetails['id']),
              // const SizedBox(height: 10),
              _buildTextField("Name", managementDetails['name']),
              const SizedBox(height: 10),
              _buildTextField("Gender", managementDetails['gender']),
              const SizedBox(height: 10),
              _buildTextField("Phone", managementDetails['phone']),
              const SizedBox(height: 10),
              _buildTextField("Email", managementDetails['email']),
              const SizedBox(height: 10),
              _buildTextField("Address", managementDetails['address']),
            ],
          ),
        ),
      ),
    );
  }
}
