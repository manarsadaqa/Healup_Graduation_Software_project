import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_review/in_app_review.dart';

class DoctorProfilePage extends StatefulWidget {
  @override
  _DoctorProfilePageState createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final _storage = FlutterSecureStorage();
  Map<String, dynamic>? doctorData; // Store doctor data
  bool isLoading = true; // Loading state
  final _formKey = GlobalKey<FormState>();
  bool _notificationsEnabled = true; // Notification toggle state
  bool _isDarkMode = false; // Dark mode toggle state

  // Controllers for the form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _yearExperienceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDoctorDetails(); // Fetch details on page load
  }

  Future<void> _fetchDoctorDetails() async {
    try {
      // Retrieve the doctor ID from secure storage
      String? doctorId = await _storage.read(key: 'doctor_id');
      if (doctorId == null) {
        throw Exception("Doctor ID not found in storage.");
      }

      // Make a GET request to fetch doctor data
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/healup/doctors/doctor/$doctorId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          doctorData = json.decode(response.body); // Parse doctor data
          isLoading = false;
        });
        _populateFields(); // Populate the form fields with the current doctor data
      } else {
        throw Exception("Failed to load doctor details.");
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog("An error occurred while loading doctor details.");
    }
  }

  void _populateFields() {
    if (doctorData != null) {
      _nameController.text = doctorData!['name'] ?? '';
      _usernameController.text = doctorData!['username'] ?? '';
      _specializationController.text = doctorData!['specialization'] ?? '';
      _phoneController.text = doctorData!['phone'] ?? '';
      _emailController.text = doctorData!['email'] ?? '';
      _addressController.text = doctorData!['address'] ?? '';
      _hospitalController.text = doctorData!['hospital'] ?? '';
      _priceController.text = doctorData!['pricePerHour'].toString() ?? '';
      _yearExperienceController.text = doctorData!['yearExperience'].toString() ?? '';
    }
  }

  Future<void> _updateDoctorProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? doctorId = await _storage.read(key: 'doctor_id');
        final response = await http.put(
          Uri.parse('http://localhost:5000/api/healup/doctors/$doctorId'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'name': _nameController.text,
            'username': _usernameController.text,
            'specialization': _specializationController.text,
            'phone': _phoneController.text,
            'email': _emailController.text,
            'address': _addressController.text,
            'hospital': _hospitalController.text,
            'pricePerHour': _priceController.text,
            'yearExperience': _yearExperienceController.text,
          }),
        );

        if (response.statusCode == 200) {
          final updatedDoctor = json.decode(response.body);
          setState(() {
            doctorData = updatedDoctor; // Update the doctor data
          });
          _showSuccessDialog("Profile updated successfully.");
        } else {
          throw Exception("Failed to update doctor details.");
        }
      } catch (error) {
        _showErrorDialog("An error occurred while updating the profile.");
      }
    }
  }

  Future<void> _logout() async {
    // Clear the secure storage
    await _storage.deleteAll();
    // Navigate back to login screen
    Navigator.of(context).pushReplacementNamed('Doctor_login');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Success"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSettingsMenu() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Settings"),
          content: Container(
            width: 300, // Set the desired width for the dialog
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    _isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                  title: Text("Dark Mode"),
                  trailing: Switch(
                    value: _isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        _isDarkMode = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text("Notifications"),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text("About"),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: "Health App",
                      applicationVersion: "1.0.0",
                      applicationLegalese: "© 2024 Health Co.",
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.star),
                  title: Text("Rate the App"),
                  onTap: () async {
                    final inAppReview = InAppReview.instance;
                    if (await inAppReview.isAvailable()) {
                      inAppReview.requestReview();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("You cannot rate the app right now.")),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.lock),
                  title: Text("Privacy Policy"),
                  onTap: () {
                    _showPrivacyPolicyDialog(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text("Log Out"),
                  onTap: () async {
                    await _storage.deleteAll();
                    Navigator.of(context).pushReplacementNamed('Doctor_login');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Privacy Policy"),
          content: SingleChildScrollView(
            child: Text("Your privacy policy text goes here."),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doctor Profile"),
        backgroundColor: const Color(0xff6be4d7),
        actions: [
          // Settings Icon
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showSettingsMenu,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/back.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.2), // Semi-transparent overlay
            ),
          ),
          // Foreground Content
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView( // Wrap the content in SingleChildScrollView
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: doctorData!['photo'] != null
                            ? NetworkImage(doctorData!['photo'])
                            : AssetImage('assets/doctor.jpg') as ImageProvider,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold), // White label
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      style: TextStyle(color: Colors.white,fontSize:17,fontWeight: FontWeight.bold), // White text
                      validator: (value) => value!.isEmpty ? 'Name is required' : null,
                    ),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold), // White label
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      style: TextStyle(color: Colors.white,fontSize:17,fontWeight: FontWeight.bold), // White text
                    ),
                    TextFormField(
                      controller: _specializationController,
                      decoration: InputDecoration(
                        labelText: 'Specialization',
                        labelStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold), // White label
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      style: TextStyle(color: Colors.white,fontSize:17,fontWeight: FontWeight.bold), // White text
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        labelStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold), // White label
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      style: TextStyle(color: Colors.white,fontSize:17,fontWeight: FontWeight.bold), // White text
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold), // White label
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      style: TextStyle(color: Colors.white,fontSize:17,fontWeight: FontWeight.bold), // White text
                      validator: (value) => value!.isEmpty ? 'Email is required' : null,
                      enabled: false, // Make email read-only

                    ),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        labelStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold), // White label
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      style: TextStyle(color: Colors.white,fontSize:17,fontWeight: FontWeight.bold), // White text
                    ),
                    TextFormField(
                      controller: _hospitalController,
                      decoration: InputDecoration(
                        labelText: 'Hospital',
                        labelStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold), // White label
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      style: TextStyle(color: Colors.white,fontSize:17,fontWeight: FontWeight.bold), // White text
                    ),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Price per Hour',
                        labelStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold), // White label
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      style: TextStyle(color: Colors.white,fontSize:17,fontWeight: FontWeight.bold), // White text
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: _yearExperienceController,
                      decoration: InputDecoration(
                        labelText: 'Years of Experience',
                        labelStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold), // White label
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      style: TextStyle(color: Colors.white,fontSize:17,fontWeight: FontWeight.bold), // White text
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    Center(
                      child:ElevatedButton(
                        onPressed: _updateDoctorProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2f9a8f),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),

                        child: const Text(
                            'Update Profile ',
                            style: TextStyle(fontSize: 18,color: Colors.white,)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildProfileTextField(TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$labelText is required";
          }
          return null;
        },
      ),
    );
  }
}
