//3.a.1.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//3.a.1.2. Modelo de datos de una cita
class Cliente {
  final String nombre;
  final String asunto;
  final String numero;
  final DateTime fechaHora; // Guarda fecha + hora en un solo campo

  Cliente({
    required this.nombre,
    required this.asunto,
    required this.numero,
    required this.fechaHora,
  });
}

class CalendarioModel extends ChangeNotifier {
  final List<Cliente> _citas = [];

  List<Cliente> get citas => List.unmodifiable(_citas);

  void addCita(Cliente cita) {
    _citas.add(cita);
    notifyListeners();
  }

  void removeCita(Cliente cita) {
    _citas.remove(cita);
    notifyListeners();
  }

  /// Filtrar citas por día (independientemente de la hora)
  List<Cliente> getCitasPorDia(DateTime dia) {
    return _citas
        .where(
          (cita) =>
              cita.fechaHora.year == dia.year &&
              cita.fechaHora.month == dia.month &&
              cita.fechaHora.day == dia.day,
        )
        .toList();
  }

  /// Filtrar citas por semana (lunes a domingo)
  List<Cliente> getCitasPorSemana(DateTime monday) {
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return _citas
        .where(
          (cita) =>
              !cita.fechaHora.isBefore(startOfWeek) &&
              !cita.fechaHora.isAfter(endOfWeek),
        )
        .toList();
  }

  /// Filtrar citas exactas por fecha y hora
  Cliente? getCitaPorFechaHora(DateTime dt) {
    try {
      return _citas.firstWhere(
        (cita) =>
            cita.fechaHora.year == dt.year &&
            cita.fechaHora.month == dt.month &&
            cita.fechaHora.day == dt.day &&
            cita.fechaHora.hour == dt.hour &&
            cita.fechaHora.minute == dt.minute,
      );
    } catch (_) {
      return null;
    }
  }

  void clearCitas() {
    _citas.clear();
    notifyListeners();
  }
}

// import 'package:flutter/material.dart';
// import 'dart:math';

// /// Clase Cliente
// class Cliente {
//   final String nombre;
//   final String asunto;
//   final String numero;
//   final DateTime fechaHora;

//   Cliente({
//     required this.nombre,
//     required this.asunto,
//     required this.numero,
//     required this.fechaHora,
//   });
// }

// /// Modelo con Provider
// class CalendarioModel extends ChangeNotifier {
//   final List<Cliente> _citas = [];

//   List<Cliente> get citas => List.unmodifiable(_citas);

//   /// Agregar nueva cita
//   void addCita(Cliente cita) {
//     _citas.add(cita);
//     notifyListeners();
//   }

//   /// Eliminar cita
//   void removeCita(Cliente cita) {
//     _citas.remove(cita);
//     notifyListeners();
//   }

//   /// Simular carga desde "base de datos"
//   void cargarCitasDePrueba() {
//     _citas.clear();
//     _citas.addAll([
//       Cliente(
//         nombre: "Juan Pérez",
//         asunto: "Consulta médica",
//         numero: "555-1234",
//         fechaHora: DateTime.now().add(const Duration(hours: 1)),
//       ),
//       Cliente(
//         nombre: "Ana López",
//         asunto: "Revisión dental",
//         numero: "555-5678",
//         fechaHora: DateTime.now().add(const Duration(days: 1, hours: 2)),
//       ),
//       Cliente(
//         nombre: "Carlos Ramírez",
//         asunto: "Entrevista de trabajo",
//         numero: "555-9876",
//         fechaHora: DateTime.now().add(const Duration(days: -1, hours: 3)),
//       ),
//     ]);
//     notifyListeners();
//   }

//   /// Generar citas aleatorias (útil para pruebas largas)
//   void generarCitasAleatorias(int cantidad) {
//     final random = Random();
//     final nombres = ["Juan", "Ana", "Carlos", "María", "Pedro", "Lucía"];
//     final asuntos = ["Consulta", "Reunión", "Llamada", "Taller", "Entrega"];

//     for (int i = 0; i < cantidad; i++) {
//       final nombre = nombres[random.nextInt(nombres.length)];
//       final asunto = asuntos[random.nextInt(asuntos.length)];
//       final numero = "555-${1000 + random.nextInt(9000)}";

//       final fecha = DateTime.now().add(
//         Duration(
//           days: random.nextInt(10) - 5, // desde 5 días atrás hasta 5 adelante
//           hours: random.nextInt(12),
//         ),
//       );

//       _citas.add(
//         Cliente(
//           nombre: nombre,
//           asunto: asunto,
//           numero: numero,
//           fechaHora: fecha,
//         ),
//       );
//     }
//     notifyListeners();
//   }
// }
