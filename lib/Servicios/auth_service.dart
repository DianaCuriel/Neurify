import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _demoUser = 'isaac';
  static const String _demoPass = '1234';

  static Future<bool> login(String username, String password) async {
    if (username == _demoUser && password == _demoPass) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      return true;
    }
    return false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
