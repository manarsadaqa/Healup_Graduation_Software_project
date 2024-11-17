import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // Import json for encoding
import 'PatientPage.dart'; // Import the Patient Page


class PatSignUpPage extends StatefulWidget {
  const PatSignUpPage({super.key});

  @override
  _PatSignUpPageState createState() => _PatSignUpPageState();
}

class _PatSignUpPageState extends State<PatSignUpPage> {
  final List<String> palestinianCities = [
    'Ramallah', 'Gaza', 'Hebron', 'Nablus', 'Jenin', 'Bethlehem', 'Jericho',
    'Tulkarm', 'Qalqilya', 'Rafah', 'Khan Younis', 'Beit Lahia', 'Beit Hanoun',
    'Deir al-Balah', 'Salfit', 'Tubas', 'Bani Na\'im', 'Yatta'
  ];

  final List<String> chronicDiseasesList = [
    'None', 'Diabetes', 'Hypertension', 'Heart Disease', 'Asthma',
    'Chronic Kidney Disease', 'Cancer', 'Liver Disease', 'Others'
  ];

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String selectedCity = 'Ramallah';
  String selectedGender = 'Male';
  String selectedChronicDisease = 'None';
  String? _emailError, _usernameError, _passwordError, _confirmPasswordError;
  DateTime? _selectedDate;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final RegExp emailRegExp = RegExp(r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');

  Future<void> signUp() async {
    final signUpData = {
      'username': _usernameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'DOB': _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : '',
      'gender': selectedGender,
      'phone': '+970${phoneController.text}',
      'address': selectedCity,
      'medical_history': selectedChronicDisease,
    };
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/healup/patients'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(signUpData),
      );
      if (response.statusCode == 201) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: 'Success',
          desc: 'Account created successfully!',
          btnOkOnPress: () {
            // Navigate to the WelcomePage after successful sign-up
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => PatientPage()), // Replace WelcomePage() with your actual welcome page
            );
          },
        ).show();
      } else {
        final errorData = json.decode(response.body);
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Sign Up Failed',
          desc: errorData['message'] ?? 'An error occurred. Please try again.',
          btnOkOnPress: () {},
        ).show();
      }
    }  catch (e) {
  print("Error: $e");
  AwesomeDialog(
  context: context,
  dialogType: DialogType.error,
  title: 'Error',
  desc: 'Could not connect to the server. Check your internet connection.',
  btnOkOnPress: () {},
  ).show();
  }

}

  void _validateEmail(String value) {
    setState(() {
      _emailError = (value.isEmpty || !emailRegExp.hasMatch(value)) ? 'Please enter a valid email' : null;
    });
  }

  void _validateUsername(String value) {
    setState(() {
      _usernameError = value.isEmpty ? 'Please enter a username' : null;
    });
  }

  void _validatePassword(String value) {
    setState(() {
      _passwordError = value.length < 6 ? 'Password must be at least 6 characters' : null;
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      _confirmPasswordError = (value != _passwordController.text) ? 'Passwords do not match' : null;
    });
  }

  Future<void> _selectBirthdate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
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
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xff2f9a8f), size: 30),
                      onPressed: () => Navigator.of(context).pushReplacementNamed("login"),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Create a New Account',
                      style: TextStyle(fontSize: 24, color: Color(0xff2f9a8f)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              errorText: _emailError,
                            ),
                            onChanged: _validateEmail,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              errorText: _usernameError,
                            ),
                            onChanged: _validateUsername,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              errorText: _passwordError,
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            onChanged: _validatePassword,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              errorText: _confirmPasswordError,
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            onChanged: _validateConfirmPassword,
                          ),
                          const SizedBox(height: 20),
                          IntlPhoneField(
                            controller: phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            initialCountryCode: 'PS',
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => _selectBirthdate(context),
                            child: Text(_selectedDate != null
                                ? 'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}'
                                : 'Select Date of Birth'),
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            value: selectedGender,
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value!;
                              });
                            },
                            items: ['Male', 'Female']
                                .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ))
                                .toList(),
                            decoration: InputDecoration(
                              labelText: 'Gender',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            value: selectedCity,
                            onChanged: (value) {
                              setState(() {
                                selectedCity = value!;
                              });
                            },
                            items: palestinianCities
                                .map((city) => DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            ))
                                .toList(),
                            decoration: InputDecoration(
                              labelText: 'City',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            value: selectedChronicDisease,
                            onChanged: (value) {
                              setState(() {
                                selectedChronicDisease = value!;
                              });
                            },
                            items: chronicDiseasesList
                                .map((disease) => DropdownMenuItem(
                              value: disease,
                              child: Text(disease),
                            ))
                                .toList(),
                            decoration: InputDecoration(
                              labelText: 'Chronic Disease (if any)',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate() && _selectedDate != null) {
                                await signUp();
                              } else if (_selectedDate == null) {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.warning,
                                  title: 'Date of Birth Required',
                                  desc: 'Please select your birthdate.',
                                  btnOkOnPress: () {},
                                ).show();
                              }
                            },
                            child: const Text('Sign Up'),
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
