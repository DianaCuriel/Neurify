import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../modelos/estadisticas_modelo.dart';
import '../Fijo/app_theme.dart';
import '../Fijo/AppBar.dart';
import '../Fijo/BottomNavigator.dart';

class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  /// Muestra el selector de rango de fechas nativo.
  Future<void> _mostrarSelectorFecha() async {
    // context.read() se usa para llamar un método, no para escuchar cambios.
    final modelo = context.read<EstadisticasModelo>();

    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: modelo.rangoFechasSeleccionado,
      builder: (context, child) {
        // Aplica el tema personalizado al DatePicker
        return Theme(
          data: ThemeData.light().copyWith(
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    // Si el usuario selecciona un rango, actualiza el modelo.
    if (newDateRange != null) {
      modelo.setRangoPersonalizado(newDateRange);
    }
  }

  /// Función llamada por el FloatingActionButton para refrescar los datos.
  void _recargarEstadisticas() {
    context.read<EstadisticasModelo>().cargarDatosActuales();
  }

  @override
  Widget build(BuildContext context) {
    // context.watch() escucha los cambios en el modelo y redibuja la UI.
    final modelo = context.watch<EstadisticasModelo>();

    return Scaffold(
      appBar: MiAppBar(title: 'Estadísticas'),
      backgroundColor: Colors.grey[100],

      // Se usa un Stack para poder mostrar un indicador de carga
      // superpuesto encima del contenido de la lista.
      body: Stack(
        children: [
          // El contenido principal de la página
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Barra de filtros (Dropdown y Calendario)
              AbsorbPointer(
                // Bloquea la interacción con los filtros mientras está cargando
                absorbing: modelo.isLoading,
                child: _buildBarraFiltros(modelo),
              ),
              const SizedBox(height: 16),

              // Título con el rango de fechas actual
              Text(
                modelo.tituloFecha,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),

              // Tarjeta de estadísticas de Cancelaciones
              _buildTarjetaEstadistica(
                titulo: 'Cancelaciones',
                datoPrincipal: modelo.datoPrincipalCancelaciones,
                datoSecundario: modelo.datoSecundarioCancelaciones,
                datosGrafica: modelo.datosGraficaCancelaciones,
                colorGrafica: Colors.red,
                filtro: modelo.filtroSeleccionado,
              ),
              const SizedBox(height: 16),

              // Tarjeta de estadísticas de Citas Realizadas
              _buildTarjetaEstadistica(
                titulo: 'Citas realizadas',
                datoPrincipal: modelo.datoPrincipalCitas,
                datoSecundario: modelo.datoSecundarioCitas,
                datosGrafica: modelo.datosGraficaCitas,
                colorGrafica: Colors.blue,
                filtro: modelo.filtroSeleccionado,
              ),
            ],
          ),

          // --- Indicador de Carga (Loader) ---
          // Se muestra solo si modelo.isLoading es true
          if (modelo.isLoading)
            Container(
              // Fondo semitransparente para atenuar la UI
              color: Colors.black.withAlpha((0.1 * 255).round()),
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
            ),
        ],
      ),

      bottomNavigationBar: const MiBottomNav(),

      floatingActionButton: FloatingActionButton(
        // Deshabilita el botón si está cargando (onPressed: null)
        onPressed: modelo.isLoading ? null : _recargarEstadisticas,
        tooltip: 'Actualizar Estadísticas',
        backgroundColor: modelo.isLoading ? Colors.grey : AppTheme.primaryColor,
        child:
            modelo.isLoading
                // Muestra un spinner DENTRO del botón si está cargando
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
                // Muestra el ícono de refrescar si no está cargando
                : const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  // --- Widgets Auxiliares ---

  /// Construye la fila superior con el Dropdown y el ícono de calendario.
  Widget _buildBarraFiltros(EstadisticasModelo modelo) {
    return Row(
      children: [
        Expanded(
          // Dropdown de filtros predefinidos
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
                // Si el filtro es 'Personalizado', muestra el 'hint'.
                // Si no, muestra el valor seleccionado.
                value:
                    (modelo.filtroSeleccionado == 'Personalizado')
                        ? null
                        : modelo.filtroSeleccionado,
                hint: const Text('Rango Personalizado'),
                isExpanded: true,
                items:
                    <String>['Semanal', 'Mensual', 'Anual']
                        .map(
                          (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    modelo.setFiltro(newValue); // Llama al modelo
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Botón de ícono para el calendario
        InkWell(
          onTap: _mostrarSelectorFecha, // Llama al selector de fechas
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

  /// Construye una tarjeta individual de estadística (ej. Cancelaciones).
  Widget _buildTarjetaEstadistica({
    required String titulo,
    required String datoPrincipal,
    required String datoSecundario,
    required List<FlSpot> datosGrafica,
    required Color colorGrafica,
    required String filtro,
  }) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título (ej. "Cancelaciones")
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),

            // Textos de resumen
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

            // Contenedor de la gráfica
            SizedBox(
              height: 120,
              child:
                  datosGrafica.isEmpty
                      // Muestra un mensaje si no hay datos
                      ? const Center(child: Text('No hay datos para mostrar'))
                      // Dibuja la gráfica si hay datos
                      : LineChart(
                        LineChartData(
                          // Configuración de la cuadrícula
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            drawHorizontalLine: true,
                            getDrawingHorizontalLine:
                                (value) => FlLine(
                                  color: Colors.grey.shade300,
                                  strokeWidth: 0.5,
                                ),
                            getDrawingVerticalLine:
                                (value) => FlLine(
                                  color: Colors.grey.shade300,
                                  strokeWidth: 0.5,
                                ),
                          ),
                          // Configuración de los títulos de los ejes (X, Y)
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),

                            // Eje Inferior (X)
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                // Lógica para mostrar las etiquetas (L, M, X... o 1, 5, 10...)
                                getTitlesWidget: (value, meta) {
                                  String texto;
                                  final int index = value.toInt();
                                  switch (filtro) {
                                    case 'Semanal':
                                      const dias = [
                                        'L',
                                        'M',
                                        'X',
                                        'J',
                                        'V',
                                        'S',
                                        'D',
                                      ];
                                      texto =
                                          (index >= 0 && index < dias.length)
                                              ? dias[index]
                                              : '';
                                      break;
                                    case 'Anual':
                                      const meses = [
                                        'E',
                                        'F',
                                        'M',
                                        'A',
                                        'M',
                                        'J',
                                        'J',
                                        'A',
                                        'S',
                                        'O',
                                        'N',
                                        'D',
                                      ];
                                      texto =
                                          (index >= 0 && index < meses.length)
                                              ? meses[index]
                                              : '';
                                      break;
                                    default: // Mensual o Personalizado
                                      // Muestra etiquetas de forma inteligente para evitar superposición
                                      int maxDias =
                                          (filtro == 'Personalizado')
                                              ? meta.max.toInt()
                                              : 30;
                                      int intervalo =
                                          (maxDias <= 10)
                                              ? 1
                                              : (maxDias <= 35)
                                              ? 5
                                              : 7;
                                      texto =
                                          (index == 0 ||
                                                  (index + 1) % intervalo == 0)
                                              ? (index + 1).toString()
                                              : '';
                                  }
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    space: 4.0,
                                    child: Text(
                                      texto,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Eje Izquierdo (Y)
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  // No dibuja etiqueta en el 0 o en el máximo
                                  if (value <= meta.min || value == meta.max) {
                                    return Container();
                                  }
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.left,
                                  );
                                },
                                // Calcula un intervalo automático para el eje Y
                                interval: _calcularIntervaloY(datosGrafica),
                              ),
                            ),
                          ),
                          // Borde de la gráfica
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 0.5,
                            ),
                          ),
                          // Datos de la línea
                          lineBarsData: [
                            LineChartBarData(
                              spots: datosGrafica,
                              isCurved: true,
                              color: colorGrafica,
                              barWidth: 3,
                              dotData: const FlDotData(
                                show: false,
                              ), // Oculta los puntos
                              // Relleno de área bajo la línea
                              belowBarData: BarAreaData(
                                show: true,
                                color: colorGrafica.withAlpha(50),
                              ),
                            ),
                          ],
                          minY: 0, // El eje Y siempre empieza en 0
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  double _calcularIntervaloY(List<FlSpot> datos) {
    if (datos.isEmpty) return 1;
    double maxVal = 0;
    for (var spot in datos) {
      if (spot.y > maxVal) maxVal = spot.y;
    }

    if (maxVal == 0) return 1;
    if (maxVal <= 5) return 1;
    if (maxVal <= 10) return 2;
    if (maxVal <= 20) return 5;
    if (maxVal <= 50) return 10;
    if (maxVal <= 100) return 20;
    return (maxVal / 5).ceilToDouble();
  }
}
