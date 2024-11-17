import 'package:flutter/material.dart';
// For converting JSON data

class DiagnosisChat extends StatefulWidget {
  const DiagnosisChat({super.key});

  @override
  _DiagnosisChatState createState() => _DiagnosisChatState();
}

class _DiagnosisChatState extends State<DiagnosisChat> {
  final TextEditingController _controller = TextEditingController();
  List<String> messages = [];
  String? diagnosis;
  String? recommendations;

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    String userMessage = _controller.text;
    setState(() {
      messages.add('User: $userMessage');
    });
    _controller.clear();

    // Simulate API call
    await _getDiagnosis(userMessage);
  }

  Future<void> _getDiagnosis(String symptoms) async {
    // Simulated response, replace with actual API call
    await Future.delayed(
        const Duration(seconds: 1)); // Simulating network delay

    // Here you can implement your AI API call to get the diagnosis.
    // For now, we will just use a placeholder response
    setState(() {
      diagnosis = 'You might have a common cold.';
      recommendations =
          'Consult a general practitioner or consider OTC medications.';
      messages.add('AI: $diagnosis');
      messages.add('AI: Recommendations: $recommendations');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Diagnosis Chat'),
        backgroundColor: const Color(0xff6be4d7),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    messages[index],
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Describe your symptoms...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
