import 'package:first/signUp.dart';
import 'package:flutter/material.dart';
import 'PatientPage.dart';
import 'package:provider/provider.dart';
import 'ThemeNotifier.dart';
import 'homepage.dart';
import 'login.dart'; // Import the ThemeNotifier class
import 'DiagnosisChat.dart';
import 'ResetPasswordPage.dart';

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
          home:  PatientPage(),
          routes: {
            "signup": (context) => const PatSignUpPage(),
            "login": (context) =>  PatLoginPage(),
            '/reset-password': (context) => ResetPasswordPage(token: 'some_token'),
            "homepage": (context) => const PatientPage(),
            "WelcomePage": (context) => const WelcomePage()
          }, // Your home page
        );
      },
    );
  }
}
