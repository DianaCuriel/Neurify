import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Modelo de datos de una cita
class Cliente {
  final String nombre;
  final String asunto;
  final String numero;
  final DateTime fechaHora;

  Cliente({
    required this.nombre,
    required this.asunto,
    required this.numero,
    required this.fechaHora,
  });
}

class CalendarioModel extends ChangeNotifier {
  final List<Cliente> _citas = [
    Cliente(
      nombre: "Juan Pérez",
      asunto: "Reparación celular iPhone14",
      numero: "555-1234",
      fechaHora: DateTime(2025, 10, 25, 15, 0), // 29 sept 2025, 3:00 PM
    ),
    Cliente(
      nombre: "Ana López",
      asunto: "Compra celular. Quiere ver Samsung",
      numero: "555-5678",
      fechaHora: DateTime(2025, 10, 2, 11, 30), // 1 oct 2025, 11:30 AM
    ),
    Cliente(
      nombre: "Carlos Ramírez",
      asunto: "Entrevista de trabajo",
      numero: "555-9876",
      fechaHora: DateTime(2025, 10, 3, 14, 0), // 3 oct 2025, 2:00 PM
    ),
    Cliente(
      nombre: "María Gómez",
      asunto: "Llamada importante",
      numero: "555-4321",
      fechaHora: DateTime(2025, 10, 5, 9, 0), // 5 oct 2025, 9:00 AM
    ),
  ];

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
