// lib/services/user_preferences.dart
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', user['id'] as int);
    await prefs.setString('fullName', user['full_name'] as String);
    await prefs.setString('username', user['username'] as String);
  }

  static Future<Map<String, dynamic>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final fullName = prefs.getString('fullName');
    final username = prefs.getString('username');

    return {
      'id': userId,
      'fullName': fullName,
      'username': username,
    };
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('fullName');
    await prefs.remove('username');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('userId');
  }
}
