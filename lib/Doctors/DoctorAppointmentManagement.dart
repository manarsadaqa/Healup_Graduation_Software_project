import 'package:flutter/material.dart';

class AppointmentManagementPage extends StatelessWidget {
  final List<String> pendingRequests = ["Patient A", "Patient B"];
  final List<String> confirmedAppointments = ["Patient C", "Patient D"];
  final List<String> pastAppointments = ["Patient E", "Patient F"];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Appointment Requests",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...pendingRequests.map((name) => Card(
              child: ListTile(
                title: Text(name),
                subtitle: Text("Pending Approval"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check, color: Colors.green),
                      onPressed: () {}, // Handle Accept
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () {}, // Handle Reject
                    ),
                  ],
                ),
              ),
            )),
            Divider(height: 32),
            Text(
              "Confirmed Appointments",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...confirmedAppointments.map((name) => Card(
              child: ListTile(
                title: Text(name),
                subtitle: Text("Confirmed"),
              ),
            )),
            Divider(height: 32),
            Text(
              "Past Appointments",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...pastAppointments.map((name) => Card(
              child: ListTile(
                title: Text(name),
                subtitle: Text("Completed"),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
