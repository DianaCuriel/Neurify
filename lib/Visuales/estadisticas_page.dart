import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import 'dart:math'; // Para generar datos de ejemplo aleatorios

import '../Fijo/app_theme.dart';
import '../Fijo/AppBar.dart';

class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  // --- ESTADO DE LA PÁGINA ---
  String _filtroSeleccionado = 'Semanal';
  DateTimeRange? _rangoFechasSeleccionado;

  // Los datos de las gráficas ahora están en el estado para poder cambiarlos
  List<FlSpot> _datosGraficaCancelaciones = [];
  List<FlSpot> _datosGraficaCitas = [];

  // Los textos de resumen también están en el estado
  String _datoPrincipalCancelaciones = '';
  String _datoSecundarioCancelaciones = '';
  String _datoPrincipalCitas = '';
  String _datoSecundarioCitas = '';

  @override
  void initState() {
    super.initState();
    // Cargar los datos iniciales para la vista "Semanal" al abrir la página
    _cargarDatos();
  }

  // --- LÓGICA DE DATOS ---

  // Simula la carga de datos según el filtro seleccionado
  void _cargarDatos({DateTimeRange? rangoPersonalizado}) {
    final random = Random();
    List<FlSpot> cancelacionesTemp = [];
    List<FlSpot> citasTemp = [];
    String filtro = _filtroSeleccionado;

    // Si hay un rango personalizado, se ignora el filtro del dropdown
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

    // Actualiza el estado con los nuevos datos, lo que redibuja la pantalla
    setState(() {
      _datosGraficaCancelaciones = cancelacionesTemp;
      _datosGraficaCitas = citasTemp;
      // Aquí podrías calcular los días con más/menos citas de verdad,
      // por ahora, usamos textos de ejemplo que cambian con el filtro.
      _actualizarTextosResumen(filtro);
    });
  }

  void _actualizarTextosResumen(String filtro) {
    if (filtro == 'Personalizado') return; // En un caso real, se calcularía

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

  // --- MANEJADORES DE EVENTOS ---

  // Muestra el selector de rango de fechas
  Future<void> _mostrarSelectorFecha() async {
    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _rangoFechasSeleccionado,
    );

    if (newDateRange != null) {
      setState(() {
        _rangoFechasSeleccionado = newDateRange;
        // Al seleccionar fechas, cambiamos el filtro a 'Personalizado' y cargamos datos
        _filtroSeleccionado = 'Personalizado';
      });
      _cargarDatos(rangoPersonalizado: newDateRange);
    }
  }

  String _getTituloFecha() {
    if (_rangoFechasSeleccionado != null) {
      final formato = DateFormat('dd/MM/yyyy');
      return '${formato.format(_rangoFechasSeleccionado!.start)} - ${formato.format(_rangoFechasSeleccionado!.end)}';
    }
    return 'Resumen - $_filtroSeleccionado';
  }

  // --- CONSTRUCCIÓN DE LA UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MiAppBar(title: 'Estadísticas'),
      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildBarraFiltros(),
          const SizedBox(height: 16),
          Text(
            _getTituloFecha(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildTarjetaEstadistica(
            titulo: 'Cancelaciones',
            datoPrincipal: _datoPrincipalCancelaciones,
            datoSecundario: _datoSecundarioCancelaciones,
            datosGrafica: _datosGraficaCancelaciones,
            colorGrafica: Colors.red,
          ),
          const SizedBox(height: 16),
          _buildTarjetaEstadistica(
            titulo: 'Citas realizadas',
            datoPrincipal: _datoPrincipalCitas,
            datoSecundario: _datoSecundarioCitas,
            datosGrafica: _datosGraficaCitas,
            colorGrafica: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildBarraFiltros() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value:
                    (_filtroSeleccionado == 'Personalizado')
                        ? null
                        : _filtroSeleccionado,
                hint: const Text('Rango Personalizado'),
                isExpanded: true,
                items:
                    <String>['Semanal', 'Mensual', 'Anual'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _filtroSeleccionado = newValue;
                      _rangoFechasSeleccionado =
                          null; // Limpiar rango personalizado
                    });
                    _cargarDatos(); // Recargar datos con el nuevo filtro
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        InkWell(
          onTap: _mostrarSelectorFecha, // Hace que el ícono sea funcional
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(Icons.calendar_month, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildTarjetaEstadistica({
    required String titulo,
    required String datoPrincipal,
    required String datoSecundario,
    required List<FlSpot> datosGrafica,
    required Color colorGrafica,
  }) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              datoPrincipal,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
            const SizedBox(height: 8),
            Text(
              datoSecundario,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child:
                  datosGrafica.isEmpty
                      ? const Center(child: Text('No hay datos para mostrar'))
                      : LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: datosGrafica,
                              isCurved: true,
                              color: colorGrafica,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: colorGrafica.withAlpha(77),
                              ),
                            ),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
