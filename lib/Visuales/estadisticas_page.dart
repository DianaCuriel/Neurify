// File: lib/paginas/estadisticas_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

// Barra de navegación y AppBar personalizados
import 'package:neurify/Fijo/BottomNavigator.dart';
import 'package:neurify/Fijo/Appbar.dart';

// Modelo
import '../modelos/estadisticas_modelo.dart';

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

  void _logModeloOncePerBuild(BuildContext context, EstadisticasModelo m) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final citasPts = m.datosGraficaCitas;
      final cancPts = m.datosGraficaCancelaciones;
      String _fmtFirstLast(List<FlSpot> xs) {
        if (xs.isEmpty) return '[]';
        final first = xs.first;
        final last = xs.last;
        return '[len=${xs.length}, first=(${first.x},${first.y}), last=(${last.x},${last.y})]';
      }

      debugPrint('──────────────── stats.page(build) ────────────────');
      debugPrint(
        '[stats.page] filtro="${m.filtroSeleccionado}"  titulo="${m.tituloFecha}"',
      );
      debugPrint('[stats.page] isLoading=${m.isLoading}');
      debugPrint(
        '[stats.page] tarjetas: Realizadas="${m.datoPrincipalCitas} ${m.datoSecundarioCitas}", Canceladas="${m.datoPrincipalCancelaciones} ${m.datoSecundarioCancelaciones}"',
      );
      debugPrint(
        '[stats.page] series: Citas ${_fmtFirstLast(citasPts)}  |  Cancel ${_fmtFirstLast(cancPts)}',
      );
      if (citasPts.isEmpty || cancPts.isEmpty) {
        debugPrint(
          '[stats.page] ⚠ puntosGrafica vacío → "No hay datos para este rango."',
        );
      }
      debugPrint('───────────────────────────────────────────────────');
    });
  }

  @override
  Widget build(BuildContext context) {
    final modelo = context.watch<EstadisticasModelo>();
    _logModeloOncePerBuild(context, modelo);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: const MiAppBar(title: 'Estadísticas'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header unificado (título + filtro + calendario)
              _HeaderFiltersBar(modelo: modelo),

              if (modelo.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                _StatCard(
                  titulo: "Citas Realizadas",
                  color: Colors.blue,
                  gradient: [Colors.blue.shade400, Colors.blue.shade100],
                  puntosGrafica: modelo.datosGraficaCitas,
                  textoPrincipal: modelo.datoPrincipalCitas,
                  textoSecundario: modelo.datoSecundarioCitas,
                ),
                const SizedBox(height: 20),
                _StatCard(
                  titulo: "Citas Canceladas",
                  color: Colors.red,
                  gradient: [Colors.red.shade400, Colors.red.shade100],
                  puntosGrafica: modelo.datosGraficaCancelaciones,
                  textoPrincipal: modelo.datoPrincipalCancelaciones,
                  textoSecundario: modelo.datoSecundarioCancelaciones,
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MiBottomNav(currentIndex: 2),
    );
  }
}

/// Header moderno: título + subtítulo del filtro + (dropdown + calendario) en el mismo contenedor
class _HeaderFiltersBar extends StatelessWidget {
  final EstadisticasModelo modelo;
  const _HeaderFiltersBar({super.key, required this.modelo});

  String _subtituloFiltro(String f) =>
      f == 'Personalizado' ? 'Rango personalizado' : f;

  @override
  Widget build(BuildContext context) {
    final primary = AppTheme.primaryColor;
    final textTheme = Theme.of(context).textTheme;
    final filtroActual = context.select(
      (EstadisticasModelo m) => m.filtroSeleccionado,
    );
    final isPersonalizado = filtroActual == 'Personalizado';

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 28,
              spreadRadius: 6,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            // acento izquierdo
            Container(
              width: 6,
              height: 32,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 10),
            // Título + subtítulo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder:
                        (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                    child: Text(
                      modelo.tituloFecha,
                      key: ValueKey(modelo.tituloFecha),
                      textAlign: TextAlign.left,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: primary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtituloFiltro(modelo.filtroSeleccionado),
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Controles: Dropdown + Calendario
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 230),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: modelo.filtroSeleccionado,
                        icon: const Icon(Icons.arrow_drop_down),
                        isDense: true,
                        items: const [
                          DropdownMenuItem(
                            value: "Personalizado",
                            child: Text(
                              "Rango personalizado",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: "Semanal",
                            child: Text(
                              "Semanal",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: "Mensual",
                            child: Text(
                              "Mensual",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: "Anual",
                            child: Text(
                              "Anual",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (valor) {
                          if (valor != null) {
                            debugPrint(
                              '[stats.page] UI:onChanged filtro="$valor" (antes="${modelo.filtroSeleccionado}")',
                            );
                            modelo.setFiltro(valor);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Seleccionar rango',
                    onPressed:
                        () => _abrirSelectorSegunFiltro(
                          context,
                          modelo,
                          modelo.filtroSeleccionado,
                        ),
                    icon: Icon(
                      Icons.calendar_month_outlined,
                      color:
                          isPersonalizado
                              ? AppTheme.primaryColor
                              : Colors.grey[800],
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==== Diálogos según filtro ====
  Future<void> _abrirSelectorSegunFiltro(
    BuildContext context,
    EstadisticasModelo modelo,
    String filtro,
  ) async {
    switch (filtro) {
      case 'Personalizado':
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
        break;

      case 'Semanal':
        final seleccionado = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (seleccionado != null) modelo.setSemanaDesdeDia(seleccionado);
        break;

      case 'Mensual':
        await _showMonthYearPicker(context, modelo);
        break;

      case 'Anual':
        await _showYearPicker(context, modelo);
        break;
    }
  }

  Future<void> _showMonthYearPicker(
    BuildContext context,
    EstadisticasModelo modelo,
  ) async {
    int tmpYear = modelo.anioSeleccionado ?? DateTime.now().year;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => tmpYear--),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '$tmpYear',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => tmpYear++),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              content: SizedBox(
                width: 360,
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: 12,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.4,
                  ),
                  itemBuilder: (_, i) {
                    final mes = i + 1;
                    return OutlinedButton(
                      onPressed: () {
                        modelo.setAnio(tmpYear);
                        modelo.setMes(mes);
                        Navigator.of(ctx).pop();
                      },
                      child: Text(_mesNombre(mes)),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showYearPicker(
    BuildContext context,
    EstadisticasModelo modelo,
  ) async {
    final ahora = DateTime.now().year;
    final years = [for (int y = ahora; y >= 2020; y--) y];

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Selecciona un año'),
          content: SizedBox(
            width: 300,
            height: 360,
            child: ListView.separated(
              itemCount: years.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final y = years[i];
                return ListTile(
                  title: Text('$y'),
                  onTap: () {
                    modelo.setAnio(y);
                    Navigator.of(ctx).pop();
                  },
                );
              },
            ),
          ),
        );
      },
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

  void _logCard() {
    if (puntosGrafica.isEmpty) {
      debugPrint(
        '[stats.page.card] "$titulo": puntosGrafica=0 (texto="$textoPrincipal $textoSecundario")',
      );
    } else {
      final first = puntosGrafica.first;
      final last = puntosGrafica.last;
      debugPrint(
        '[stats.page.card] "$titulo": puntos=${puntosGrafica.length} first=(${first.x},${first.y}) last=(${last.x},${last.y})',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _logCard();

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 40,
              spreadRadius: 10,
              offset: const Offset(0, 14),
            ),
          ],
        ),
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
                      fontSize: 16,
                      color: AppTheme.primaryColor,
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
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                textoSecundario,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
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

String _mesNombre(int m) {
  const meses = [
    "Enero",
    "Febrero",
    "Marzo",
    "Abril",
    "Mayo",
    "Junio",
    "Julio",
    "Agosto",
    "Septiembre",
    "Octubre",
    "Noviembre",
    "Diciembre",
  ];
  if (m < 1 || m > 12) return "N/A";
  return meses[m - 1];
}
