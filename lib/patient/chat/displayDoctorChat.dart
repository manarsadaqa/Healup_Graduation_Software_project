import 'package:flutter/material.dart';
import 'package:first/services/doctorService.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'chatPage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first/services/chat_service.dart';

class DoctorsPage extends StatefulWidget {
  @override
  _DoctorsPageState createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  late Future<List<Doctor>> _doctors;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _patientId;
  TextEditingController _searchController = TextEditingController();
  List<Doctor> _filteredDoctors = [];
  List<Doctor> _allDoctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _doctors = DoctorService().getDoctors();
    _loadPatientId();
    _searchController.addListener(_filterDoctors);
  }

  Future<void> _markMessagesAsRead(String doctorId) async {
    final List<String> users = [_patientId!, doctorId];
    users.sort();
    final String chatRoomID = users.join("_");

    final querySnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomID)
        .collection('messages')
        .where('receiverId', isEqualTo: _patientId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'isRead': true});
    }

    setState(() {
      _doctors = DoctorService().getDoctors(); // Refresh the list of doctors
    });
  }

  Future<void> _loadPatientId() async {
    String? id = await _storage.read(key: 'patient_id');
    setState(() {
      _patientId = id;
    });
  }

  void _filterDoctors() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDoctors = _allDoctors
          .where((doctor) =>
      doctor.name.toLowerCase().contains(query) ||
          doctor.specialization.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<Map<String, dynamic>> getLastMessage(String doctorId) async {
    final List<String> users = [_patientId!, doctorId];
    users.sort();
    final String chatRoomID = users.join("_");

    final querySnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final messageData = querySnapshot.docs.first.data();
      return messageData;
    } else {
      return {'message': 'No message yet', 'isRead': true};
    }
  }

  Future<bool> _hasUnreadMessages(String doctorId) async {
    final List<String> users = [_patientId!, doctorId];
    users.sort();
    final String chatRoomID = users.join("_");

    final querySnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomID)
        .collection('messages')
        .where('receiverId', isEqualTo: _patientId)
        .where('isRead', isEqualTo: false)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<List<Doctor>> _sortDoctorsByUnreadMessages(List<Doctor> doctors) async {
    List<Doctor> doctorsWithUnreadMessages = [];
    List<Doctor> doctorsWithoutUnreadMessages = [];

    for (var doctor in doctors) {
      bool hasUnread = await _hasUnreadMessages(doctor.id);
      if (hasUnread) {
        doctorsWithUnreadMessages.add(doctor);
      } else {
        doctorsWithoutUnreadMessages.add(doctor);
      }
    }

    return doctorsWithUnreadMessages + doctorsWithoutUnreadMessages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        centerTitle: true,
        backgroundColor: Colors.tealAccent[200],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _doctors = DoctorService().getDoctors();
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/pat.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Color(0xff2f9a8f)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white70,
                  hintText: 'Enter doctor\'s name or specialization',
                  hintStyle: TextStyle(
                    color: _searchController.text.isEmpty
                        ? Colors.grey
                        : Color(0xff2f9a8f),
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Doctor>>(
                future: _doctors,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No doctors found.'));
                  }

                  if (_allDoctors.isEmpty) {
                    _allDoctors = snapshot.data!;
                    _filteredDoctors = _allDoctors;
                  }

                  return FutureBuilder<List<Doctor>>(
                    future: _sortDoctorsByUnreadMessages(_filteredDoctors),
                    builder: (context, sortedSnapshot) {
                      if (sortedSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (sortedSnapshot.hasError) {
                        return Center(child: Text('Error: ${sortedSnapshot.error}'));
                      } else if (!sortedSnapshot.hasData || sortedSnapshot.data!.isEmpty) {
                        return Center(child: Text('No doctors found.'));
                      }

                      final doctors = sortedSnapshot.data!;

                      return ListView.builder(
                        padding: EdgeInsets.all(10),
                        itemCount: doctors.length,
                        itemBuilder: (context, index) {
                          final doctor = doctors[index];
                          return FutureBuilder<Map<String, dynamic>>(
                            future: getLastMessage(doctor.id),
                            builder: (context, messageSnapshot) {
                              String lastMessage = 'No message yet';
                              bool isRead = true;

                              if (messageSnapshot.connectionState == ConnectionState.done) {
                                if (messageSnapshot.hasData) {
                                  lastMessage = messageSnapshot.data!['message'] ?? 'No message yet';
                                  isRead = messageSnapshot.data!['isRead'] ?? true;
                                }
                              }

                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(15),
                                  leading: CircleAvatar(
                                    backgroundImage: AssetImage(doctor.photo),
                                    radius: 30,
                                  ),
                                  title: Row(
                                    children: [
                                      Text(
                                        doctor.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (!isRead)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: CircleAvatar(
                                            radius: 5,
                                            backgroundColor: Colors.red,
                                          ),
                                        ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(doctor.specialization),
                                      Text(
                                        lastMessage,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black45,
                                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 18.0),  // Add space to the left of the icon
                                        child: Icon(FontAwesomeIcons.comments, color: Color(0xff2f9a8f)),
                                      ),
                                    ],
                                  ),


                                  onTap: () async {
                                    // Mark messages as read when the doctor is tapped
                                    await _markMessagesAsRead(doctor.id);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatPage(
                                          doctorId: doctor.id,
                                          doctorName: doctor.name,
                                          doctorPhoto: doctor.photo,
                                          patientId: _patientId!,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
