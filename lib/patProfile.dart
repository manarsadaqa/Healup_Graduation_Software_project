import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data'; // For MemoryImage (web)
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';  // For encoding image to base64
import 'ThemeNotifier.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart'; // Import file_picker


class PatProfile extends StatefulWidget {
  final String patientId; // Pass the patient ID to this widget

  const PatProfile({super.key, required this.patientId});

  @override
  _PatProfileState createState() => _PatProfileState();
}

class _PatProfileState extends State<PatProfile> {
  File? _profileImage; // Store the selected profile image
  ImageProvider? _profileImageProvider; // Store the selected image as ImageProvider (for web)
  Map<String, dynamic>? _patientData; // Store patient data
  bool _isLoading = true; // Track loading state
  bool _isUpdating = false; // Track if data is being updated

  // Controllers for editable fields
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;
  late TextEditingController _phoneController;
  late TextEditingController _medicalHistoryController;

  bool _notificationsEnabled = true; // Track notification status

  @override
  void initState() {
    super.initState();
    _fetchPatientData(widget.patientId); // Fetch patient data on widget load
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }
// Function to show confirmation dialog for turning off dark mode or any setting change
  void _showConfirmationDialog(BuildContext context, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                onConfirm(); // Execute the action when confirmed
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Function to fetch patient data from the backend
  Future<void> _fetchPatientData(String patientId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/healup/patients/getPatientById/$patientId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _patientData = data;
          _usernameController = TextEditingController(text: data['username']);
          _emailController = TextEditingController(text: data['email']);
          _addressController = TextEditingController(text: data['address']);
          _dobController = TextEditingController(text: data['dob']);
          _phoneController = TextEditingController(text: data['phone']);
          _medicalHistoryController = TextEditingController(text: data['medicalHistory']);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load patient data');
      }
    } catch (e) {
      print('Error fetching patient data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to pick an image from the gallery (for web)
    Future<void> _pickImage() async {
      FilePickerResult? result;

      if (kIsWeb) {
        // For web, use file_picker_web
        result = await FilePicker.platform.pickFiles(type: FileType.image);
      } else {
        // For mobile, use default file_picker behavior
        result = await FilePicker.platform.pickFiles(type: FileType.image);
      }

      if (result != null) {
        // Picked file
        PlatformFile file = result.files.single;
        print('Picked file path: ${file.path}');

        setState(() {
          // Check if running on the web
          if (kIsWeb) {
            // If on web, read the image as bytes and use MemoryImage for web
            _profileImageProvider = MemoryImage(
                Uint8List.fromList(file.bytes!)); // Use MemoryImage for web
            _profileImage = null; // Clear the file-based image for web
          } else {
            // If on mobile, use FileImage
            _profileImage = File(file.path!);
            _profileImageProvider = null; // Clear the MemoryImage for mobile
          }
        });
      } else {
        print('No image selected.');
      }
    }

  // Function to update patient data
  Future<void> _updatePatientData() async {
    setState(() {
      _isUpdating = true; // Show loading spinner
    });

    try {
      final uri = Uri.parse('http://localhost:5000/api/healup/patients/updatePatient/${widget.patientId}');
      final headers = {
        'Content-Type': 'application/json',
      };

      final body = jsonEncode({
        'username': _usernameController.text,
        'address': _addressController.text,
        'DOB': _dobController.text,
        'phone': _phoneController.text,
        'medical_history': _medicalHistoryController.text,
      });

      final response = await http.put(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        final updatedData = jsonDecode(response.body);

        setState(() {
          _patientData = updatedData['data']; // Update local data
          _isUpdating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      print('Error updating patient data: $e');
      setState(() {
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  // Function to show confirmation dialog for turning off notifications
  void _showTurnOffNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Turn off Notifications"),
          content: const Text("Are you sure you want to turn off notifications?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                setState(() {
                  _notificationsEnabled = false;
                });
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Function to show settings menu with notification toggle
  void _showSettingsMenu(BuildContext context, ThemeNotifier themeNotifier) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Settings"),
          content: Container(
            width: 300, // Set the desired width for the dialog
        child: Column(
        mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  themeNotifier.isDarkMode
                      ? Icons.nightlight_round
                      : Icons.wb_sunny,
                  color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
                ),
                title: const Text("Dark Mode"),
                trailing: Switch(
                  value: themeNotifier.isDarkMode,
                  onChanged: (value) {
                    // Show confirmation dialog if turning off dark mode
                    if (themeNotifier.isDarkMode && !value) {
                      _showConfirmationDialog(context, 'Turn off Dark Mode?', () {
                        themeNotifier.toggleTheme();
                        Navigator.of(context).pop(); // Close the dialog
                      });
                    } else {
                      themeNotifier.toggleTheme();
                    }
                  },
                ),
              ),

              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text("Notifications"),
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    if (_notificationsEnabled && !value) {
                      _showTurnOffNotificationsDialog(context); // Show confirmation to turn off
                    } else {
                      setState(() {
                        _notificationsEnabled = value; // Directly toggle notifications
                      });
                    }
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text("About"),
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
              leading: const Icon(Icons.star),
              title: const Text("Rate the App"),
              onTap: () async {
                final inAppReview = InAppReview.instance;
                if (await inAppReview.isAvailable()) {
                  inAppReview.requestReview();
                } else {
                  // You can show a message or redirect the user to the store
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("You cannot rate the app right now.")),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Privacy Policy"),
              onTap: () {
                _showPrivacyPolicyDialog(context);
              },
            ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text("Log Out"),
                onTap: () async {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      "login", (route) => false); // Perform logout action here
                  print("User logged out");
                },
              ),
            ],
        ),
          ),
          // Adjust the width of the AlertDialog
          contentPadding: EdgeInsets.all(16.0), // Optional: Add padding to the content
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Profile"),
        backgroundColor: const Color(0xff6be4d7),

        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  _showSettingsMenu(context, themeNotifier);
                },
              ),
              if (_notificationsEnabled)
                Positioned(
                  top: 6,
                  right: 6,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: const Text(
                      '!',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _patientData == null
          ? const Center(child: Text("Failed to load patient data"))
          : Stack(
        children: [
          // Background Image
          Image.asset(
            "images/pat.jpg",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Profile Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: _profileImage != null
                            ? (kIsWeb
                            ? _profileImageProvider!
                            : FileImage(_profileImage!))
                            : NetworkImage(_patientData!['pic']) as ImageProvider,
                        child: _profileImage == null
                            ? Icon(
                          Icons.camera_alt,
                          size: 30,
                          color: Colors.white.withOpacity(0.8),
                        )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Editable Fields
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: "Username"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    readOnly: true, // Email is not editable
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: "Address"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _dobController,
                    decoration: const InputDecoration(labelText: "Date of Birth"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: "Phone"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _medicalHistoryController,
                    decoration: const InputDecoration(labelText: "Medical History"),
                  ),
                  const SizedBox(height: 20),
                  // Save Button
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2f9a8f),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _isUpdating ? null : _updatePatientData,
                      child: _isUpdating
                          ? const CircularProgressIndicator(color: Color(0xff2f9a8f))
                          : const Text("Save Changes" ,
                          style: TextStyle(fontSize: 18,color: Colors.white,)
                    ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
void _showPrivacyPolicyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Privacy Policy"),
        content: SingleChildScrollView(
          child: Column(
            children: const [
              Text(
                "Your privacy is important to us. Please read our privacy policy to understand how we collect, use, and protect your information...",
                style: TextStyle(fontSize: 16),
              ),
              // Add more policy content as needed
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      );
    },
  );
}