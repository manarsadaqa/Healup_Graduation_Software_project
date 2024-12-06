import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../PatientPage.dart';
import 'ResetPasswordPage.dart';
import 'signUp.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

class PatLoginPage extends StatefulWidget {
  @override
  _PatLoginPageState createState() => _PatLoginPageState();
}

class _PatLoginPageState extends State<PatLoginPage> {
  late StreamSubscription _sub;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  late RegExp emailRegExp;
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initUniLinks();
    emailRegExp = RegExp(emailPattern);
  }

  Future<void> _initUniLinks() async {
    try {
      String? initialLink = await getInitialLink();
      if (initialLink != null) {
        Uri deepLink = Uri.parse(initialLink);
        _handleResetLink(deepLink);
      }
    } catch (e) {
      print("Error with deep linking: $e");
    }

    _sub = linkStream.listen((String? link) {
      if (link != null) {
        Uri deepLink = Uri.parse(link);
        _handleResetLink(deepLink);
      }
    });
  }

  void _handleResetLink(Uri deepLink) {
    String? token = deepLink.queryParameters['token'];
    if (token != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordPage(token: token),
        ),
      );
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;

      try {
        final response = await http.post(
          Uri.parse('http://localhost:5000/api/healup/patients/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'email': email, 'password': password}),
        );

        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData['_id'] != null) {
            // Save the patient's name and token in secure storage
            await _storage.write(key: 'auth_token', value: responseData['_id']);
            await _storage.write(key: 'patient_name', value: responseData['name']);  // Store the name
            await _storage.write(key: 'patient_id', value: responseData['_id']);  // Store patient ID

            // Navigate to the PatientPage
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => PatientPage()),
            );
          } else {
            _showErrorDialog('Invalid credentials. Please try again.');
          }
        } else {
          final responseData = json.decode(response.body);
          _showErrorDialog(responseData['message'] ?? 'An error occurred');
        }
      } catch (e) {
        _showErrorDialog('An error occurred. Please try again later.');
      }
    }
  }


  void _showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: 'Error',
      desc: message,
      btnOkOnPress: () {},
    )..show();
  }

  void _showSuccessDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: 'Success',
      desc: message,
      btnOkOnPress: () {},
    )..show();
  }

  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter your email'),
          content: TextField(
            controller: _emailController,
            decoration: InputDecoration(hintText: 'Email'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                String email = _emailController.text.trim();
                if (email.isNotEmpty && emailRegExp.hasMatch(email)) {
                  _sendResetPasswordRequest(email);
                  Navigator.of(context).pop();
                } else {
                  _showErrorDialog('Please enter a valid email address.');
                }
              },
              child: Text('Send Reset Link'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendResetPasswordRequest(String email) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/healup/patients/forgotPassword'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog('Password reset link has been sent to your email.');
      } else {
        final responseData = json.decode(response.body);
        _showErrorDialog(responseData['message'] ?? 'An error occurred.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred. Please try again later.');
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/signlogin.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Container(
            color: Colors.white.withOpacity(0.1),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center the login form vertically
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xff2f9a8f), size: 30),
                      onPressed: () => Navigator.of(context).pushReplacementNamed("welcomePage"),
                    ),
                  ),
                  const SizedBox(height: 40), // Add space above the form
                  const Center(
                    child: CircleAvatar(
                      radius: 70,
                      backgroundImage: AssetImage('images/logo.png'),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.lightBlue, Colors.lightGreen],
                              tileMode: TileMode.clamp,
                            ).createShader(bounds),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 55,
                                fontFamily: 'Hello Valentina',
                                fontWeight: FontWeight.bold,
                                color: Colors.lightBlue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 50),
                          // Email TextField
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.grey[700]),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              } else if (!emailRegExp.hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Password TextField
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.grey[700]),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              } else if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Forgot Password Button (Aligned to the left)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _forgotPassword,
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(color: Colors.black, fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Login Button (Centered)
                          ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff2f9a8f),
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(fontSize: 18,color: Colors.white,)
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Create Account Button (Centered under the login button)
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PatSignUpPage()), // Navigate to the sign-up page
                              );
                            },
                            child: const Text(
                              "Don't have an account? Sign up",
                              style: TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
