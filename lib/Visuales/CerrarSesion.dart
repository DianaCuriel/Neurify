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
      print("🚀 Intentando cerrar sesión para id_usuario: $idUsuario");
      print("📡 URL: $url");

      final body = jsonEncode({'id_usuario': idUsuario});
      print("📦 Body enviado: $body");

      // Petición al servidor
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print("📶 Código de respuesta: ${response.statusCode}");
      print("📄 Body de respuesta: ${response.body}");

      final data = jsonDecode(response.body);
      print("📝 Data decodificada: $data");

      if (data['success'] == true) {
        // Limpiar sesión local
        await prefs.clear();

        if (!mounted) return;
        // Redirigir al login
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        print("⚠️ Error en el servidor: ${data['mensaje']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión en el servidor')),
        );
      }
    } catch (e, stack) {
      print("❌ Excepción al cerrar sesión: $e");
      print(stack);
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
      bottomNavigationBar: const MiBottomNav(
        currentIndex: 3, // aquí el índice de Estadísticas
      ),
    );
  }
}
