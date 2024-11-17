// login_signup_page.dart
import 'package:flutter/material.dart';

class patSignUp extends StatelessWidget {
  const patSignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login / Sign Up'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Login or Sign Up',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement your login logic here
                print('Login button pressed');
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement your sign-up logic here
                print('Sign Up button pressed');
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
