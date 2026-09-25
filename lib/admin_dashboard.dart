import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'prefs_service.dart';
import 'login_screen.dart';
import 'manage_teachers_screen.dart';
import 'manage_students_screen.dart';
import 'manage_subjects_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String name = 'Admin';
  String uid = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    var data = await PrefsService.getUserSession();
    setState(() {
      name = data['name'] ?? 'Admin';
      uid = data['uid'] ?? '';
    });
  }

  void logout() async {
    await AuthService().logout();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginScreen()), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: const Color(0xFF4E342E),
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: logout)],
      ),
      body: Column(
        children: [
          ListTile(
            tileColor: Colors.white,
            title: Text('Welcome, $name', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('2023 Batch Management'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Manage Teachers'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ManageTeachersScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Manage Students'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ManageStudentsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Manage Subjects'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ManageSubjectsScreen())),
          ),
        ],
      ),
    );
  }
}