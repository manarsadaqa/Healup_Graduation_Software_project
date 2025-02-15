import 'dart:convert';
import 'package:http/http.dart' as http;

class DoctorService {

  Future<List<Doctor>> getDoctors() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/healup/doctors/doctors'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Doctor.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch doctors');
    }
  }
}

class Doctor {
  final String id;
  final String name;
  final String photo;
  final String specialization;


  Doctor({required this.id,required this.name, required this.photo, required this.specialization});

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id:json['_id'],
      name: json['name'],
      photo: json['photo'],
      specialization: json['specialization'],
    );
  }
}
