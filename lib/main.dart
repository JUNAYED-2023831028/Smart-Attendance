import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_screen.dart';
import 'admin_dashboard.dart';
import 'teacher_dashboard.dart';
import 'student_dashboard.dart';
import 'prefs_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);

  Widget screen = const LoginScreen();
  bool isLoggedIn = await PrefsService.isLoggedIn();

  if (isLoggedIn == true) {
    String role = await PrefsService.getUserRole();
    if (role == 'admin') {
      screen = const AdminDashboard();
    } else if (role == 'teacher') {
      screen = const TeacherDashboard();
    } else if (role == 'student') {
      screen = const StudentDashboard();
    }
  }

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: screen,
  ));
}