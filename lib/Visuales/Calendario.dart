// Calendario_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Fijo/Appbar.dart';
import '../Fijo/BottomNavigator.dart';
import 'Calendario_card.dart';
import '../Fijo/app_theme.dart';
import '../Modelos/Calendario_model.dart';
import 'DatosXdia_card.dart';
import 'Calendario_agregarcita_card.dart';

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});

  @override
  _CalendarioPageState createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  bool _isMonthlyView = false;
  double _calendarFrac = 0.55;
  double _datosFrac = 0.45;
  bool _isExpandedDatos = false;
  bool _showSortBy = true;
  bool _showLast24 = true;

  @override
  void initState() {
    super.initState();
    // Llamar al modelo para cargar las citas apenas se abra la página
    Future.microtask(() {
      final calendario = context.read<CalendarioModel>();
      calendario.fetchCitas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final calendario = context.watch<CalendarioModel>(); // acceso al modelo

    return Scaffold(
      appBar: const MiAppBar(title: "Calendario"),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const controlBarHeight = 56.0;
          final total = constraints.maxHeight;
          final available = (total - controlBarHeight).clamp(
            0.0,
            double.infinity,
          );
          final fracHeight = (_calendarFrac.clamp(0.0, 1.0)) * available;
          final monthlyBase = available * 0.85;
          final calendarHeight =
              _isMonthlyView ? max(monthlyBase, fracHeight) : fracHeight;
          final bottomTarget = (_datosFrac.clamp(0.0, 1.0)) * available;

          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_calendarFrac > 0 || _isMonthlyView)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOut,
                      height: calendarHeight,
                      child: CalendarCard(
                        initialDate: DateTime.now(),
                        isMonthlyView: _isMonthlyView,
                        onToggleView: () {
                          setState(() => _isMonthlyView = !_isMonthlyView);
                        },
                      ),
                    ),
                  Container(
                    height: controlBarHeight,
                    color: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        if (_showSortBy)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_calendarFrac == 0.95 &&
                                    _datosFrac == 0.0) {
                                  _calendarFrac = 0.55;
                                  _datosFrac = 0.45;
                                  _isExpandedDatos = false;
                                  _showSortBy = true;
                                  _showLast24 = true;
                                } else {
                                  _calendarFrac = 0.95;
                                  _datosFrac = 0.0;
                                  _isExpandedDatos = false;
                                  _showSortBy = true;
                                  _showLast24 = false;
                                }
                              });
                            },
                            child: Row(
                              children: const [
                                Icon(Icons.swap_vert),
                                SizedBox(width: 6),
                                Text("Sort by", style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        const Spacer(),
                        if (_showLast24)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                final bool isExpanded24 =
                                    _isExpandedDatos && _datosFrac >= 0.8;
                                if (isExpanded24) {
                                  _calendarFrac = _isMonthlyView ? 0.85 : 0.55;
                                  _datosFrac = _isMonthlyView ? 0.15 : 0.45;
                                  _isExpandedDatos = false;
                                  _showSortBy = true;
                                  _showLast24 = true;
                                } else {
                                  _isMonthlyView = false;
                                  _calendarFrac = 0.0;
                                  _datosFrac = 1.0;
                                  _isExpandedDatos = true;
                                  _showSortBy = false;
                                  _showLast24 = true;
                                }
                              });
                            },
                            child: Row(
                              children: const [
                                Text(
                                  "Last 24h",
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_drop_up),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_datosFrac > 0)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOut,
                      height: bottomTarget,
                      child: DatosxdiaCard(isExpanded: _isExpandedDatos),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder:
                (context) =>
                    const AgregarCitaPage(), // ya tiene acceso al provider
          );
        },
        tooltip: 'Agregar',
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: AppTheme.primaryColor,
      ),
      bottomNavigationBar: const MiBottomNav(currentIndex: 0),
    );
  }
}
