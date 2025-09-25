//3.a.1.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//3.a.1.2. Modelo de datos de una cita
class Cliente {
  final String nombre;
  final String asunto;
  final String numero;
  final String fecha; // "dd/MM/yyyy"
  final String hora; // "HH:mm"

  Cliente({
    required this.nombre,
    required this.asunto,
    required this.numero,
    required this.fecha,
    required this.hora,
  });
}

// Modelo central de gestión de citas
class CalendarioModel extends ChangeNotifier {
  final List<Cliente> _citas = [];

  // Obtener todas las citas (copia para evitar manipulación directa)
  List<Cliente> get citas => List.unmodifiable(_citas);

  // Agregar una cita
  void addCita(Cliente cita) {
    _citas.add(cita);
    notifyListeners(); // Notifica a los widgets que están escuchando
  }

  // Eliminar una cita
  void removeCita(Cliente cita) {
    _citas.remove(cita);
    notifyListeners();
  }

  // Filtrar citas por día
  List<Cliente> getCitasPorDia(DateTime dia) {
    return _citas.where((cita) {
      try {
        final fechaCita = DateFormat("dd/MM/yyyy").parse(cita.fecha);
        return fechaCita.year == dia.year &&
            fechaCita.month == dia.month &&
            fechaCita.day == dia.day;
      } catch (e) {
        debugPrint("Error parseando fecha: $e");
        return false;
      }
    }).toList();
  }

  // Filtrar citas por semana (lunes a domingo)
  List<Cliente> getCitasPorSemana(DateTime monday) {
    final startOfWeek = monday;
    final endOfWeek = monday.add(const Duration(days: 6));
    return _citas.where((cita) {
      try {
        final fechaCita = DateFormat("dd/MM/yyyy").parse(cita.fecha);
        return !fechaCita.isBefore(startOfWeek) &&
            !fechaCita.isAfter(endOfWeek);
      } catch (e) {
        debugPrint("Error parseando fecha: $e");
        return false;
      }
    }).toList();
  }

  // Limpiar todas las citas
  void clearCitas() {
    _citas.clear();
    notifyListeners();
  }
}
