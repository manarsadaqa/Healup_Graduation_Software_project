import 'package:flutter/material.dart';
import 'package:first/services/doctorService.dart';
import 'package:first/services/patientService.dart';
import 'package:first/services/chat_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'docChat.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DisplayPatDoc extends StatefulWidget {
  @override
  _DisplayPatDocState createState() => _DisplayPatDocState();
}

class _DisplayPatDocState extends State<DisplayPatDoc> with SingleTickerProviderStateMixin {
  final DoctorService _doctorService = DoctorService();
  final PatientService _patientService = PatientService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _doctorId;
  String? _patientId;
  List<Doctor> doctors = [];
  List<Patient> patients = [];
  bool isLoading = true;
  late TabController _tabController;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchData();
    _loadDoctorId();
    _loadPatientId();
  }

  Future<void> _loadDoctorId() async {
    String? id = await _storage.read(key: 'doctor_id');
    setState(() {
      _doctorId = id;
    });
  }

  Future<void> _loadPatientId() async {
    String? id = await _storage.read(key: 'patient_id');
    setState(() {
      _patientId = id;
    });
  }

  Future<void> fetchData() async {
    try {
      final fetchedDoctors = await _doctorService.getDoctors();
      final fetchedPatients = await _patientService.getPatients();
      setState(() {
        doctors = fetchedDoctors;
        patients = fetchedPatients;
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> getUnreadStatus(String senderId, String receiverId) async {
    final List<String> users = [senderId, receiverId];
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
      return messageData['isRead'] == false;  // Return unread status
    }
    return false;  // No messages, considered as read by default
  }

  Future<List<Doctor>> getSortedDoctors() async {
    List<Doctor> sortedDoctors = List.from(doctors);
    List<DoctorWithUnreadStatus> doctorStatuses = [];

    // Fetch the unread status for each doctor asynchronously
    for (var doctor in sortedDoctors) {
      bool unread = await getUnreadStatus(_doctorId!, doctor.id);
      doctorStatuses.add(DoctorWithUnreadStatus(doctor, unread));
    }

    // Sort doctors based on unread status
    doctorStatuses.sort((a, b) => b.unreadStatus ? 1 : 0 - (a.unreadStatus ? 1 : 0));

    // Convert back to sorted list of doctors
    return doctorStatuses.map((e) => e.doctor).toList();
  }

  Future<List<Patient>> getSortedPatients() async {
    List<Patient> sortedPatients = List.from(patients);
    List<PatientWithUnreadStatus> patientStatuses = [];

    // Fetch the unread status for each patient asynchronously
    for (var patient in sortedPatients) {
      bool unread = await getUnreadStatus(_doctorId!, patient.id);
      patientStatuses.add(PatientWithUnreadStatus(patient, unread));
    }

    // Sort patients based on unread status
    patientStatuses.sort((a, b) => b.unreadStatus ? 1 : 0 - (a.unreadStatus ? 1 : 0));

    // Convert back to sorted list of patients
    return patientStatuses.map((e) => e.patient).toList();
  }

  Future<Map<String, dynamic>> getLastMessage(String senderId, String receiverId) async {
    final List<String> users = [senderId, receiverId];
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
      return messageData; // Return entire message data
    } else {
      return {'message': 'No message yet', 'isRead': true};
    }
  }

  Future<void> markMessagesAsRead(String senderId, String receiverId) async {
    final List<String> users = [senderId, receiverId];
    users.sort();
    final String chatRoomID = users.join("_");

    final querySnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomID)
        .collection('messages')
        .where('receiverId', isEqualTo: _doctorId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'isRead': true});
    }

    setState(() {});
  }

  Widget buildDoctorTile(Doctor doctor) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getLastMessage(_doctorId!, doctor.id),
      builder: (context, snapshot) {
        String lastMessage = 'No message yet';
        bool isRead = true;

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            lastMessage = snapshot.data!['message'] ?? 'No message yet';
            isRead = snapshot.data!['isRead'] ?? true;
          }
        }

        return Card(
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Stack(
            children: [
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10), // Adjust padding for centering
                leading: CircleAvatar(
                  backgroundImage: doctor.photo.isNotEmpty
                      ? AssetImage(doctor.photo)
                      : null,
                  child: doctor.photo.isEmpty
                      ? Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Keep title left-aligned
                  children: [
                    Text(
                      doctor.name,
                      style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      doctor.specialization,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Last Message: $lastMessage',
                      style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
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
                  await markMessagesAsRead(_doctorId!, doctor.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => docChat(
                        senderId: _doctorId!,
                        receiverId: doctor.id,
                        receiverName: doctor.name,
                        receiverPhoto: doctor.photo,
                      ),
                    ),
                  );
                },
              ),
              if (!isRead) // Red dot if the message is unread
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget buildPatientTile(Patient patient) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getLastMessage(_doctorId!, patient.id),
      builder: (context, snapshot) {
        String lastMessage = 'No message yet';
        bool isRead = true;

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            lastMessage = snapshot.data!['message'] ?? 'No message yet';
            isRead = snapshot.data!['isRead'] ?? true;
          }
        }

        return Card(
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Stack(
            children: [
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10), // Adjust padding for centering
                leading: CircleAvatar(
                  backgroundImage: patient.pic.isNotEmpty
                      ? AssetImage(patient.pic)
                      : null,
                  child: patient.pic.isEmpty
                      ? Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Keep title left-aligned
                  children: [
                    Text(
                      patient.username,
                      style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Last Message: $lastMessage',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
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
                  await markMessagesAsRead(_doctorId!, patient.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => docChat(
                        senderId: _doctorId!,
                        receiverId: patient.id,
                        receiverName: patient.username,
                        receiverPhoto: patient.pic,
                      ),
                    ),
                  );
                },
              ),
              if (!isRead) // Red dot if the message is unread
                Positioned(
                  right: 180,
                  top: 22,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        backgroundColor: Color(0xff2f9a8f),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          labelStyle: TextStyle(fontSize: 20),
          unselectedLabelStyle: TextStyle(fontSize: 18),
          tabs: [
            Tab(text: "Doctors"),
            Tab(text: "Patients"),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/back.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onChanged: (query) {
                  setState(() {
                    searchQuery = query;
                  });
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  FutureBuilder<List<Doctor>>(
                    future: getSortedDoctors(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.hasData) {
                        final doctorsList = snapshot.data!
                            .where((doctor) =>
                            doctor.name.toLowerCase().contains(searchQuery.toLowerCase()))
                            .toList();

                        return ListView(
                          children: doctorsList.map(buildDoctorTile).toList(),
                        );
                      }

                      return Center(child: Text('No doctors found.'));
                    },
                  ),
                  FutureBuilder<List<Patient>>(
                    future: getSortedPatients(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.hasData) {
                        final patientsList = snapshot.data!
                            .where((patient) =>
                            patient.username.toLowerCase().contains(searchQuery.toLowerCase()))
                            .toList();

                        return ListView(
                          children: patientsList.map(buildPatientTile).toList(),
                        );
                      }

                      return Center(child: Text('No patients found.'));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorWithUnreadStatus {
  final Doctor doctor;
  final bool unreadStatus;

  DoctorWithUnreadStatus(this.doctor, this.unreadStatus);
}

class PatientWithUnreadStatus {
  final Patient patient;
  final bool unreadStatus;

  PatientWithUnreadStatus(this.patient, this.unreadStatus);
}
