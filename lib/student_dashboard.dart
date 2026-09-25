import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'prefs_service.dart';
import 'login_screen.dart';
import 'qr_scanner_screen.dart';
import 'student_history_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  Map<String, dynamic> user = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    var session = await PrefsService.getUserSession();
    var doc = await FirebaseFirestore.instance.collection('students').doc(session['uid']).get();
    if (doc.exists) {
      setState(() {
        user = doc.data() as Map<String, dynamic>;
        user['uid'] = session['uid'];
      });
    }
  }

  void logout() async {
    await AuthService().logout();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginScreen()), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Panel'),
        backgroundColor: const Color(0xFF4E342E),
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: logout)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(user['name'] ?? 'Loading...'),
                subtitle: Text('ID: ${user['studentId'] ?? ''}\nDept: ${user['dept'] ?? ''}'),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Open Scanner'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => QrScannerScreen(studentUid: user['uid'])));
              },
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
              icon: const Icon(Icons.history),
              label: const Text('View History'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => StudentHistoryScreen(studentUid: user['uid'])));
              },
            ),
          ],
        ),
      ),
    );
  }
}