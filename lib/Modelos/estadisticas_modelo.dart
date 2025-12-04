// File: lib/modelos/estadisticas_modelo.dart
//
// Modelo de estadísticas para Flutter Web/Mobile.
// Fuente de datos: HTTP POST a Calendario.php { "accion": "listar" }.
// Filtrado por rango en cliente, armado de series y logs de depuración.
// No toca la UI ni el diseño.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

void _log(String m) => debugPrint('[stats.model] $m');

class Cita {
  final int id;
  final DateTime fecha;
  final String estado;

  Cita({required this.id, required this.fecha, required this.estado});

  static DateTime _parseFechaHora(String? f, String? h) {
    final fecha = (f ?? '').trim();
    final hora = (h == null || h.trim().isEmpty) ? '00:00:00' : h.trim();
    // Por estabilidad en Web.
    return DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).parse('$fecha $hora', true).toLocal();
  }

  factory Cita.fromMap(Map<String, dynamic> m) => Cita(
    id: (m['id_citas'] as num).toInt(),
    fecha: _parseFechaHora(m['fecha'] as String?, m['hora'] as String?),
    estado: (m['estado'] ?? '').toString(),
  );
}

class EstadisticasModelo extends ChangeNotifier {
  // --- Filtros
  int? mesSeleccionado;
  int? anioSeleccionado;
  String filtroSeleccionado = 'Semanal';
  DateTimeRange? rangoFechasSeleccionado;

  // --- Datos UI
  List<FlSpot> datosGraficaCancelaciones = [];
  List<FlSpot> datosGraficaCitas = [];
  String datoPrincipalCancelaciones = '';
  String datoSecundarioCancelaciones = '';
  String datoPrincipalCitas = '';
  String datoSecundarioCitas = '';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- Endpoint HTTP (SOLO http como pediste)
  static const String _HOST = 'servidor-morales11.sytes.net';
  static const int _PORT = 5050;
  static const String _PATH_CALENDARIO = '/Calendario.php';

  EstadisticasModelo() {
    final now = DateTime.now();
    anioSeleccionado = now.year;
    mesSeleccionado = now.month;
    cargarDatosActuales();
  }

  // ===================== Setters =====================
  // File: lib/modelos/estadisticas_modelo.dart
  // Agrega este método a tu clase EstadisticasModelo (no cambia diseño).
  // Útil para Semanal: aplicar lunes–domingo de un día dado sin cambiar el filtro.

  void setSemanaDesdeDia(DateTime dia) {
    final base = DateTime(dia.year, dia.month, dia.day);
    final lunes = base.subtract(Duration(days: base.weekday - 1));
    final domingo = lunes.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );

    // Por qué: queremos usar este rango con filtro "Semanal" sin mutar el valor del filtro
    rangoFechasSeleccionado = DateTimeRange(start: lunes, end: domingo);

    // Recargar con este rango
    cargarDatosActuales();
    notifyListeners();
  }

  void setMes(int mes) {
    mesSeleccionado = mes;
    if (filtroSeleccionado == "Mensual") {
      rangoFechasSeleccionado = null;
      cargarDatosActuales();
    }
    notifyListeners();
  }

  void setAnio(int anio) {
    anioSeleccionado = anio;
    if (filtroSeleccionado == "Anual" || filtroSeleccionado == "Mensual") {
      rangoFechasSeleccionado = null;
      cargarDatosActuales();
    }
    notifyListeners();
  }

  void setFiltro(String nuevoFiltro) {
    filtroSeleccionado = nuevoFiltro;
    if (nuevoFiltro != "Personalizado") {
      rangoFechasSeleccionado = null;
    }
    if (nuevoFiltro == "Mensual" && mesSeleccionado == null) {
      mesSeleccionado = DateTime.now().month;
    }
    if (nuevoFiltro == "Anual" && anioSeleccionado == null) {
      anioSeleccionado = DateTime.now().year;
    }
    cargarDatosActuales();
  }

  void setRangoPersonalizado(DateTimeRange nuevoRango) {
    rangoFechasSeleccionado = nuevoRango;
    filtroSeleccionado = 'Personalizado';
    cargarDatosActuales();
  }

  // ===================== Título =====================
  // File: lib/modelos/estadisticas_modelo.dart
  // Reemplaza dentro de tu clase `EstadisticasModelo` el getter `tituloFecha`
  // y agrega los helpers debajo.

  String get tituloFecha {
    // Personalizado con rango elegido
    if (rangoFechasSeleccionado != null) {
      return _humanizeRange(
        rangoFechasSeleccionado!.start,
        rangoFechasSeleccionado!.end,
      );
    }

    // Mensual
    if (filtroSeleccionado == "Mensual" &&
        mesSeleccionado != null &&
        anioSeleccionado != null) {
      final d = DateTime(anioSeleccionado!, mesSeleccionado!, 1);
      return '${_monAbbr(d)} ${d.year}';
    }

    // Anual
    if (filtroSeleccionado == "Anual" && anioSeleccionado != null) {
      return '${anioSeleccionado!}';
    }

    // Semanal (semana actual)
    if (filtroSeleccionado == "Semanal") {
      final hoy = DateTime.now();
      final base = DateTime(hoy.year, hoy.month, hoy.day);
      final lunes = base.subtract(Duration(days: base.weekday - 1));
      final domingo = lunes.add(const Duration(days: 6));
      return _humanizeRange(lunes, domingo);
    }

    return '';
  }

  // ===== Helpers de formato “moderno” =====

  // Abreviatura de mes en español, siempre minúscula y sin punto final (ene, feb, mar, ...).
  String _monAbbr(DateTime d) {
    // DateFormat('MMM', 'es') suele traer 'dic.' → quitamos punto y forzamos lowercase.
    final raw = DateFormat('MMM', 'es').format(d);
    final clean = raw.replaceAll('.', '').toLowerCase();
    return clean;
  }

  // Día sin cero a la izquierda
  String _dayNum(DateTime d) => DateFormat('d', 'es').format(d);

  // Rango compacto:
  // - Mismo mes/año:        1–7 dic 2025
  // - Mismo año, mes cambia:28 nov – 3 dic 2025
  // - Año cambia:           28 dic 2025 – 3 ene 2026
  String _humanizeRange(DateTime a, DateTime b) {
    final da = DateTime(a.year, a.month, a.day);
    final db = DateTime(b.year, b.month, b.day);

    final sameYear = da.year == db.year;
    final sameMonth = sameYear && da.month == db.month;

    if (sameMonth) {
      return '${_dayNum(da)}–${_dayNum(db)} ${_monAbbr(db)} ${db.year}';
    }

    if (sameYear) {
      return '${_dayNum(da)} ${_monAbbr(da)} – ${_dayNum(db)} ${_monAbbr(db)} ${db.year}';
    }

    return '${_dayNum(da)} ${_monAbbr(da)} ${da.year} – ${_dayNum(db)} ${_monAbbr(db)} ${db.year}';
  }

  // ===================== HTTP helpers =====================
  Uri _buildUri({required String path}) {
    return Uri(
      scheme: 'http', // ← SOLO HTTP
      host: _HOST,
      port: _PORT, // host y port separados
      path: path,
    );
  }

  Future<http.Response> _post(Uri uri, Map<String, dynamic> jsonBody) {
    final body = jsonEncode(jsonBody);
    _log('POST $uri body=$jsonBody');
    return http
        .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
        .timeout(const Duration(seconds: 20));
  }

  Future<List<Cita>> _listarCitasDesdeCalendario() async {
    final uri = _buildUri(path: _PATH_CALENDARIO);
    try {
      final res = await _post(uri, {"accion": "listar"});
      _log('status=${res.statusCode} bytes=${res.bodyBytes.length}');
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
      final decoded = jsonDecode(res.body);
      if (decoded is! Map ||
          decoded['success'] != true ||
          decoded['citas'] is! List) {
        throw Exception('Formato inesperado: $decoded');
      }
      final List raw = decoded['citas'];
      final out = <Cita>[];
      for (final e in raw) {
        try {
          out.add(Cita.fromMap(Map<String, dynamic>.from(e)));
        } catch (pe) {
          _log('parse cita error: $pe / $e');
        }
      }
      _log('listar -> n=${out.length}');
      return out;
    } catch (e) {
      _log('POST fail ($uri): $e');
      rethrow;
    }
  }

  // ===================== Carga principal =====================
  Future<void> cargarDatosActuales() async {
    _isLoading = true;
    notifyListeners();

    // rango
    DateTime inicio, fin;
    if (rangoFechasSeleccionado != null) {
      inicio = DateTime(
        rangoFechasSeleccionado!.start.year,
        rangoFechasSeleccionado!.start.month,
        rangoFechasSeleccionado!.start.day,
      );
      fin = DateTime(
        rangoFechasSeleccionado!.end.year,
        rangoFechasSeleccionado!.end.month,
        rangoFechasSeleccionado!.end.day,
        23,
        59,
        59,
      );
    } else {
      switch (filtroSeleccionado) {
        case "Semanal":
          final hoy = DateTime.now();
          final base = DateTime(hoy.year, hoy.month, hoy.day);
          inicio = base.subtract(Duration(days: hoy.weekday - 1));
          fin = inicio.add(
            const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
          );
          break;
        case "Mensual":
          inicio = DateTime(anioSeleccionado!, mesSeleccionado!, 1);
          fin = DateTime(
            anioSeleccionado!,
            mesSeleccionado! + 1,
            0,
            23,
            59,
            59,
          );
          break;
        case "Anual":
          inicio = DateTime(anioSeleccionado!, 1, 1);
          fin = DateTime(anioSeleccionado!, 12, 31, 23, 59, 59);
          break;
        default:
          inicio = DateTime.now();
          fin = DateTime.now();
      }
    }
    _log('rango: $inicio .. $fin  filtro=$filtroSeleccionado');

    try {
      // 1) Traer TODAS las citas
      final todas = await _listarCitasDesdeCalendario();

      // 2) Filtrar por rango en cliente
      final citas =
          todas
              .where((c) => !c.fecha.isBefore(inicio) && !c.fecha.isAfter(fin))
              .toList();
      _log('citas en rango=${citas.length} de total=${todas.length}');

      // 3) Totales
      final confirmadas =
          citas.where((c) => c.estado.toLowerCase().contains('confirm')).length;
      final canceladas =
          citas.where((c) => c.estado.toLowerCase().contains('cancel')).length;

      datoPrincipalCitas = "$confirmadas";
      datoSecundarioCitas = "Confirmadas";
      datoPrincipalCancelaciones = "$canceladas";
      datoSecundarioCancelaciones = "Canceladas";

      // 4) Series
      _construirDatosGrafica(citas);

      // 5) Fallback visual si hay totales pero sin puntos
      if (datosGraficaCitas.isEmpty && (confirmadas > 0 || canceladas > 0)) {
        datosGraficaCitas = [
          FlSpot(0, confirmadas.toDouble()),
          FlSpot(1, confirmadas.toDouble()),
        ];
        datosGraficaCancelaciones = [
          FlSpot(0, canceladas.toDouble()),
          FlSpot(1, canceladas.toDouble()),
        ];
      }

      _log(
        'series listas: citasPts=${datosGraficaCitas.length} cancPts=${datosGraficaCancelaciones.length}',
      );
    } catch (e, st) {
      _log('❌ cargarDatosActuales: $e\n$st');
      datoPrincipalCitas = "Error";
      datoSecundarioCitas = "No disponible";
      datoPrincipalCancelaciones = "";
      datoSecundarioCancelaciones = "";
      datosGraficaCitas = [];
      datosGraficaCancelaciones = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // ===================== Series =====================
  void _construirDatosGrafica(List<Cita> citas) {
    datosGraficaCitas = [];
    datosGraficaCancelaciones = [];
    if (citas.isEmpty) return;

    switch (filtroSeleccionado) {
      case 'Semanal':
      case 'Mensual':
      case 'Personalizado':
        _construirPorDia(citas);
        break;
      case 'Anual':
        _construirPorMes(citas);
        break;
      default:
        _construirPorDia(citas);
        break;
    }
  }

  void _construirPorDia(List<Cita> citas) {
    final porDia = groupBy<Cita, DateTime>(
      citas,
      (c) => DateTime(c.fecha.year, c.fecha.month, c.fecha.day),
    );
    final dias = porDia.keys.toList()..sort();

    for (int i = 0; i < dias.length; i++) {
      final lista = porDia[dias[i]]!;
      final conf =
          lista
              .where((c) => c.estado.toLowerCase().contains('confirm'))
              .length
              .toDouble();
      final canc =
          lista
              .where((c) => c.estado.toLowerCase().contains('cancel'))
              .length
              .toDouble();
      datosGraficaCitas.add(FlSpot(i.toDouble(), conf));
      datosGraficaCancelaciones.add(FlSpot(i.toDouble(), canc));
    }
  }

  void _construirPorMes(List<Cita> citas) {
    final porMes = groupBy<Cita, int>(citas, (c) => c.fecha.month);
    for (int i = 1; i <= 12; i++) {
      final lista = porMes[i] ?? [];
      final conf =
          lista
              .where((c) => c.estado.toLowerCase().contains('confirm'))
              .length
              .toDouble();
      final canc =
          lista
              .where((c) => c.estado.toLowerCase().contains('cancel'))
              .length
              .toDouble();
      final x = (i - 1).toDouble();
      datosGraficaCitas.add(FlSpot(x, conf));
      datosGraficaCancelaciones.add(FlSpot(x, canc));
    }
  }
}
