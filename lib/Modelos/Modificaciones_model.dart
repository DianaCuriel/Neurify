//3.a.1.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//3.a.1.2. Modelo de datos de una cita
class Modificiones {
  final String titulo;
  final DateTime fechaHora; // Guarda fecha + hora en un solo campo

  Modificiones({required this.titulo, required this.fechaHora});
}

class ModificacionesModel extends ChangeNotifier {
  final List<Modificiones> _citas = [];

  List<Modificiones> get citas => List.unmodifiable(_citas);

  void addCita(Modificiones cita) {
    _citas.add(cita);
    notifyListeners();
  }

  void removeCita(Modificiones cita) {
    _citas.remove(cita);
    notifyListeners();
  }

  /// Filtrar citas por día (independientemente de la hora)
  List<Modificiones> getCitasPorDia(DateTime dia) {
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
  List<Modificiones> getCitasPorSemana(DateTime monday) {
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
  Modificiones? getCitaPorFechaHora(DateTime dt) {
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
