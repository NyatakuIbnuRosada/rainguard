import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static int? userId;
  static String? username;

  static Future<void> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getInt('user_id');
      username = prefs.getString('username');
    } catch (e) {
      print('LOAD SESSION ERROR: $e');
      userId = null;
      username = null;
    }
  }

  static Future<void> saveSession(int id, String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', id);
      await prefs.setString('username', name);
      userId = id;
      username = name;
    } catch (e) {
      print('SAVE SESSION ERROR: $e');
    }
  }

  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('username');
    } catch (e) {
      print('LOGOUT ERROR: $e');
    }

    userId = null;
    username = null;
  }
}
