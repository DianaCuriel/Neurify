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
    final idUsuario = prefs.getInt('id_credenciales'); // o 'id_usuario'
    final url = Uri.parse(
      'http://servidor-morales11.sytes.net:5050/CerrarSesion.php',
    );

    try {
      // Petición al servidor
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_usuario': idUsuario}),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        // Limpiar sesión local
        await prefs.clear();

        if (!mounted) return;
        // Redirigir al login
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión en el servidor')),
        );
      }
    } catch (e) {
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
      bottomNavigationBar: const MiBottomNav(),
    );
  }
}
