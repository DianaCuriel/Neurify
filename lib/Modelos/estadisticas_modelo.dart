// lib/modelos/estadisticas_modelo.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// 1. Usamos ChangeNotifier para poder "notificar" a los widgets que escuchan
class EstadisticasModelo with ChangeNotifier {
  // --- ESTADO (LOS DATOS) ---
  // Todas las variables de estado ahora viven aquí
  String _filtroSeleccionado = 'Semanal';
  DateTimeRange? _rangoFechasSeleccionado;

  List<FlSpot> _datosGraficaCancelaciones = [];
  List<FlSpot> _datosGraficaCitas = [];

  String _datoPrincipalCancelaciones = '';
  String _datoSecundarioCancelaciones = '';
  String _datoPrincipalCitas = '';
  String _datoSecundarioCitas = '';

  // --- GETTERS (Para que la vista lea los datos) ---
  String get filtroSeleccionado => _filtroSeleccionado;
  List<FlSpot> get datosGraficaCancelaciones => _datosGraficaCancelaciones;
  List<FlSpot> get datosGraficaCitas => _datosGraficaCitas;
  String get datoPrincipalCancelaciones => _datoPrincipalCancelaciones;
  String get datoSecundarioCancelaciones => _datoSecundarioCancelaciones;
  String get datoPrincipalCitas => _datoPrincipalCitas;
  String get datoSecundarioCitas => _datoSecundarioCitas;

  String get tituloFecha {
    if (_rangoFechasSeleccionado != null) {
      final formato = DateFormat('dd/MM/yyyy');
      return '${formato.format(_rangoFechasSeleccionado!.start)} - ${formato.format(_rangoFechasSeleccionado!.end)}';
    }
    return 'Resumen - $_filtroSeleccionado';
  }

  // --- CONSTRUCTOR ---
  EstadisticasModelo() {
    // Cargar los datos iniciales al crear el modelo
    _cargarDatos();
  }

  // --- LÓGICA DE DATOS (Las funciones que estaban en el State) ---

  void _cargarDatos({DateTimeRange? rangoPersonalizado}) {
    final random = Random();
    List<FlSpot> cancelacionesTemp = [];
    List<FlSpot> citasTemp = [];
    String filtro = _filtroSeleccionado;

    if (rangoPersonalizado != null) {
      filtro = 'Personalizado';
      final dias = rangoPersonalizado.duration.inDays;
      for (int i = 0; i < dias; i++) {
        cancelacionesTemp.add(
          FlSpot(i.toDouble(), random.nextInt(5).toDouble()),
        );
        citasTemp.add(FlSpot(i.toDouble(), 5 + random.nextInt(10).toDouble()));
      }
    } else {
      switch (filtro) {
        case 'Mensual':
          for (int i = 0; i < 30; i++) {
            cancelacionesTemp.add(
              FlSpot(i.toDouble(), random.nextInt(7).toDouble()),
            );
            citasTemp.add(
              FlSpot(i.toDouble(), 7 + random.nextInt(15).toDouble()),
            );
          }
          break;
        case 'Anual':
          for (int i = 0; i < 12; i++) {
            cancelacionesTemp.add(
              FlSpot(i.toDouble(), 20 + random.nextInt(30).toDouble()),
            );
            citasTemp.add(
              FlSpot(i.toDouble(), 60 + random.nextInt(80).toDouble()),
            );
          }
          break;
        case 'Semanal':
        default:
          for (int i = 0; i < 7; i++) {
            cancelacionesTemp.add(
              FlSpot(i.toDouble(), random.nextInt(5).toDouble()),
            );
            citasTemp.add(
              FlSpot(i.toDouble(), 5 + random.nextInt(10).toDouble()),
            );
          }
      }
    }

    _datosGraficaCancelaciones = cancelacionesTemp;
    _datosGraficaCitas = citasTemp;
    _actualizarTextosResumen(filtro);

    // 2. Notificar a todos los widgets que escuchan que los datos cambiaron
    notifyListeners();
  }

  void _actualizarTextosResumen(String filtro) {
    // ... (Esta función es idéntica a la que tenías)
    if (filtro == 'Personalizado') return;

    switch (filtro) {
      case 'Mensual':
        _datoPrincipalCancelaciones = 'Día con más cancelaciones del mes: 15';
        _datoSecundarioCancelaciones = 'Día con menos cancelaciones del mes: 3';
        _datoPrincipalCitas = 'Día con más citas del mes: 28';
        _datoSecundarioCitas = 'Día con menos citas del mes: 1';
        break;
      case 'Anual':
        _datoPrincipalCancelaciones = 'Mes con más cancelaciones: Diciembre';
        _datoSecundarioCancelaciones = 'Mes con menos cancelaciones: Febrero';
        _datoPrincipalCitas = 'Mes con más citas: Noviembre';
        _datoSecundarioCitas = 'Mes con menos citas: Junio';
        break;
      case 'Semanal':
      default:
        _datoPrincipalCancelaciones =
            'Día con más cancelaciones de la semana: Jueves';
        _datoSecundarioCancelaciones =
            'Día con menos cancelaciones de la semana: Martes';
        _datoPrincipalCitas = 'Día con más citas de la semana: Sábado';
        _datoSecundarioCitas = 'Día con menos citas de la semana: Miércoles';
    }
  }

  // --- MÉTODOS DE ACCIÓN (Llamados desde la vista) ---

  // La vista llama a esta función cuando se selecciona un nuevo filtro
  void actualizarFiltro(String newValue) {
    _filtroSeleccionado = newValue;
    _rangoFechasSeleccionado = null; // Limpiar rango personalizado
    _cargarDatos();
  }

  // La vista llama a esta función cuando se selecciona un rango de fechas
  void actualizarFiltroPersonalizado(DateTimeRange newDateRange) {
    _rangoFechasSeleccionado = newDateRange;
    _filtroSeleccionado = 'Personalizado';
    _cargarDatos(rangoPersonalizado: newDateRange);
  }
}
