import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../modelos/estadisticas_modelo.dart';
import '../Fijo/app_theme.dart';
import '../Fijo/AppBar.dart'; // Asegúrate que el nombre del archivo sea correcto (AppBar.dart o Appbar.dart?)
import '../Fijo/BottomNavigator.dart'; // Asegúrate que esta es la ruta y nombre correctos

class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  // Función para mostrar el selector de rango de fechas
  Future<void> _mostrarSelectorFecha() async {
    final modelo = context.read<EstadisticasModelo>();

    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: modelo.rangoFechasSeleccionado,
      builder: (context, child) {
        // Aplica el tema al selector de fechas
        return Theme(
          data: ThemeData.light().copyWith(
            dialogTheme: const DialogThemeData(
              // Corrección para propiedad obsoleta
              backgroundColor: Colors.white,
            ),
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor, // Color del header
              onPrimary: Colors.white, // Texto del header
              onSurface: Colors.black87, // Texto de las fechas
            ),
          ),
          child: child!,
        );
      },
    );

    // Si el usuario selecciona un rango, actualiza el modelo
    if (newDateRange != null) {
      modelo.setRangoPersonalizado(newDateRange);
    }
  }

  // Función llamada por el FloatingActionButton para refrescar los datos
  void _recargarEstadisticas() {
    final modelo = context.read<EstadisticasModelo>();
    // Llama al método en el modelo (¡ASEGÚRATE QUE EXISTA!)
    modelo.cargarDatosActuales();

    // Muestra un mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Estadísticas actualizadas.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escucha los cambios en el modelo para redibujar la UI
    final modelo = context.watch<EstadisticasModelo>();

    return Scaffold(
      appBar: MiAppBar(title: 'Estadísticas'),
      backgroundColor: Colors.grey[100],
      body: ListView(
        // Permite scroll si el contenido es largo
        padding: const EdgeInsets.all(16.0),
        children: [
          // Barra superior con filtros
          _buildBarraFiltros(modelo),
          const SizedBox(height: 16),
          // Título que muestra el filtro o rango actual
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
          // Tarjeta para las estadísticas de Cancelaciones
          _buildTarjetaEstadistica(
            titulo: 'Cancelaciones',
            datoPrincipal: modelo.datoPrincipalCancelaciones,
            datoSecundario: modelo.datoSecundarioCancelaciones,
            datosGrafica: modelo.datosGraficaCancelaciones,
            colorGrafica: Colors.red,
            filtro: modelo.filtroSeleccionado,
          ),
          const SizedBox(height: 16),
          // Tarjeta para las estadísticas de Citas Realizadas
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
      // Barra de navegación inferior
      bottomNavigationBar: const MiBottomNav(
        currentIndex: 2,
      ), // Usa tu widget personalizado
      // Botón flotante para recargar
      floatingActionButton: FloatingActionButton(
        onPressed: _recargarEstadisticas, // Llama a la función de recarga
        tooltip: 'Actualizar Estadísticas',
        backgroundColor: AppTheme.primaryColor, // Color del botón
        child: const Icon(
          Icons.refresh,
          color: Colors.white,
        ), // Ícono de refrescar
      ),
    );
  }

  // --- Widgets Auxiliares ---

  // Construye la barra de filtros (Dropdown + Ícono Calendario)
  Widget _buildBarraFiltros(EstadisticasModelo modelo) {
    return Row(
      children: [
        Expanded(
          // Dropdown ocupa el espacio disponible
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              // Estilo del contenedor del dropdown
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              // Quita la línea de abajo
              child: DropdownButton<String>(
                value:
                    (modelo.filtroSeleccionado == 'Personalizado')
                        ? null // Muestra el hint si hay rango personalizado
                        : modelo.filtroSeleccionado, // Muestra el filtro actual
                hint: const Text(
                  'Rango Personalizado',
                ), // Texto si no hay filtro seleccionado
                isExpanded: true, // Ocupa todo el ancho
                items:
                    <String>[
                          'Semanal',
                          'Mensual',
                          'Anual',
                        ] // Opciones del dropdown
                        .map(
                          (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                onChanged: (newValue) {
                  // Cuando se selecciona una opción
                  if (newValue != null) {
                    // Llama al método en el modelo para cambiar el filtro
                    context.read<EstadisticasModelo>().setFiltro(newValue);
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 16), // Espacio entre dropdown y calendario
        // Ícono de Calendario para abrir el selector de fechas
        InkWell(
          // Hace que el contenedor sea clickeable
          onTap: _mostrarSelectorFecha,
          borderRadius: BorderRadius.circular(
            8.0,
          ), // Borde redondeado para el efecto ripple
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              // Estilo del botón del ícono
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

  // Construye una tarjeta de estadística individual (Título, Texto, Gráfica)
  Widget _buildTarjetaEstadistica({
    required String titulo,
    required String datoPrincipal,
    required String datoSecundario,
    required List<FlSpot> datosGrafica,
    required Color colorGrafica,
    required String filtro, // Para formatear ejes de la gráfica
  }) {
    return Card(
      // Widget Card para elevación y bordes
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ), // Bordes redondeados
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Padding interno
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Alinea a la izquierda
          children: [
            // Título de la tarjeta
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
              height: 120, // Altura fija para la gráfica
              child:
                  datosGrafica.isEmpty
                      ? const Center(
                        child: Text('No hay datos para mostrar'),
                      ) // Mensaje si no hay datos
                      : LineChart(
                        // Widget de la gráfica de líneas
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
                          // Configuración de los títulos de los ejes
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ), // Oculta eje derecho
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ), // Oculta eje superior
                            // Eje Inferior (X)
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true, // Muestra etiquetas
                                reservedSize: 30, // Espacio para las etiquetas
                                // Función para generar las etiquetas (L,M,X... o 1,5,10...)
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
                                      texto =
                                          (index == 0 || (index + 1) % 5 == 0)
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
                                showTitles: true, // Muestra etiquetas
                                reservedSize: 40, // Espacio para los números
                                // Función para generar las etiquetas numéricas
                                getTitlesWidget: (value, meta) {
                                  // Evita dibujar etiquetas en los bordes min/max
                                  if (value <= meta.min || value >= meta.max) {
                                    return Container();
                                  }
                                  return Text(
                                    value
                                        .toInt()
                                        .toString(), // Muestra el número entero
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.left,
                                  );
                                },
                                // Calcula un intervalo adecuado para los números
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
                              spots: datosGrafica, // Puntos de datos
                              isCurved: true, // Línea curva
                              color: colorGrafica, // Color de la línea
                              barWidth: 3, // Grosor de la línea
                              isStrokeCapRound: true, // Extremos redondeados
                              dotData: const FlDotData(
                                show: false,
                              ), // No mostrar puntos
                              belowBarData: BarAreaData(
                                // Área bajo la línea
                                show: true,
                                color: colorGrafica.withAlpha(
                                  50,
                                ), // Color del área (transparente)
                              ),
                            ),
                          ],
                          // Límites del eje Y
                          minY: 0, // Siempre empezar en 0
                          // maxY: // Podrías calcular dinámicamente el máximo + un margen
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  // Función auxiliar para calcular un intervalo adecuado para el eje Y
  double _calcularIntervaloY(List<FlSpot> datos) {
    if (datos.isEmpty) return 1; // Intervalo mínimo si no hay datos
    double maxVal = 0;
    // Encuentra el valor Y máximo
    for (var spot in datos) {
      if (spot.y > maxVal) maxVal = spot.y;
    }
    // Define intervalos basados en el valor máximo para mejor legibilidad
    if (maxVal <= 10) return 2;
    if (maxVal <= 20) return 5;
    if (maxVal <= 50) return 10;
    if (maxVal <= 100) return 20;
    // Para valores mayores, intenta dividir en ~5 intervalos
    return (maxVal / 5).ceilToDouble();
  }
} // Fin de la clase _EstadisticasPageState
