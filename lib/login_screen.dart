import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'helpers.dart';
import 'student_dashboard.dart';
import 'teacher_dashboard.dart';
import 'admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final idController = TextEditingController();
  final passwordController = TextEditingController();
  bool hide = true;

  void login() async {
    String email = idController.text.trim();
    if (email.contains('@') == false) {
      email = '$email@student.qrattendance.app';
    }

    try {
      var user = await AuthService().login(email, passwordController.text);
      String role = user['role'];

      Widget nextScreen = const StudentDashboard();
      if (role == 'admin') {
        nextScreen = const AdminDashboard();
      } else if (role == 'teacher') {
        nextScreen = const TeacherDashboard();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    } catch (e) {
      UIHelpers.showSnackBar(context, 'Login Failed: Check ID/Password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB08D57),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner, size: 60, color: Colors.white),
            const Text(
              'Attendance App',
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: idController,
              decoration: const InputDecoration(hintText: 'ID', fillColor: Colors.white, filled: true),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: hide,
              decoration: const InputDecoration(hintText: 'Password', fillColor: Colors.white, filled: true),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: login, child: const Text('SIGN IN')),
            ),
          ],
        ),
      ),
    );
  }
}