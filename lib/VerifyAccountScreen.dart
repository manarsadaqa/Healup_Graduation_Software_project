import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For parsing the JSON response
import 'package:awesome_dialog/awesome_dialog.dart';
import 'PatientPage.dart';



class VerifyEmailPage extends StatefulWidget {
  final String email;

  const VerifyEmailPage({Key? key, required this.email}) : super(key: key);

  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isChecking = false;
  bool isVerified = false;

  Future<void> checkVerification() async {
    setState(() => isChecking = true);

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/healup/patients/${widget.email}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['isVerified'] == true) {
          setState(() => isVerified = true);
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            title: 'Verified',
            desc: 'Your email has been verified. You can now log in.',
            btnOkOnPress: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PatientPage()),
              );
            },
          ).show();
        } else {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.warning,
            title: 'Not Verified',
            desc: 'Your email has not been verified yet. Please check your email.',
            btnOkOnPress: () {},
          ).show();
        }
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Error',
          desc: 'Could not fetch verification status. Try again later.',
          btnOkOnPress: () {},
        ).show();
      }
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Error',
        desc: 'Could not connect to the server.',
        btnOkOnPress: () {},
      ).show();
    } finally {
      setState(() => isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: const Color(0xff2f9a8f),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'We have sent a verification email to ${widget.email}. Please verify your email to proceed.',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2f9a8f),
              ),
              onPressed: isChecking ? null : checkVerification,
              child: isChecking
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Check Verification'),
            ),
          ],
        ),
      ),
    );
  }
}
