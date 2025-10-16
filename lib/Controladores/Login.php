<!-- import 'dart:convert';
import 'package:http/http.dart' as http; // libreria para hacer peticiones http

class ConexionBD {
  final String url_login =
      "https://1606-2806-102e-7-33a4-4cee-b0b2-baab-9b0f.ngrok-free.app/login.php"; aqui debe ir la url de tu php

  // Método para iniciar sesión
  Future<Map<String, dynamic>> login(String usuario, String contraseña) async {
    try {
      final response = await http.post(
        Uri.parse(url_login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'usuario': usuario,
          'contraseña': contraseña,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded['success'] == true) {
          return {
            'success': true,
            'mensaje': decoded['mensaje'],
            'datos': decoded['datos'], //obtuve la informacion del usuario
          };
        } else {
          return {
            'success': false,
            'mensaje': decoded['mensaje'],
          };
        }
      } else {
        throw Exception("Error en la conexión: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
      return {'success': false, 'mensaje': 'Error de conexión'};
    }
  } // Fin del método login
} -->