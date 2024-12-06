import 'package:first/patient/login&signUP/signUp.dart';
import 'package:flutter/material.dart';
import 'patient/PatientPage.dart';
import 'package:provider/provider.dart';
import 'patient/profile/ThemeNotifier.dart';
import 'homepage.dart';
import 'patient/login&signUP/login.dart'; // Import the ThemeNotifier class
import 'patient/login&signUP/ResetPasswordPage.dart';
import 'Doctors/DoctorLoginPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  void initState() {

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          theme: themeNotifier.currentTheme, // Apply the current theme
          home:  WelcomePage(),
          routes: {
            "welcomePage":(context) => const WelcomePage(),
            "signup": (context) => const PatSignUpPage(),
            "login": (context) =>  PatLoginPage(),
            '/reset-password': (context) => ResetPasswordPage(token: 'some_token'),
            "homepage": (context) => const PatientPage(),
            "WelcomePage": (context) => const WelcomePage(),
            "Doctor_login":(context) =>  DoctorLoginPage()
          }, // Your home page
        );
      },
    );
  }
}
