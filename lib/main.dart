import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'package:neurify/Calendario.dart';
// import 'home_page.dart';
import 'Fijo/app_theme.dart';
=======
import 'package:shared_preferences/shared_preferences.dart';
import 'fijo/app_theme.dart';
import 'visuales/login_page.dart';
import 'visuales/calendario_page.dart';
>>>>>>> Stashed changes

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
<<<<<<< Updated upstream
      title: "Mi App",
      theme: AppTheme.themeData, // 🌟 aquí aplicamos el tema
      home: const CalendarioPage(),
=======
      title: "Neurify App",
      theme: AppTheme.themeData,
      home: const AuthWrapper(),
>>>>>>> Stashed changes
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    setState(() {
      _isLoggedIn = isLoggedIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _isLoggedIn ? const CalendarioPage() : const LoginPage();
  }
}
