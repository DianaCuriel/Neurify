import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

// Barra de navegación y AppBar personalizados
import 'package:neurify/Fijo/BottomNavigator.dart';
import 'package:neurify/Fijo/Appbar.dart';

// Modelo
import '../Modelos/estadisticas_modelo.dart';

// Tema de la app
import 'package:neurify/Fijo/app_theme.dart';

class EstadisticasPage extends StatelessWidget {
  const EstadisticasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EstadisticasModelo(),
      child: const _EstadisticasPageContent(),
    );
  }
}

class _EstadisticasPageContent extends StatelessWidget {
  const _EstadisticasPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final modelo = context.watch<EstadisticasModelo>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const MiAppBar(title: 'Estadísticas'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F7FB), Color(0xFFE6EBF7)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // CONTENEDOR PRINCIPAL (FONDO GRIS)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // ⬅️ GRIS EN VEZ DE BLANCO
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _FiltrosUI(),
                      const SizedBox(height: 24),
                      Text(
                        modelo.tituloFecha,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      if (modelo.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ----------- SECCIÓN: CITAS REALIZADAS -----------
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Text(
                                "Citas Realizadas",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ),
                            _StatCard(
                              titulo: "Citas Realizadas",
                              color: Colors.blue,
                              gradient: [
                                Colors.blue.shade400,
                                Colors.blue.shade100,
                              ],
                              puntosGrafica: modelo.datosGraficaCitas,
                              textoPrincipal: modelo.datoPrincipalCitas,
                              textoSecundario: modelo.datoSecundarioCitas,
                            ),

                            const SizedBox(height: 32), // MÁS SEPARACIÓN
                            // Divider para dividir las secciones
                            Divider(
                              thickness: 1.2,
                              color: Colors.grey[400],
                              indent: 12,
                              endIndent: 12,
                            ),
                            const SizedBox(height: 20),

                            // ----------- SECCIÓN: CITAS CANCELADAS -----------
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Text(
                                "Citas Canceladas",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.red[900],
                                ),
                              ),
                            ),

                            _StatCard(
                              titulo: "Citas Canceladas",
                              color: Colors.red,
                              gradient: [
                                Colors.red.shade400,
                                Colors.red.shade100,
                              ],
                              puntosGrafica: modelo.datosGraficaCancelaciones,
                              textoPrincipal: modelo.datoPrincipalCancelaciones,
                              textoSecundario:
                                  modelo.datoSecundarioCancelaciones,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const MiBottomNav(currentIndex: 2),
    );
  }
}

// ------------------ FILTROS ------------------

class _FiltrosUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final modelo = context.read<EstadisticasModelo>();
    final filtroActual = context.select(
      (EstadisticasModelo m) => m.filtroSeleccionado,
    );

    final isPersonalizado = filtroActual == 'Personalizado';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(6),
          child: ToggleButtons(
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
            borderRadius: BorderRadius.circular(12),
            fillColor: AppTheme.primaryColor,
            selectedColor: Colors.white,
            color: Colors.grey[700],
            borderColor: Colors.transparent,
            selectedBorderColor: Colors.transparent,
            constraints: const BoxConstraints(minWidth: 90, minHeight: 40),
            children: const [Text('Semanal'), Text('Mensual'), Text('Anual')],
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.calendar_today_outlined, size: 18),
          label: Text(
            'Rango Personalizado',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isPersonalizado ? Colors.white : Colors.grey[800],
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isPersonalizado ? AppTheme.primaryColor : Colors.grey[200],
            foregroundColor: isPersonalizado ? Colors.white : Colors.grey[800],
            elevation: isPersonalizado ? 2 : 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
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
            if (rango != null) modelo.setRangoPersonalizado(rango);
          },
        ),
      ],
    );
  }
}

// ----------- TARJETA DE ESTADÍSTICA -----------

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
      color: Colors.white, // Fondo de la tarjeta
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(Icons.bar_chart_rounded, color: color.withOpacity(0.9)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child:
                  puntosGrafica.isEmpty
                      ? const Center(
                        child: Text(
                          "No hay datos para este rango.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                      : LineChart(_buildGradientChartData(context)),
            ),
            const SizedBox(height: 12),
            Text(
              textoPrincipal,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              textoSecundario,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
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
            colors: [color.withOpacity(0.9), color.withOpacity(1)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradient.map((c) => c.withOpacity(0.30)).toList(),
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}
