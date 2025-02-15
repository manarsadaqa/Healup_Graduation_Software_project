import 'package:flutter/material.dart';
import 'package:first/services/chat_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io'; // Import for the File class
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String doctorPhoto;

  ChatPage({
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorPhoto,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead(); // Mark messages as read when the chat is opened
  }

  Future<void> _pickFile() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose an option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _pickImage(ImageSource.gallery),
                child: Row(
                  children: [
                    Icon(Icons.photo),
                    SizedBox(width: 8),
                    Text('Gallery'),
                  ],
                ),
              ),
              SizedBox(height: 16),
              InkWell(
                onTap: () => _pickImage(ImageSource.camera),
                child: Row(
                  children: [
                    Icon(Icons.camera_alt),
                    SizedBox(width: 8),
                    Text('Camera'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // Close the dialog
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      String filePath = image.path;
      String fileName = image.name;

      try {
        // Upload the file to Firebase Storage
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('chat_files/${widget.patientId}/${DateTime.now().millisecondsSinceEpoch}_$fileName');

        final UploadTask uploadTask = storageRef.putFile(File(filePath));

        // Wait for the upload to complete and get the download URL
        final TaskSnapshot snapshot = await uploadTask;
        final String downloadUrl = await snapshot.ref.getDownloadURL();

        // Send the file as a chat message with the download URL
        _chatService.sendMessage(
          senderId: widget.patientId,
          receiverId: widget.doctorId,
          message: 'Image: $fileName', // Optional: Include file name
          fileUrl: downloadUrl, // Include the file's URL
          isRead: false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image uploaded successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected')),
      );
    }
  }

  Future<void> _markMessagesAsRead() async {
    final List<String> users = [widget.patientId, widget.doctorId];
    users.sort();
    final String chatRoomID = users.join("_");

    final unreadMessages = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomID)
        .collection('messages')
        .where('receiverId', isEqualTo: widget.patientId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in unreadMessages.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  void _sendMessage(String message, {String? fileUrl}) {
    if (message.isNotEmpty || fileUrl != null) {
      _chatService.sendMessage(
        senderId: widget.patientId,
        receiverId: widget.doctorId,
        message: message,
        fileUrl: fileUrl,
        isRead: false,
      );
      _messageController.clear();
    }
  }

  Stream<List<Map<String, dynamic>>> _getMessages() {
    final List<String> users = [widget.patientId, widget.doctorId];
    users.sort();
    final String chatRoomID = users.join("_");

    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'messageId': doc.id,
          'message': data['message'] ?? '',
          'fileUrl': data['fileUrl'],
          'senderId': data['senderId'],
          'timestamp': data['timestamp'],
          'isRead': data['isRead'] ?? true,
          'status': data['status'] ?? 'sent',
        };
      }).toList();
    });
  }

  Future<Map<String, dynamic>> _getLastMessage() async {
    final List<String> users = [widget.patientId, widget.doctorId];
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
      final data = querySnapshot.docs.first.data();
      return {
        'message': data['message'] ?? '',
        'isRead': data['isRead'] ?? true,
      };
    } else {
      return {'message': 'No message yet', 'isRead': true};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(widget.doctorPhoto),
              radius: 20,
            ),
            SizedBox(width: 10),
            Text('${widget.doctorName}'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/chatBack.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getMessages(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No messages yet.'));
                  } else {
                    final messages = snapshot.data!;
                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isSender = message['senderId'] == widget.patientId;

                        return ListTile(
                          title: Align(
                            alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment:
                              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSender ? Color(0xff2f9a8f) : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: message['fileUrl'] != null
                                      ? GestureDetector(
                                    onTap: () => launch(message['fileUrl']),
                                    child: Text(
                                      'View File',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  )
                                      : Text(
                                    message['message'],
                                    style: TextStyle(
                                      color: isSender ? Colors.white : Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                if (!isSender)
                                  Text(
                                    message['isRead'] ? 'Read' : 'Unread',
                                    style: TextStyle(
                                      color: message['isRead'] ? Colors.grey : Colors.red,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.attach_file),
                    onPressed: _pickFile,
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () => _sendMessage(_messageController.text),
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
