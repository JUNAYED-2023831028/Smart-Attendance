import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'prefs_service.dart';

class AuthService {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> login(String email, String password) async {
    var result = await auth.signInWithEmailAndPassword(
      email: email.trim(), 
      password: password.trim()
    );
    
    var doc = await firestore.collection('users').doc(result.user!.uid).get();
    var data = doc.data() as Map<String, dynamic>;

    await PrefsService.saveUserSession(
      uid: result.user!.uid,
      role: data['role'],
      name: data['name'],
      id: data['idNumber'],
    );

    return data;
  }

  Future<void> logout() async {
    await auth.signOut();
    await PrefsService.clearSession();
  }
}