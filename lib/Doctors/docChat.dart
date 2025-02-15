import 'package:flutter/material.dart';
import 'package:first/services/chat_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io'; // Import for the File class
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class docChat extends StatefulWidget {
  final String senderId;
  final String receiverId;
  final String receiverName;
  final String receiverPhoto;

  docChat({
    required this.senderId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverPhoto,
  });

  @override
  _docChatState createState() => _docChatState();
}

class _docChatState extends State<docChat> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final ImagePicker _imagePicker = ImagePicker();

  // Function to pick an image
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _uploadFile(File(pickedFile.path), 'image');
    }
  }

  // Function to pick a file
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      _uploadFile(file, 'file');
    }
  }

  // Upload selected file to Firebase Storage
  Future<void> _uploadFile(File file, String type) async {
    try {
      // Generate a unique file name based on timestamp
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Define file path in Firebase Storage
      Reference storageRef = FirebaseStorage.instance.ref().child('chats/$fileName');

      // Upload file to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

      // Get the file URL after the upload
      String fileUrl = await snapshot.ref.getDownloadURL();

      // Send message with the file URL
      _sendMessage('Sent a $type', fileUrl: fileUrl);
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  // Sending a message
  void _sendMessage(String message, {String? fileUrl}) {
    if (message.isNotEmpty || fileUrl != null) {
      _chatService.sendMessage(
        senderId: widget.senderId,
        receiverId: widget.receiverId,
        message: message,
        fileUrl: fileUrl,
      );
      _messageController.clear();
    }
  }

  // Stream for fetching messages
  Stream<List<Map<String, dynamic>>> _getMessages() {
    final List<String> users = [widget.senderId, widget.receiverId];
    users.sort();
    final String chatRoomID = users.join("_");

    return _chatService.getMessages(chatRoomID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.receiverPhoto.isNotEmpty
                  ? AssetImage(widget.receiverPhoto)
                  : null,
              child: widget.receiverPhoto.isEmpty
                  ? Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 10),
            Text('${widget.receiverName}'),
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
                        final isSender = message['senderId'] == widget.senderId;

                        return ListTile(
                          title: Align(
                            alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSender ? Color(0xff2f9a8f) : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: message['fileUrl'] != null
                                      ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message['message'],
                                        style: TextStyle(
                                          color: isSender ? Colors.white : Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () {
                                          launch(message['fileUrl']);
                                        },
                                        child: Text(
                                          'View File',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                      : Text(
                                    message['message'],
                                    style: TextStyle(
                                      color: isSender ? Colors.white : Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  message['status'] ?? 'sent',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
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
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.attach_file),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.image),
                                      title: Text('Pick Image'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _pickImage();
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.insert_drive_file),
                                      title: Text('Pick File'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _pickFile();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      _sendMessage(_messageController.text.trim());
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

