import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import '../visuales/login_screen.dart';
import '../Fijo/AppBar.dart';
import '../Fijo/BottomNavigator.dart';

// lib/visuales/cerrar_sesion.dart
class CerrarsesionPage extends StatefulWidget {
  const CerrarsesionPage({super.key});

  @override
  State<CerrarsesionPage> createState() => _CerrarsesionPageState();
}

class _CerrarsesionPageState extends State<CerrarsesionPage> {
  bool _cargando = false;

  Future<void> _logout() async {
    setState(() => _cargando = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in');
    await prefs.remove('usuario'); // opcional: o prefs.clear();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MiAppBar(title: "Cerrar sesión"),
      body: Center(
        child:
            _cargando
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text("Cerrar sesión"),
                ),
      ),
      bottomNavigationBar: const MiBottomNav(currentIndex: 3),
    );
  }
}
