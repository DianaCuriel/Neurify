import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Needed for DateFormat

class EstadisticasModelo extends ChangeNotifier {
  // --- STATE ---
  String filtroSeleccionado = 'Semanal';
  DateTimeRange? rangoFechasSeleccionado;
  List<FlSpot> datosGraficaCancelaciones = [];
  List<FlSpot> datosGraficaCitas = [];
  String datoPrincipalCancelaciones = '';
  String datoSecundarioCancelaciones = '';
  String datoPrincipalCitas = '';
  String datoSecundarioCitas = '';

  // --- CONSTRUCTOR ---
  EstadisticasModelo() {
    // Load initial data when the model is created
    _cargarDatos();
  }

  // --- GETTERS ---
  // Formats the title based on the selected filter or date range
  String get tituloFecha {
    if (rangoFechasSeleccionado != null) {
      final formato = DateFormat('dd/MM/yyyy');
      // Asegura que start y end no sean nulos antes de formatear
      final startFormatted = formato.format(rangoFechasSeleccionado!.start);
      final endFormatted = formato.format(rangoFechasSeleccionado!.end);
      return '$startFormatted - $endFormatted';
    }
    return 'Resumen - $filtroSeleccionado';
  }

  // --- PUBLIC METHODS ---
  // Called when the dropdown filter changes
  void setFiltro(String nuevoFiltro) {
    // Avoid unnecessary reloads if the filter hasn't changed
    if (filtroSeleccionado == nuevoFiltro && rangoFechasSeleccionado == null) {
      return; // If same filter and no custom range, do nothing
    }
    filtroSeleccionado = nuevoFiltro;
    rangoFechasSeleccionado =
        null; // Clear custom range when selecting a preset filter
    _cargarDatos(); // Reload data with the new filter
  }

  // Called when a custom date range is selected
  void setRangoPersonalizado(DateTimeRange nuevoRango) {
    // Optional check to avoid reloading identical range selection
    if (rangoFechasSeleccionado != null &&
        rangoFechasSeleccionado!.start == nuevoRango.start &&
        rangoFechasSeleccionado!.end == nuevoRango.end) {
      return;
    }
    rangoFechasSeleccionado = nuevoRango;
    filtroSeleccionado =
        'Personalizado'; // Update filter state to reflect custom range
    _cargarDatos(
      rangoPersonalizado: nuevoRango,
    ); // Reload data with the custom range
  }

  // --- METHOD CALLED BY THE REFRESH BUTTON ---
  /// Reloads data based on the currently selected filter or date range.
  void cargarDatosActuales() {
    print(
      "Recargando datos con filtro: $filtroSeleccionado y rango: $rangoFechasSeleccionado",
    ); // Debug log
    // Simply call the internal loading method with the current range
    // It will be null if a preset filter ('Semanal', 'Mensual', etc.) is active,
    // which is what _cargarDatos expects in that case.
    _cargarDatos(rangoPersonalizado: rangoFechasSeleccionado);
  }
  // --- END OF ADDED METHOD ---

  // --- INTERNAL LOGIC ---
  // Simulates loading data based on the filter/range
  void _cargarDatos({DateTimeRange? rangoPersonalizado}) {
    final random = Random();
    List<FlSpot> cancelacionesTemp = [];
    List<FlSpot> citasTemp = [];
    String filtroAplicado = filtroSeleccionado; // Start with the current state

    // Determine the actual filter/range to use for loading
    if (rangoPersonalizado != null) {
      filtroAplicado = 'Personalizado';
      // Calculate number of days in the range, including the end date
      // Ensure positive duration even for same-day selection
      final dias = max(1, rangoPersonalizado.duration.inDays + 1);
      print("Cargando datos personalizados para $dias días."); // Debug log
      for (int i = 0; i < dias; i++) {
        // Generate random data points for each day in the range
        cancelacionesTemp.add(
          FlSpot(i.toDouble(), random.nextInt(6).toDouble()),
        ); // 0 to 5
        citasTemp.add(
          FlSpot(i.toDouble(), 5 + random.nextInt(11).toDouble()),
        ); // 5 to 15
      }
    } else {
      // Use the selected preset filter if no custom range is provided
      print("Cargando datos para filtro: $filtroAplicado"); // Debug log
      switch (filtroAplicado) {
        case 'Mensual':
          for (int i = 0; i < 30; i++) {
            cancelacionesTemp.add(
              FlSpot(i.toDouble(), random.nextInt(8).toDouble()),
            ); // 0 to 7
            citasTemp.add(
              FlSpot(i.toDouble(), 7 + random.nextInt(16).toDouble()),
            ); // 7 to 22
          }
          break;
        case 'Anual':
          for (int i = 0; i < 12; i++) {
            // Assuming 1 point per month
            cancelacionesTemp.add(
              FlSpot(i.toDouble(), 20 + random.nextInt(31).toDouble()),
            ); // 20 to 50
            citasTemp.add(
              FlSpot(i.toDouble(), 60 + random.nextInt(81).toDouble()),
            ); // 60 to 140
          }
          break;
        case 'Semanal':
        default: // Default to 'Semanal' if filter is unrecognized
          filtroAplicado = 'Semanal'; // Ensure filterAplicado reflects this
          for (int i = 0; i < 7; i++) {
            cancelacionesTemp.add(
              FlSpot(i.toDouble(), random.nextInt(6).toDouble()),
            ); // 0 to 5
            citasTemp.add(
              FlSpot(i.toDouble(), 5 + random.nextInt(11).toDouble()),
            ); // 5 to 15
          }
      }
    }

    // Update the model's state variables
    datosGraficaCancelaciones = cancelacionesTemp;
    datosGraficaCitas = citasTemp;
    _actualizarTextosResumen(
      filtroAplicado,
    ); // Update summary text based on the loaded filter

    // Notify listeners (the UI) that the data has changed and it should rebuild
    notifyListeners();
    print("Datos cargados y UI notificada."); // Debug log
  }

  // Updates the summary text strings based on the loaded data/filter
  void _actualizarTextosResumen(String filtroAplicado) {
    if (filtroAplicado == 'Personalizado') {
      // Example calculations for custom range (replace with real logic if needed)
      final totalCancelaciones =
          datosGraficaCancelaciones
              .fold<double>(0, (prev, e) => prev + e.y)
              .toInt();
      final totalCitas =
          datosGraficaCitas.fold<double>(0, (prev, e) => prev + e.y).toInt();
      datoPrincipalCancelaciones =
          'Rango: $tituloFecha'; // Use the getter for formatted dates
      datoSecundarioCancelaciones = 'Total Cancelaciones: $totalCancelaciones';
      datoPrincipalCitas = 'Rango: $tituloFecha';
      datoSecundarioCitas = 'Total Citas: $totalCitas';
    } else {
      // Placeholder/Example texts for preset filters
      // In a real app, you would calculate these based on the loaded data
      switch (filtroAplicado) {
        case 'Mensual':
          datoPrincipalCancelaciones = 'Pico cancelaciones mes: Día 15 (Ej.)';
          datoSecundarioCancelaciones = 'Valle cancelaciones mes: Día 3 (Ej.)';
          datoPrincipalCitas = 'Pico citas mes: Día 28 (Ej.)';
          datoSecundarioCitas = 'Valle citas mes: Día 1 (Ej.)';
          break;
        case 'Anual':
          datoPrincipalCancelaciones = 'Pico cancelaciones año: Dic (Ej.)';
          datoSecundarioCancelaciones = 'Valle cancelaciones año: Feb (Ej.)';
          datoPrincipalCitas = 'Pico citas año: Nov (Ej.)';
          datoSecundarioCitas = 'Valle citas año: Jun (Ej.)';
          break;
        case 'Semanal':
        default:
          datoPrincipalCancelaciones = 'Pico cancelaciones sem: Jue (Ej.)';
          datoSecundarioCancelaciones = 'Valle cancelaciones sem: Mar (Ej.)';
          datoPrincipalCitas = 'Pico citas sem: Sáb (Ej.)';
          datoSecundarioCitas = 'Valle citas sem: Mié (Ej.)';
      }
    }
    // No need to call notifyListeners() here, as it's called at the end of _cargarDatos
  }
} // End of EstadisticasModelo class
