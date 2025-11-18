// Utilidades compartidas por las vistas del calendario
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neurify/modelos/modificaciones_model.dart';

int? weekdayFromSpanish(String? dia) {
  if (dia == null) return null;
  final d = dia.trim().toLowerCase();
  switch (d) {
    case 'lunes':
      return DateTime.monday;
    case 'martes':
      return DateTime.tuesday;
    case 'miércoles':
    case 'miercoles':
      return DateTime.wednesday;
    case 'jueves':
      return DateTime.thursday;
    case 'viernes':
      return DateTime.friday;
    case 'sábado':
    case 'sabado':
      return DateTime.saturday;
    case 'domingo':
      return DateTime.sunday;
    default:
      return null;
  }
}

/// Rango [start, end) por minutos (la hora fin es *exclusiva*)
bool hourInRange(DateTime target, DateTime? start, DateTime? end) {
  final tM = target.hour * 60 + target.minute;
  final sM = start == null ? null : start.hour * 60 + start.minute;
  final eM = end == null ? null : end.hour * 60 + end.minute;
  if (sM != null && tM < sM) return false;
  if (eM != null && tM >= eM) return false;
  return true;
}

bool sameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool dateInRange(DateTime day, DateTime? start, DateTime? end) {
  DateTime onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);
  final d = onlyDate(day);
  final s = start == null ? null : onlyDate(start);
  final e = end == null ? null : onlyDate(end);
  if (s != null && d.isBefore(s)) return false;
  if (e != null && d.isAfter(e)) return false;
  return true;
}

bool isBlockedAt({
  required DateTime day,
  required int hour,
  required Modificacion mod,
}) {
  final target = DateTime(day.year, day.month, day.day, hour, 0);
  switch (mod.tipo) {
    case TipoModificacion.unica:
      if (mod.fechaUnica == null) return false;
      if (!sameDate(day, mod.fechaUnica!)) return false;
      final ok = hourInRange(target, mod.horaInicio, mod.horaFin);
      if (ok)
        debugPrint(' Única ${mod.titulo} @ ${DateFormat.Hm().format(target)}');
      return ok;
    case TipoModificacion.rangoDiario:
      if (!dateInRange(day, mod.fechaInicio, mod.fechaFinal)) return false;
      final ok = hourInRange(target, mod.horaInicio, mod.horaFin);
      if (ok)
        debugPrint(' Diario ${mod.titulo} @ ${DateFormat.Hm().format(target)}');
      return ok;
    case TipoModificacion.semanal:
      final w = weekdayFromSpanish(mod.diaSemana);
      if (w == null || day.weekday != w) return false;
      final ok = hourInRange(target, mod.horaInicio, mod.horaFin);
      if (ok)
        debugPrint('Semanal ${mod.titulo} @ ${DateFormat.Hm().format(target)}');
      return ok;
  }
}

bool anyBlockOnDay(DateTime day, List<Modificacion> mods) {
  for (final m in mods) {
    switch (m.tipo) {
      case TipoModificacion.unica:
        if (m.fechaUnica != null && sameDate(day, m.fechaUnica!)) return true;
        break;
      case TipoModificacion.rangoDiario:
        if (dateInRange(day, m.fechaInicio, m.fechaFinal)) return true;
        break;
      case TipoModificacion.semanal:
        final w = weekdayFromSpanish(m.diaSemana);
        if (w != null && day.weekday == w) return true;
        break;
    }
  }
  return false;
}
