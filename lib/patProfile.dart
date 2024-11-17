import 'dart:io'; // To handle file I/O for images
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'ThemeNotifier.dart'; // Import the ThemeNotifier class

class PatProfile extends StatefulWidget {
  const PatProfile({super.key});

  @override
  _PatProfileState createState() => _PatProfileState();
}

class _PatProfileState extends State<PatProfile> {
  File? _profileImage; // Store the selected profile image
  final picker = ImagePicker();
  final TextEditingController _nameController =
      TextEditingController(text: "John Doe");

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path); // Set the selected image
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier =
        Provider.of<ThemeNotifier>(context); // Access the ThemeNotifier

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Profile"),
        backgroundColor:
            themeNotifier.isDarkMode ? Colors.black : const Color(0xff6be4d7),
      ),
      body: Stack(
        children: [
          // Background Image from assets
          Image.asset(
            "images/pat.jpg", // Path to your background image in the assets folder
            fit: BoxFit.cover, // Ensure the image covers the entire screen
            width: double.infinity, // Set width to fill the screen
            height: double.infinity, // Set height to fill the screen
          ),

          // Profile Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture and User Info
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage, // On tap, allow image selection
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: _profileImage != null
                                ? FileImage(
                                    _profileImage!) // Display the picked image
                                : const NetworkImage(
                                    "https://via.placeholder.com/150", // Default profile image URL
                                  ) as ImageProvider,
                            child: Icon(
                              Icons.camera_alt,
                              size: 30,
                              color: Colors.white.withOpacity(0.8),
                            ), // Icon to indicate change image
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Editable Name
                        TextField(
                          controller: _nameController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black), // Change color if needed
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter your name",
                            hintStyle: TextStyle(
                                color: Colors.black), // Hint text color
                          ),
                        ),
                        const SizedBox(height: 10),
                        // User Email (non-editable)
                        const Text(
                          "johndoe@example.com",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Settings Section
                  const Text(
                    "Settings",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black), // Change color if needed
                  ),
                  const SizedBox(height: 10),

                  // Dark Mode Switch
                  ListTile(
                    leading: Icon(
                      themeNotifier.isDarkMode
                          ? Icons.nightlight_round
                          : Icons.wb_sunny,
                      color: themeNotifier.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                    title: const Text("Dark Mode",
                        style: TextStyle(
                            color: Colors.black)), // Change color if needed
                    trailing: Switch(
                      value: themeNotifier.isDarkMode,
                      onChanged: (value) {
                        themeNotifier.toggleTheme(); // Toggle dark mode
                      },
                    ),
                  ),

                  // Notifications Setting
                  ListTile(
                    leading: const Icon(Icons.notifications,
                        color: Colors.black), // Change color if needed
                    title: const Text("Notifications",
                        style: TextStyle(
                            color: Colors.black)), // Change color if needed
                    trailing: Switch(
                      value:
                          true, // This should be linked to actual notification settings
                      onChanged: (value) {
                        // Handle notifications toggle
                        print("Notifications toggled: $value");
                      },
                    ),
                  ),

                  // About Section
                  ListTile(
                    leading: const Icon(Icons.info,
                        color: Colors.black), // Change color if needed
                    title: const Text("About",
                        style: TextStyle(
                            color: Colors.black)), // Change color if needed
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: "Health App",
                        applicationVersion: "1.0.0",
                        applicationLegalese: "© 2024 Health App Inc.",
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Text(
                                "This app helps patients to track their medication, schedule, and profile details.",
                                style: TextStyle(
                                    color: Colors
                                        .black)), // Change color if needed
                          ),
                        ],
                      );
                    },
                  ),

                  // Logout Option
                  ListTile(
                    leading: const Icon(Icons.logout,
                        color: Colors.black), // Change color if needed
                    title: const Text("Logout",
                        style: TextStyle(
                            color: Colors.black)), // Change color if needed
                    onTap: () async {
                      // Handle logout action
                      GoogleSignIn googlwSignIn = GoogleSignIn();
                      googlwSignIn.disconnect();
                      Navigator.of(context).pushNamedAndRemoveUntil("login",
                          (route) => false); // Perform logout action here
                      print("User logged out");
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show confirmation dialog for logout
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Logout"),
              onPressed: () async {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    "login", (route) => false); // Perform logout action here
                print("User logged out");
              },
            ),
          ],
        );
      },
    );
  }
}
