import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'managementList.dart';  // Assuming you have a page that lists the management

class AddManagementPage extends StatefulWidget {
  @override
  _AddManagementPageState createState() => _AddManagementPageState();
}

class _AddManagementPageState extends State<AddManagementPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Add Management function
  Future<void> _addManagement() async {
    final url = 'http://10.0.2.2:5000/api/healup/management/register';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': _nameController.text,
        'gender': _genderController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Management added successfully')),
      );
      // Navigate to the management list page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ManagementListPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add management')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false,  // لإزالة سهم التراجع
        title: const Text(
          "Add New Management",
          style: TextStyle(
            fontSize: 24,  // زيادة حجم الخط
            //fontWeight: FontWeight.bold,  // جعل الخط عريض
          ),
        ),
        backgroundColor: const Color(0xff2f9a8f),
      ),
      body: Container(
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                icon: Icons.person,
                validator: (value) => value!.isEmpty ? 'Please enter name' : null,
              ),
              // Gender
              _buildTextField(
                controller: _genderController,
                label: 'Gender',
                icon: Icons.person_outline,
                validator: (value) => value!.isEmpty ? 'Please enter gender' : null,
              ),
              // Phone
              _buildTextField(
                controller: _phoneController,
                label: 'Phone',
                icon: Icons.phone,
                validator: (value) => value!.isEmpty ? 'Please enter phone number' : null,
              ),
              // Address
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on,
                validator: (value) => value!.isEmpty ? 'Please enter address' : null,
              ),
              // Email
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                validator: (value) => value!.isEmpty ? 'Please enter email' : null,
              ),
              // Password
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock,
                //obscureText: true,
                validator: (value) => value!.isEmpty ? 'Please enter password' : null,
              ),
              SizedBox(height: 20),
              // Add Management Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addManagement();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2f9a8f),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  'Add Management',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom text field builder with icon and validation
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black87),
          labelText: label,
          labelStyle: TextStyle(color: Colors.black87, fontSize: 18),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black87, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black87, width: 2),
          ),
        ),
        style: TextStyle(color: Colors.black, fontSize: 18),
        validator: validator,
      ),
    );
  }
}
