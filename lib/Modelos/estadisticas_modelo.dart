import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart'; // Para la función groupBy
import 'package:intl/intl.dart';

// Modelo de datos para una Cita de la BBDD.
class Cita {
  final int id;
  final DateTime fecha;
  final String estado;
  // 'Realizada', 'Cancelada', 'Pendiente', etc.

  Cita({required this.id, required this.fecha, required this.estado});

  // Constructor para crear desde un Map de la BBDD.
  factory Cita.fromMap(Map<String, dynamic> map) {
    return Cita(
      id: map['id_citas'],
      // Asegúrate que el formato de fecha y hora de tu BBDD coincida
      fecha: DateTime.parse("${map['fecha']} ${map['hora']}"),
      estado: map['estado'],
    );
  }
}

// Gestiona el estado y la lógica de la página de estadísticas.
class EstadisticasModelo extends ChangeNotifier {
  // --- STATE ---
  String filtroSeleccionado = 'Semanal'; // Filtro activo
  DateTimeRange? rangoFechasSeleccionado; // Rango de fechas del calendario
  List<FlSpot> datosGraficaCancelaciones = [];
  // Puntos (X, Y) para la gráfica
  List<FlSpot> datosGraficaCitas = [];
  String datoPrincipalCancelaciones = '';
  // Textos de resumen
  String datoSecundarioCancelaciones = '';
  String datoPrincipalCitas = '';
  String datoSecundarioCitas = '';
  bool _isLoading = false; // Estado de carga (true si está buscando datos)
  bool get isLoading => _isLoading;
  // Carga los datos iniciales al crear.
  EstadisticasModelo() {
    cargarDatosActuales();
  }

  // --- GETTERS ---
  // Devuelve el título (ej. "Resumen - Semanal" o "01/01 - 07/01").
  String get tituloFecha {
    if (rangoFechasSeleccionado != null) {
      final formato = DateFormat('dd/MM/yyyy');
      final startFormatted = formato.format(rangoFechasSeleccionado!.start);
      final endFormatted = formato.format(rangoFechasSeleccionado!.end);
      return '$startFormatted - $endFormatted';
    }
    return 'Resumen - $filtroSeleccionado';
  }

  // --- MÉTODOS PÚBLICOS ---

  // Actualiza el filtro (Semanal, Mensual, Anual) y recarga.
  void setFiltro(String nuevoFiltro) {
    if (filtroSeleccionado == nuevoFiltro && rangoFechasSeleccionado == null) {
      return;
    }
    filtroSeleccionado = nuevoFiltro;
    rangoFechasSeleccionado = null; // Limpia el rango personalizado
    cargarDatosActuales();
  }

  // Actualiza a un rango personalizado y recarga.
  void setRangoPersonalizado(DateTimeRange nuevoRango) {
    if (rangoFechasSeleccionado != null &&
        rangoFechasSeleccionado!.start == nuevoRango.start &&
        rangoFechasSeleccionado!.end == nuevoRango.end) {
      return;
    }
    rangoFechasSeleccionado = nuevoRango;
    filtroSeleccionado = 'Personalizado';
    cargarDatosActuales();
  }

  // Método principal para cargar/recargar los datos.
  Future<void> cargarDatosActuales() async {
    _isLoading = true;
    notifyListeners();
    // Notifica a la UI que empiece a mostrar el loader

    // 1. Determina el rango de fechas para la consulta
    DateTime fechaFin = DateTime.now();
    DateTime fechaInicio;

    if (rangoFechasSeleccionado != null) {
      // Rango personalizado
      fechaInicio = rangoFechasSeleccionado!.start;
      fechaFin = DateTime(
        rangoFechasSeleccionado!.end.year,
        rangoFechasSeleccionado!.end.month,
        rangoFechasSeleccionado!.end.day,
        23,
        59,
        59,
      );
    } else {
      // Filtros estándar
      switch (filtroSeleccionado) {
        case 'Mensual':
          fechaInicio = DateTime(fechaFin.year, fechaFin.month, 1);
          break;
        case 'Anual':
          fechaInicio = DateTime(fechaFin.year, 1, 1);
          break;
        case 'Semanal':
        default:
          // Lógica para el lunes de esta semana
          int daysToSubtract = fechaFin.weekday - DateTime.monday;
          if (daysToSubtract < 0) {
            daysToSubtract += 7; // Si hoy es domingo (7), resta 6 días
          }
          fechaInicio = fechaFin.subtract(Duration(days: daysToSubtract));
          fechaInicio = DateTime(
            fechaInicio.year,
            fechaInicio.month,
            fechaInicio.day,
          ); // Empieza a las 00:00 del lunes
          break;
      }
    }

    // Asegura que la fecha de inicio no sea posterior a la de fin
    if (fechaInicio.isAfter(fechaFin)) {
      fechaInicio = DateTime(fechaFin.year, fechaFin.month, fechaFin.day);
    }

    // 2. Carga y procesa los datos
    try {
      List<Cita> citasReales = await _simularDatosDB(fechaInicio, fechaFin);
      // 3. Filtra los datos obtenidos
      final citasCanceladas =
          citasReales.where((c) => c.estado == 'Cancelada').toList();
      final citasRealizadas =
          citasReales.where((c) => c.estado == 'Realizada').toList();
      // 4. Agrupa los datos para las gráficas
      datosGraficaCancelaciones = _agruparDatosParaGrafica(
        citasCanceladas,
        fechaInicio,
        fechaFin,
        filtroSeleccionado,
      );
      datosGraficaCitas = _agruparDatosParaGrafica(
        citasRealizadas,
        fechaInicio,
        fechaFin,
        filtroSeleccionado,
      );
      // 5. Actualiza los textos de resumen
      _actualizarTextosResumen(
        citasCanceladas,
        citasRealizadas,
        filtroSeleccionado,
        fechaInicio, // Pasa la fecha de inicio para las etiquetas
      );
    } catch (e) {
      datoPrincipalCancelaciones = "Error al cargar datos";
      datoSecundarioCancelaciones = "Revisa la conexión o la base de datos";
      datoPrincipalCitas = "Error al cargar datos";
      datoSecundarioCitas = "";
      datosGraficaCancelaciones = [];
      datosGraficaCitas = [];
    }

    _isLoading = false;
    notifyListeners();
    // Notifica a la UI que se redibuje
  }

  // --- MÉTODOS INTERNOS ---

  // Convierte una List<Cita> en una List<FlSpot> para la gráfica.
  List<FlSpot> _agruparDatosParaGrafica(
    List<Cita> citas,
    DateTime fechaInicio,
    DateTime fechaFin,
    String filtro,
  ) {
    if (citas.isEmpty) return [];
    if (filtro == 'Anual') {
      // Agrupa por mes (1 a 12)
      final gruposPorMes = groupBy(citas, (c) => c.fecha.month);
      // Genera 12 puntos (spots), uno por cada mes (índice 0 = Ene, 11 = Dic)
      return List.generate(12, (indexMes) {
        int mes = indexMes + 1;
        int total = gruposPorMes[mes]?.length ?? 0;
        return FlSpot(indexMes.toDouble(), total.toDouble());
      });
    }

    // Agrupa por día para 'Semanal', 'Mensual' o 'Personalizado'
    int numDias = fechaFin.difference(fechaInicio).inDays + 1;
    // Evita numDias negativo si el rango es de un solo día
    if (numDias <= 0) numDias = 1;

    final gruposPorDia = <int, int>{};

    for (var cita in citas) {
      // Asegura que la cita esté dentro del rango
      if (cita.fecha.isBefore(fechaInicio) || cita.fecha.isAfter(fechaFin)) {
        continue;
      }
      int diaIndex = cita.fecha.difference(fechaInicio).inDays;
      if (diaIndex >= 0 && diaIndex < numDias) {
        gruposPorDia.update(diaIndex, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    // Genera un punto por cada día en el rango
    return List.generate(numDias, (indexDia) {
      double total = (gruposPorDia[indexDia] ?? 0).toDouble();
      return FlSpot(indexDia.toDouble(), total);
    });
  }

  // Calcula los textos de resumen (totales y picos).
  void _actualizarTextosResumen(
    List<Cita> canceladas,
    List<Cita> realizadas,
    String filtro,
    DateTime fechaInicio,
  ) {
    datoPrincipalCancelaciones = "Total Cancelaciones: ${canceladas.length}";
    datoPrincipalCitas = "Total Citas: ${realizadas.length}";

    if (datosGraficaCancelaciones.isNotEmpty) {
      final picoCancel = datosGraficaCancelaciones.reduce(
        (a, b) => a.y > b.y ? a : b,
      );
      String etiquetaPico = _getEtiquetaPico(
        picoCancel.x.toInt(),
        filtro,
        fechaInicio,
      );
      datoSecundarioCancelaciones =
          "Pico: $etiquetaPico (${picoCancel.y.toInt()})";
    } else {
      datoSecundarioCancelaciones = "Pico: N/A (0)";
    }

    if (datosGraficaCitas.isNotEmpty) {
      final picoCitas = datosGraficaCitas.reduce((a, b) => a.y > b.y ? a : b);
      String etiquetaPico = _getEtiquetaPico(
        picoCitas.x.toInt(),
        filtro,
        fechaInicio,
      );
      datoSecundarioCitas = "Pico: $etiquetaPico (${picoCitas.y.toInt()})";
    } else {
      datoSecundarioCitas = "Pico: N/A (0)";
    }
  }

  // Helper para formatear la etiqueta del eje X (ej. 'Lun', 'Ene', 'Día 5').
  String _getEtiquetaPico(int index, String filtro, DateTime fechaInicio) {
    switch (filtro) {
      case 'Anual':
        const meses = [
          'Ene',
          'Feb',
          'Mar',
          'Abr',
          'May',
          'Jun',
          'Jul',
          'Ago',
          'Sep',
          'Oct',
          'Nov',
          'Dic',
        ];
        return (index >= 0 && index < 12) ? meses[index] : 'N/A';
      case 'Semanal':
        const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
        return (index >= 0 && index < 7) ? dias[index] : 'N/A';
      case 'Personalizado':
      case 'Mensual':
      default:
        // Muestra la fecha real, ej: "05/11"
        try {
          final fecha = fechaInicio.add(Duration(days: index));
          return DateFormat('dd/MM').format(fecha);
        } catch (e) {
          return 'Día ${index + 1}';
        }
    }
  }

  // --- FUNCIÓN DE SIMULACIÓN (REEMPLAZAR) ---
  Future<List<Cita>> _simularDatosDB(DateTime inicio, DateTime fin) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Simula espera de red

    List<Cita> citasSimuladas = [];
    final random = Random();
    int numDias = max(1, fin.difference(inicio).inDays + 1);

    for (int i = 0; i < numDias; i++) {
      DateTime diaActual = inicio.add(Duration(days: i));
      // Simula horas aleatorias
      int horaRandom = 8 + random.nextInt(10); // Entre 8am y 5pm

      int numCanceladas = random.nextInt(4);
      for (int c = 0; c < numCanceladas; c++) {
        citasSimuladas.add(
          Cita(
            id: i * 100 + c,
            fecha: diaActual.add(Duration(hours: horaRandom + c)),
            estado: 'Cancelada',
          ),
        );
      }

      int numRealizadas = 5 + random.nextInt(10);
      for (int r = 0; r < numRealizadas; r++) {
        citasSimuladas.add(
          Cita(
            id: i * 200 + r,
            fecha: diaActual.add(Duration(hours: horaRandom + r)),
            estado: 'Realizada',
          ),
        );
      }
    }
    return citasSimuladas;
  }
}
