import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
class ResetPasswordPage extends StatefulWidget {
  final String token;

  ResetPasswordPage({required this.token});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      String newPassword = _newPasswordController.text;

      try {
        final response = await http.patch(
          Uri.parse('http://10.0.2.2:5000/api/healup/patients/resetPassword/${widget.token}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'password': newPassword}),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          _showSuccessDialog(responseData['message'] ?? 'Password reset successful.');
        } else {
          final responseData = json.decode(response.body);
          _showErrorDialog(responseData['message'] ?? 'Failed to reset password.');
        }
      } catch (e) {
        _showErrorDialog('An error occurred. Please try again later.');
      }
    }
  }

  // Error and Success dialogs can be reused from your existing code
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your new password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _resetPassword,
                child: Text('Reset Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
