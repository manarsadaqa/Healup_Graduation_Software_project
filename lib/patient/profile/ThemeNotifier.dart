import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  // Define the current theme mode (light by default)
  bool _isDarkMode = false;

  // Getter for the current theme
  bool get isDarkMode => _isDarkMode;

  // Method to toggle between dark and light modes
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // Notify all listeners that the theme has changed
  }

  // Method to get the current theme data
  ThemeData get currentTheme {
    return _isDarkMode ? ThemeData.dark() : ThemeData.light();
  }
}
