import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart'; // Import uuid package for generating sessionId

class ChatBot extends StatefulWidget {
  final String patientId; // Accepts patientId as a parameter

  ChatBot({required this.patientId});

  @override
  _ChatBotState createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  String sessionId = ""; // To hold the sessionId
  String username = ""; // Will hold the fetched username
  String medical_history = ""; // Will hold the fetched medical history
  String symptoms = ""; // To store symptoms
  String historyOfPresentIllness = ""; // To store history of present illness
  String currentStep = "symptoms"; // Tracks the current step in the conversation

  @override
  void initState() {
    super.initState();
    _initializeSession(); // Initialize the sessionId and fetch username during initialization
  }

  Future<void> _initializeSession() async {
    // Generate sessionId if not set
    if (sessionId.isEmpty) {
      sessionId = Uuid().v4(); // Generate a new session ID using uuid package
    }
    await _fetchUsername(); // Fetch the username after session is initialized
  }

  Future<void> _fetchUsername() async {
    final apiUrl = "http://localhost:5000/api/healup/patients/getPatientById/${widget
        .patientId}";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        medical_history = data["medical_history"];
        if (data.containsKey("username")) {
          setState(() {
            username = data["username"];
          });

          // Add a personalized greeting message after fetching the username
          _messages.add({
            "sender": "bot",
            "text": "Hello $username! Let’s get started. Could you please tell me about your symptoms?"
          });
        }
      } else {
        setState(() {
          username = "User"; // Default to "User" if fetching fails
        });
        _messages.add({
          "sender": "bot",
          "text": "Hello! Let’s get started. Could you please tell me about your symptoms?"
        });
      }
    } catch (error) {
      print("Error fetching username: $error");
      setState(() {
        username = "User";
      });
      _messages.add({
        "sender": "bot",
        "text": "Hello! Let’s get started. Could you please tell me about your symptoms?"
      });
    }
  }

  Future<void> sendMessage(String message) async {
    if (message
        .trim()
        .isEmpty) return;

    // Add user message to the chat
    setState(() {
      _messages.add({"sender": "user", "text": message});
    });

    if (currentStep == "symptoms") {
      symptoms = message; // Store the symptoms
      _askNext("historyOfPresentIllness");
    } else if (currentStep == "historyOfPresentIllness") {
      historyOfPresentIllness = message; // Store history of present illness
      _processAndRecommend();
    } else if (currentStep == "followUp") {
      // Handle user's response to the follow-up question
      if (message.toLowerCase() == "yes") {
        _restartConversation();
      } else if (message.toLowerCase() == "no") {
        setState(() {
          _messages.add({
            "sender": "bot",
            "text": "Alright, feel free to reach out anytime. Take care!"
          });
        });
      } else {
        setState(() {
          _messages.add({
            "sender": "bot",
            "text": "I didn't quite catch that. Please respond with 'yes' or 'no'."
          });
        });
      }
    }
  }

  void _restartConversation() {
    setState(() {
      // Clear stored input data
      symptoms = "";
      historyOfPresentIllness = "";
      currentStep = "symptoms"; // Reset to the initial step

      // Add the bot's message to start over
      _messages.add({
        "sender": "bot",
        "text": "Great! Let's start over. Could you please tell me about your symptoms?"
      });
    });
  }


  void _askNext(String nextStep) {
    setState(() {
      if (nextStep == "historyOfPresentIllness") {
        _messages.add({
          "sender": "bot",
          "text": "Thank you. Since when have you been feeling this way?"
        });
      }
      currentStep = nextStep;
    });
  }

  Future<void> _processAndRecommend() async {
    setState(() {
      _messages.add({
        "sender": "bot",
        "text": "Thank you for providing the details. Let me process this information and recommend a specialist."
      });
    });

    const apiUrl = "http://localhost:5000/api/healup/Symptoms/recommend-doctor";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": symptoms,
          "historyOfPresentIllness": historyOfPresentIllness,
          "patientId": widget.patientId,
          // Use the patientId passed to the widget
          "sessionId": sessionId,
          // Pass the sessionId with the request
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Update sessionId if provided
        if (data.containsKey("sessionId")) {
          sessionId = data["sessionId"];
        }

        if (data.containsKey("condition")) {
          setState(() {
            // Message 1: Informing about the condition
            _messages.add({
              "sender": "bot",
              "text": "Based on your symptoms, and your medical history which is $medical_history,I recommend you consult a ${data['recommendedSpecialist']}Specialist"
            });

            // Message 3: Prompting for additional input
            _messages.add({
              "sender": "bot",
              "text": "Would you like to provide more symptoms or discuss another issue?"
            });

            currentStep = "followUp"; // Set step to follow-up
          });
        }
      } else {
        setState(() {
          _messages.add({
            "sender": "bot",
            "text": "An error occurred while processing your information. Please try again later.",
          });
        });
      }
    } catch (error) {
      print("Error calling API: $error");
      setState(() {
        _messages.add({
          "sender": "bot",
          "text": "Unable to connect to the server. Please check your internet connection.",
        });
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Symptom Chatbot'),
        backgroundColor: Color(0xff6be4d7), // Set the AppBar background color
      ),
      body: Stack(
        children: [
          // Background image with opacity
          Opacity(
            opacity: 0.5, // Adjust the opacity (0.0 to 1.0)
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/back.jpg"), // Path to the background image
                  fit: BoxFit.cover, // Ensures the image covers the entire screen
                ),
              ),
            ),
          ),
          // Chat content on top
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isUserMessage = message["sender"] == "user";

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isUserMessage ? Color(0xff2f9a8f) : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          message["text"] ?? "",
                          style: TextStyle(color: isUserMessage ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Divider(height: 1),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                color: Colors.white.withOpacity(0.8), // Slightly transparent background for the input field
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration.collapsed(
                          hintText: "Type your response here...",
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () => sendMessage(_messageController.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


}
