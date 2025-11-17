import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'calendario.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<bool>? _future;

  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('logged_in') == true;
  }

  @override
  void initState() {
    super.initState();
    _future = _isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _future,
      builder: (context, snap) {
        if (!snap.hasData) {
          // Splash sencillito mientras leemos prefs
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final logged = snap.data!;
        return logged ? const CalendarioPage() : const LoginScreen();
      },
    );
  }
}
