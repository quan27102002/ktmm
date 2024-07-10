import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SendStringToFirebase extends StatefulWidget {
  const SendStringToFirebase({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SendStringToFirebaseState createState() => _SendStringToFirebaseState();
}

class _SendStringToFirebaseState extends State<SendStringToFirebase> {
  final TextEditingController _controller = TextEditingController();
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  DatabaseReference status =
      FirebaseDatabase.instance.ref('/user').child('status');
  Future<void> _sendStringToRealtimeDatabase(String inputString) async {
    try {
      await _databaseReference.child('user').set({'pass': inputString});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  String statusString = "Đang cập nhật";
  void _initData() {
    status.onValue.listen((event) {
      var data = event.snapshot.value;
      setState(() {
        var statusInt = int.parse(data.toString());
        if (statusInt == 0) {
          statusString = "mở";
        }
        if (statusInt == 1) {
          statusString = "đóng";
        }
      });
    });
  }

  @override
  void initState() {
    _initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý cửa ra vào'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Text(
                "Trạng thái cửa ra vào: $statusString",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Nhập mật khẩu mới',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  _sendStringToRealtimeDatabase(_controller.text);
                }
              },
              child: const Text('Cập nhật mật khẩu'),
            ),
          ],
        ),
      ),
    );
  }
}
