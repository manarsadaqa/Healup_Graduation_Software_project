import 'dart:convert';
import 'package:http/http.dart' as http;



class PatientService {
  Future<List<Patient>> getPatients({int page = 1, int limit = 10}) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/healup/patients/'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return (data['data'] as List).map((json) => Patient.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch patients');
    }
  }
}

class Patient {
  final String id;
  final String username;
  final String email;
  final String pic;

  Patient({required this.id, required this.username, required this.email,required this.pic});

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      pic:json['pic'],
    );
  }
}
