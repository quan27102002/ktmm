import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SendStringToFirebase extends StatefulWidget {
  const SendStringToFirebase({super.key});

  @override
  _SendStringToFirebaseState createState() => _SendStringToFirebaseState();
}

class _SendStringToFirebaseState extends State<SendStringToFirebase> {
  final TextEditingController _controller = TextEditingController();
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  Future<void> _sendStringToRealtimeDatabase(String inputString) async {
    try {
      await _databaseReference.child('user').set({'pass': inputString});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('String sent to Firebase!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending string: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send String to Firebase'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter a string',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  _sendStringToRealtimeDatabase(_controller.text);
                }
              },
              child: Text('Send to Firebase'),
            ),
          ],
        ),
      ),
    );
  }
}
