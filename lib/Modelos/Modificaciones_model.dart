import 'package:flutter/material.dart';

/// Tipos de bloqueo en el calendario
enum TipoModificacion {
  unica, // Solo un día específico
  rangoDiario, // Se repite diario dentro de un rango de fechas
  semanal, // Repetición semanal (ej: todos los lunes)
}

/// Clase que representa un bloqueo/modificación en el calendario
class Modificacion {
  final String titulo;

  /// Fecha de inicio y fin (para rangos o un único día)
  final DateTime fechaInicio;
  final DateTime fechaFin;

  /// Hora de inicio y fin del bloqueo
  final TimeOfDay horaInicio;
  final TimeOfDay horaFin;

  /// Tipo de modificación
  final TipoModificacion tipo;

  /// Si es semanal, indica qué días de la semana aplica (0 = Lunes, 6 = Domingo)
  final List<int>? diasSemana;

  Modificacion({
    required this.titulo,
    required this.fechaInicio,
    required this.fechaFin,
    required this.horaInicio,
    required this.horaFin,
    required this.tipo,
    this.diasSemana,
  });
}

class ModificacionesModel extends ChangeNotifier {
  final List<Modificacion> _modificaciones = [];

  ModificacionesModel() {
    // 🔹 Ejemplos iniciales para probar
    _modificaciones.addAll([
      // 🟡 ÚNICA: 29 sep 2025 de 1 a 3 PM
      Modificacion(
        titulo: "Pagar servicio",
        fechaInicio: DateTime(2025, 9, 29),
        fechaFin: DateTime(2025, 9, 29),
        horaInicio: const TimeOfDay(hour: 13, minute: 0),
        horaFin: const TimeOfDay(hour: 15, minute: 0),
        tipo: TipoModificacion.unica,
      ),
      // 🔵 SEMANAL: Todos los lunes de 17:00 a 18:00
      Modificacion(
        titulo: "Recoger a la niña",
        fechaInicio: DateTime(2025, 1, 1),
        fechaFin: DateTime(2025, 12, 31),
        horaInicio: const TimeOfDay(hour: 17, minute: 0),
        horaFin: const TimeOfDay(hour: 18, minute: 0),
        tipo: TipoModificacion.semanal,
        diasSemana: [0], // Lunes
      ),
      // 🟤 RANGO DIARIO: del 5 al 20 de enero de 14:00 a 15:00
      Modificacion(
        titulo: "Comida",
        fechaInicio: DateTime(2025, 1, 5),
        fechaFin: DateTime(2025, 1, 20),
        horaInicio: const TimeOfDay(hour: 14, minute: 0),
        horaFin: const TimeOfDay(hour: 15, minute: 0),
        tipo: TipoModificacion.rangoDiario,
      ),
    ]);
  }

  List<Modificacion> get modificaciones => List.unmodifiable(_modificaciones);

  void addModificacion(Modificacion mod) {
    _modificaciones.add(mod);
    notifyListeners();
  }

  void removeModificacion(Modificacion mod) {
    _modificaciones.remove(mod);
    notifyListeners();
  }

  /// Devuelve todos los bloqueos que afectan un día específico
  List<Modificacion> getBloqueosPorDia(DateTime dia) {
    return _modificaciones.where((mod) {
      switch (mod.tipo) {
        case TipoModificacion.unica:
          return _esMismoDia(mod.fechaInicio, dia);

        case TipoModificacion.rangoDiario:
          return dia.isAfter(
                mod.fechaInicio.subtract(const Duration(days: 1)),
              ) &&
              dia.isBefore(mod.fechaFin.add(const Duration(days: 1)));

        case TipoModificacion.semanal:
          final weekdayIndex = (dia.weekday - 1); // 0=Lunes
          return mod.diasSemana?.contains(weekdayIndex) ?? false;
      }
    }).toList();
  }

  /// Verifica si un intervalo de tiempo (ej. cita) cae dentro de algún bloqueo
  bool estaBloqueado(DateTime fecha, TimeOfDay horaInicio, TimeOfDay horaFin) {
    final bloqueosDelDia = getBloqueosPorDia(fecha);
    for (final b in bloqueosDelDia) {
      if (_intersectanHoras(horaInicio, horaFin, b.horaInicio, b.horaFin)) {
        return true;
      }
    }
    return false;
  }

  // Helpers
  bool _esMismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _intersectanHoras(
    TimeOfDay start1,
    TimeOfDay end1,
    TimeOfDay start2,
    TimeOfDay end2,
  ) {
    final start1Min = start1.hour * 60 + start1.minute;
    final end1Min = end1.hour * 60 + end1.minute;
    final start2Min = start2.hour * 60 + start2.minute;
    final end2Min = end2.hour * 60 + end2.minute;

    return start1Min < end2Min && end1Min > start2Min;
  }

  void clear() {
    _modificaciones.clear();
    notifyListeners();
  }
}
