import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'prefs_service.dart';
import 'login_screen.dart';
import 'teacher_classes_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});
  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  Map<String, dynamic> user = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    var session = await PrefsService.getUserSession();
    var doc = await FirebaseFirestore.instance.collection('users').doc(session['uid']).get();
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
        title: const Text('Teacher Panel'),
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
                subtitle: Text('ID: ${user['idNumber'] ?? ''}\nDept: ${user['dept'] ?? ''}\n${user['designation'] ?? ''}'),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              icon: const Icon(Icons.class_outlined),
              label: const Text('View Assigned Courses'),
              onPressed: () {
                if (user['uid'] != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => TeacherClassesScreen(teacherUid: user['uid'])));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}