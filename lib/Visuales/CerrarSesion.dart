import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Fijo/AppBar.dart';
import '../Fijo/BottomNavigator.dart';

class CerrarsesionPage extends StatefulWidget {
  const CerrarsesionPage({super.key});

  @override
  _CerrarsesionPageState createState() => _CerrarsesionPageState();
}

class _CerrarsesionPageState extends State<CerrarsesionPage> {
  bool _cargando = false;
  Future<void> _cerrarSesion() async {
    setState(() => _cargando = true);

    final prefs = await SharedPreferences.getInstance();
    final usuario = prefs.getString('usuario'); // guardado en login

    final url = Uri.parse(
      'http://servidor-morales11.sytes.net:5050/CerrarSesion.php',
    );

    try {
      print('🚀 Intentando cerrar sesión para usuario: $usuario');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'id_usuario': usuario}),
      );

      print('📦 Body enviado: {"id_usuario": "$usuario"}');
      print('📡 HTTP: ${response.statusCode}');
      print('📤 Respuesta: ${response.body}');

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        await prefs.clear();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['mensaje'] ?? 'Error al cerrar sesión')),
        );
      }
    } catch (e) {
      print('❌ Excepción al cerrar sesión: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión con el servidor')),
      );
    } finally {
      setState(() => _cargando = false);
    }
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
                  onPressed: _cerrarSesion,
                  icon: const Icon(Icons.logout),
                  label: const Text("Cerrar sesión"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
      ),
      bottomNavigationBar: const MiBottomNav(currentIndex: 3),
    );
  }
}
