import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static Future<void> saveUserSession({required String uid, required String role, required String name, required String id}) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('login', true);
    await p.setString('role', role);
    await p.setString('uid', uid);
    await p.setString('name', name);
    await p.setString('id', id);
  }

  static Future<bool> isLoggedIn() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('login') ?? false;
  }

  static Future<String> getUserRole() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('role') ?? '';
  }

  static Future<Map<String, dynamic>> getUserSession() async {
    final p = await SharedPreferences.getInstance();
    return {
      'uid': p.getString('uid') ?? '',
      'role': p.getString('role') ?? '',
      'name': p.getString('name') ?? '',
      'id': p.getString('id') ?? '',
    };
  }

  static Future<void> clearSession() async {
    final p = await SharedPreferences.getInstance();
    await p.clear();
  }
}