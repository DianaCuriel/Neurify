import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart'; // Para la función groupBy
import 'package:intl/intl.dart';

// Modelo de datos para una Cita de la BBDD.
class Cita {
  final int id;
  final DateTime fecha;
  final String estado; // 'Realizada', 'Cancelada', 'Pendiente', etc.

  Cita({required this.id, required this.fecha, required this.estado});

  // Constructor para crear desde un Map de la BBDD.
  factory Cita.fromMap(Map<String, dynamic> map) {
    return Cita(
      id: map['id_citas'],
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
  List<FlSpot> datosGraficaCancelaciones = []; // Puntos (X, Y) para la gráfica
  List<FlSpot> datosGraficaCitas = [];
  String datoPrincipalCancelaciones = ''; // Textos de resumen
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
    notifyListeners(); // Notifica a la UI que empiece a mostrar el loader

    // 1. Determina el rango de fechas para la consulta
    DateTime fechaFin = DateTime.now();
    DateTime fechaInicio;

    if (rangoFechasSeleccionado != null) {
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
      switch (filtroSeleccionado) {
        case 'Mensual':
          fechaInicio = DateTime(fechaFin.year, fechaFin.month, 1);
          break;
        case 'Anual':
          fechaInicio = DateTime(fechaFin.year, 1, 1);
          break;
        case 'Semanal':
        default:
          fechaInicio = fechaFin.subtract(Duration(days: fechaFin.weekday - 1));
          fechaInicio = DateTime(
            fechaInicio.year,
            fechaInicio.month,
            fechaInicio.day,
          );
          break;
      }
    }

    if (fechaInicio.isAfter(fechaFin)) {
      fechaInicio = DateTime(fechaFin.year, fechaFin.month, fechaFin.day);
    }

    // 2. Carga y procesa los datos
    try {
      //
      // *********************
      // TODO: Reemplaza esta sección con tu llamada a la base de datos
      // *********************
      //
      // Ejemplo:
      // List<Cita> citasReales = await TuDatabaseHelper.instance.getCitas(fechaInicio, fechaFin);
      //

      // --- Simulación de datos (BORRA ESTA LÍNEA CUANDO TENGAS DATOS REALES) ---
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
      );
    } catch (e) {
      print("Error al cargar estadísticas: $e");
      datoPrincipalCancelaciones = "Error al cargar datos";
      // ... (etc.)
    }

    _isLoading = false;
    notifyListeners(); // Notifica a la UI que se redibuje
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
      final gruposPorMes = groupBy(citas, (c) => c.fecha.month);
      return List.generate(12, (indexMes) {
        int mes = indexMes + 1;
        int total = gruposPorMes[mes]?.length ?? 0;
        return FlSpot(indexMes.toDouble(), total.toDouble());
      });
    }

    // Agrupa por día para 'Semanal', 'Mensual' o 'Personalizado'
    int numDias = fechaFin.difference(fechaInicio).inDays + 1;
    final gruposPorDia = <int, int>{};

    for (var cita in citas) {
      int diaIndex = cita.fecha.difference(fechaInicio).inDays;
      if (diaIndex >= 0 && diaIndex < numDias) {
        gruposPorDia.update(diaIndex, (value) => value + 1, ifAbsent: () => 1);
      }
    }

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
  ) {
    datoPrincipalCancelaciones = "Total Cancelaciones: ${canceladas.length}";
    datoPrincipalCitas = "Total Citas: ${realizadas.length}";

    if (datosGraficaCancelaciones.isNotEmpty) {
      final picoCancel = datosGraficaCancelaciones.reduce(
        (a, b) => a.y > b.y ? a : b,
      );
      String etiquetaPico = _getEtiquetaPico(picoCancel.x.toInt(), filtro);
      datoSecundarioCancelaciones =
          "Pico: $etiquetaPico (${picoCancel.y.toInt()})";
    } else {
      datoSecundarioCancelaciones = "Pico: N/A (0)";
    }

    if (datosGraficaCitas.isNotEmpty) {
      final picoCitas = datosGraficaCitas.reduce((a, b) => a.y > b.y ? a : b);
      String etiquetaPico = _getEtiquetaPico(picoCitas.x.toInt(), filtro);
      datoSecundarioCitas = "Pico: $etiquetaPico (${picoCitas.y.toInt()})";
    } else {
      datoSecundarioCitas = "Pico: N/A (0)";
    }
  }

  // Helper para formatear la etiqueta del eje X (ej. 'Lun', 'Ene', 'Día 5').
  String _getEtiquetaPico(int index, String filtro) {
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
      default:
        return 'Día ${index + 1}';
    }
  }

  // --- FUNCIÓN DE SIMULACIÓN (REEMPLAZAR) ---
  Future<List<Cita>> _simularDatosDB(DateTime inicio, DateTime fin) async {
    await Future.delayed(const Duration(seconds: 1)); // Simula espera de red
    print("Simulando datos de DB desde $inicio hasta $fin");
    List<Cita> citasSimuladas = [];
    final random = Random();
    int numDias = max(1, fin.difference(inicio).inDays + 1);

    for (int i = 0; i < numDias; i++) {
      DateTime diaActual = inicio.add(Duration(days: i));
      int numCanceladas = random.nextInt(4);
      for (int c = 0; c < numCanceladas; c++) {
        citasSimuladas.add(
          Cita(id: i * 100 + c, fecha: diaActual, estado: 'Cancelada'),
        );
      }
      int numRealizadas = 5 + random.nextInt(10);
      for (int r = 0; r < numRealizadas; r++) {
        citasSimuladas.add(
          Cita(id: i * 200 + r, fecha: diaActual, estado: 'Realizada'),
        );
      }
    }
    return citasSimuladas;
  }
}
