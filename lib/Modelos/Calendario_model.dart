import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Cliente {
  final int? id; // opcional para identificar en BD
  final String nombre;
  final String asunto;
  final String numero;
  final DateTime fechaHora;

  Cliente({
    this.id,
    required this.nombre,
    required this.asunto,
    required this.numero,
    required this.fechaHora,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nombre: json['nombre'],
      asunto: json['asunto'],
      numero: json['numero'],
      fechaHora: DateTime.parse(json['fechaHora']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'asunto': asunto,
      'numero': numero,
      'fechaHora': fechaHora.toIso8601String(),
    };
  }
}

class CalendarioModel extends ChangeNotifier {
  final String apiUrl =
      'http://servidor-morales11.sytes.net:5050/Calendario.php';
  List<Cliente> _citas = [];

  List<Cliente> get citas => List.unmodifiable(_citas);

  // Leer citas desde la base de datos
  Future<void> fetchCitas() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          _citas = data.map((json) => Cliente.fromJson(json)).toList();
          notifyListeners();
        } else {
          print('Error: JSON recibido no es una lista: $data');
        }
      } else {
        print('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetchCitas: $e');
    }
  }

  // Crear cita
  Future<void> addCita(Cliente cita) async {
    final body = {
      'accion': 'añadir',
      'id_cliente': 1, // Por ejemplo, asigna un valor
      'id_empresario': 1, // Igual
      'motivo': cita.asunto,
      'fechaHora': cita.fechaHora.toIso8601String(),
      'estado': 'pendiente',
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      await fetchCitas();
    } else {
      print('Error al agregar cita: ${response.body}');
    }
  }

  // Actualizar cita
  Future<void> updateCita(Cliente cita) async {
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cita.toJson()),
    );
    if (response.statusCode == 200) {
      await fetchCitas();
    }
  }

  // Eliminar cita
  Future<void> removeCita(Cliente cita) async {
    if (cita.id == null) return;
    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': cita.id}),
    );
    if (response.statusCode == 200) {
      await fetchCitas();
    }
  }
}
