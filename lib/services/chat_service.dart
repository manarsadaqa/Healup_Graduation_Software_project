import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  // Example method to send a message
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
    String? fileUrl, // Optional file URL
    bool isRead = false, // Default value set to false
  }) async {
    final List<String> users = [senderId, receiverId];
    users.sort(); // Ensure consistent chat room ID
    final String chatRoomID = users.join("_");

    final String messageId = FirebaseFirestore.instance.collection('chats').doc().id; // Generate a unique ID

    final Map<String, dynamic> chatMessage = {
      'messageId': messageId, // Add unique message ID
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'fileUrl': fileUrl, // Include file URL if provided
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'sent', // Initial status of the message
      'isRead': isRead, // Set the isRead field
    };

    // Save the message to Firestore
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomID)
        .collection('messages')
        .add(chatMessage);
  }


  Future<void> updateMessageStatus(String chatRoomID, String messageId, String status) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomID)
        .collection('messages')
        .doc(messageId)
        .update({'status': status});
  }

  Future<void> markMessageAsRead(String chatRoomID, String messageId) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomID)
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true}); // Mark message as read
  }


  Future<void> deleteMessage(String chatRoomID, String messageId) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomID)
        .collection('messages')
        .doc(messageId)
        .delete();
  }


  // Example method to get messages stream
  Stream<List<Map<String, dynamic>>> getMessages(String chatRoomID) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList());
  }

}
