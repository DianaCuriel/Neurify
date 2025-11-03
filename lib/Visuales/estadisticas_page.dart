import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

// Importa tu barra de navegación personalizada
import 'package:neurify/Fijo/BottomNavigator.dart';
import 'package:neurify/Fijo/Appbar.dart';

// Importa el modelo
import '../Modelos/estadisticas_modelo.dart';
// Importa tu tema para el color del botón
import 'package:neurify/Fijo/app_theme.dart'; // Asegúrate que este archivo exista

// ✅ Solución 3: El Provider se crea dentro de la página
class EstadisticasPage extends StatelessWidget {
  const EstadisticasPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Aquí se crea el provider local
    return ChangeNotifierProvider(
      create: (_) => EstadisticasModelo(),
      child: const _EstadisticasPageContent(),
    );
  }
}

// 🔹 Contenido interno (tu lógica original)
class _EstadisticasPageContent extends StatelessWidget {
  const _EstadisticasPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final modelo = context.watch<EstadisticasModelo>();

    return Scaffold(
      appBar: const MiAppBar(title: 'Estadísticas'),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FiltrosUI(),
            const SizedBox(height: 24),
            Text(
              modelo.tituloFecha,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (modelo.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Column(
                children: [
                  _StatCard(
                    titulo: "Citas Realizadas",
                    color: Colors.blue,
                    gradient: [Colors.blue.shade400, Colors.blue.shade100],
                    puntosGrafica: modelo.datosGraficaCitas,
                    textoPrincipal: modelo.datoPrincipalCitas,
                    textoSecundario: modelo.datoSecundarioCitas,
                  ),
                  const SizedBox(height: 16),
                  _StatCard(
                    titulo: "Citas Canceladas",
                    color: Colors.red,
                    gradient: [Colors.red.shade400, Colors.red.shade100],
                    puntosGrafica: modelo.datosGraficaCancelaciones,
                    textoPrincipal: modelo.datoPrincipalCancelaciones,
                    textoSecundario: modelo.datoSecundarioCancelaciones,
                  ),
                ],
              ),
          ],
        ),
      ),

      bottomNavigationBar: const MiBottomNav(
        currentIndex: 2, // aquí el índice de Estadísticas
      ),
    );
  }
}

// --- WIDGETS INTERNOS DE UI ---

class _FiltrosUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final modelo = context.read<EstadisticasModelo>();
    final filtroActual = context.select(
      (EstadisticasModelo m) => m.filtroSeleccionado,
    );

    return Column(
      children: [
        ToggleButtons(
          isSelected: [
            filtroActual == 'Semanal',
            filtroActual == 'Mensual',
            filtroActual == 'Anual',
          ],
          onPressed: (index) {
            if (index == 0) modelo.setFiltro('Semanal');
            if (index == 1) modelo.setFiltro('Mensual');
            if (index == 2) modelo.setFiltro('Anual');
          },
          borderRadius: BorderRadius.circular(8),
          constraints: BoxConstraints(
            minWidth: (MediaQuery.of(context).size.width - 40) / 3,
            minHeight: 40,
          ),
          children: const [Text('Semanal'), Text('Mensual'), Text('Anual')],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.calendar_today),
          label: const Text('Rango Personalizado'),
          style: OutlinedButton.styleFrom(
            foregroundColor:
                filtroActual == 'Personalizado'
                    ? Theme.of(context).primaryColor
                    : Colors.grey[700],
            side: BorderSide(
              color:
                  filtroActual == 'Personalizado'
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
            ),
          ),
          onPressed: () async {
            final rango = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              initialDateRange:
                  modelo.rangoFechasSeleccionado ??
                  DateTimeRange(
                    start: DateTime.now().subtract(const Duration(days: 7)),
                    end: DateTime.now(),
                  ),
            );
            if (rango != null) {
              modelo.setRangoPersonalizado(rango);
            }
          },
        ),
      ],
    );
  }
}

// --- Tarjeta de estadística con gráfica ---
class _StatCard extends StatelessWidget {
  final String titulo;
  final Color color;
  final List<Color> gradient;
  final String textoPrincipal;
  final String textoSecundario;
  final List<FlSpot> puntosGrafica;

  const _StatCard({
    super.key,
    required this.titulo,
    required this.color,
    required this.gradient,
    required this.textoPrincipal,
    required this.textoSecundario,
    required this.puntosGrafica,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              height: 150,
              child:
                  puntosGrafica.isEmpty
                      ? const Center(
                        child: Text("No hay datos para este rango."),
                      )
                      : LineChart(_buildGradientChartData(context)),
            ),
            const SizedBox(height: 16),
            Text(
              textoPrincipal,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              textoSecundario,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildGradientChartData(BuildContext context) {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minX: 0,
      lineBarsData: [
        LineChartBarData(
          spots: puntosGrafica,
          isCurved: true,
          curveSmoothness: 0.35,
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(1)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradient.map((c) => c.withOpacity(0.3)).toList(),
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}
