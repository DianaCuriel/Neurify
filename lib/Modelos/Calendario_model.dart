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
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      _citas = data.map((json) => Cliente.fromJson(json)).toList();
      notifyListeners();
    }
  }

  // Crear cita
  Future<void> addCita(Cliente cita) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cita.toJson()),
    );
    if (response.statusCode == 200) {
      await fetchCitas();
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

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// // Modelo de datos de una cita
// class Cliente {
//   final String nombre;
//   final String asunto;
//   final String numero;
//   final DateTime fechaHora; // Guarda fecha + hora en un solo campo

//   Cliente({
//     required this.nombre,
//     required this.asunto,
//     required this.numero,
//     required this.fechaHora,
//   });
// }

// class CalendarioModel extends ChangeNotifier {
//   final List<Cliente> _citas = [
//     Cliente(
//       nombre: "Juan Pérez",
//       asunto: "Reparación celular iPhone14",
//       numero: "555-1234",
//       fechaHora: DateTime(2025, 9, 29, 15, 0), // 29 sept 2025, 3:00 PM
//     ),
//     Cliente(
//       nombre: "Ana López",
//       asunto: "Compra celular. Quiere ver Samsung",
//       numero: "555-5678",
//       fechaHora: DateTime(2025, 10, 2, 11, 30), // 1 oct 2025, 11:30 AM
//     ),
//     Cliente(
//       nombre: "Carlos Ramírez",
//       asunto: "Entrevista de trabajo",
//       numero: "555-9876",
//       fechaHora: DateTime(2025, 10, 3, 14, 0), // 3 oct 2025, 2:00 PM
//     ),
//     Cliente(
//       nombre: "María Gómez",
//       asunto: "Llamada importante",
//       numero: "555-4321",
//       fechaHora: DateTime(2025, 10, 5, 9, 0), // 5 oct 2025, 9:00 AM
//     ),
//   ];

//   List<Cliente> get citas => List.unmodifiable(_citas);

//   void addCita(Cliente cita) {
//     _citas.add(cita);
//     notifyListeners();
//   }

//   void removeCita(Cliente cita) {
//     _citas.remove(cita);
//     notifyListeners();
//   }

//   /// Filtrar citas por día (independientemente de la hora)
//   List<Cliente> getCitasPorDia(DateTime dia) {
//     return _citas
//         .where(
//           (cita) =>
//               cita.fechaHora.year == dia.year &&
//               cita.fechaHora.month == dia.month &&
//               cita.fechaHora.day == dia.day,
//         )
//         .toList();
//   }

//   /// Filtrar citas por semana (lunes a domingo)
//   List<Cliente> getCitasPorSemana(DateTime monday) {
//     final startOfWeek = DateTime(monday.year, monday.month, monday.day);
//     final endOfWeek = startOfWeek.add(const Duration(days: 6));
//     return _citas
//         .where(
//           (cita) =>
//               !cita.fechaHora.isBefore(startOfWeek) &&
//               !cita.fechaHora.isAfter(endOfWeek),
//         )
//         .toList();
//   }

//   /// Filtrar citas exactas por fecha y hora
//   Cliente? getCitaPorFechaHora(DateTime dt) {
//     try {
//       return _citas.firstWhere(
//         (cita) =>
//             cita.fechaHora.year == dt.year &&
//             cita.fechaHora.month == dt.month &&
//             cita.fechaHora.day == dt.day &&
//             cita.fechaHora.hour == dt.hour &&
//             cita.fechaHora.minute == dt.minute,
//       );
//     } catch (_) {
//       return null;
//     }
//   }

//   void clearCitas() {
//     _citas.clear();
//     notifyListeners();
//   }
// }
