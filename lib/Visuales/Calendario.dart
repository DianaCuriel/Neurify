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
  double _calendarFrac = 0.55; // tamaño inicial del calendario (semanal)
  double _datosFrac = 0.45; // tamaño inicial de Datosxdia
  bool _isExpandedDatos = false; // para scroll interno de Datosxdia

  bool _showSortBy = true; // controla si se muestra Sort by
  bool _showLast24 = true; // controla si se muestra Last 24h

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalendarioModel(),
      child: Scaffold(
        appBar: const MiAppBar(title: "Calendario"),
        body: LayoutBuilder(
          builder: (context, constraints) {
            const controlBarHeight = 56.0;
            final total = constraints.maxHeight;

            // espacio útil para calendar + datos (sin contar la barra de control)
            final available = (total - controlBarHeight).clamp(
              0.0,
              double.infinity,
            );

            // altura basada en fracciones (modo "control por _calendarFrac")
            final fracHeight = (_calendarFrac.clamp(0.0, 1.0)) * available;

            // altura base para mensual (puedes ajustar 0.85 si quieres más/menos)
            final monthlyBase = available * 0.85;

            // altura final del calendario:
            // - si estamos en mensual, permitimos que crezca hasta lo que pida _calendarFrac también
            // - si estamos en semanal, usamos fracHeight
            final calendarHeight =
                _isMonthlyView ? max(monthlyBase, fracHeight) : fracHeight;

            // altura del panel datos (sigue usando la fracción que controlas)
            final bottomTarget = (_datosFrac.clamp(0.0, 1.0)) * available;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 📅 CALENDARIO (ahora una sola AnimatedContainer con altura dinámica)
                    if (_calendarFrac > 0 || _isMonthlyView)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeInOut,
                        height: calendarHeight,
                        child: CalendarCard(
                          initialDate: DateTime.now(),
                          isMonthlyView: _isMonthlyView,
                          onToggleView: () {
                            setState(() {
                              _isMonthlyView = !_isMonthlyView;
                            });
                          },
                        ),
                      ),

                    // 🔸 BARRA DE CONTROL
                    Container(
                      height: controlBarHeight,
                      color: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // 🟡 Sort by
                          if (_showSortBy)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_calendarFrac == 0.95 &&
                                      _datosFrac == 0.0) {
                                    // volver al estado inicial
                                    _calendarFrac = 0.55;
                                    _datosFrac = 0.45;
                                    _isExpandedDatos = false;
                                    _showSortBy = true;
                                    _showLast24 = true;
                                  } else {
                                    // expandir calendario y ocultar datosxdia
                                    _calendarFrac = 0.95;
                                    _datosFrac = 0.0;
                                    _isExpandedDatos = false;
                                    _showSortBy = true;
                                    _showLast24 = false; // ocultar Last 24h
                                  }
                                });
                              },
                              child: Row(
                                children: const [
                                  Icon(Icons.swap_vert),
                                  SizedBox(width: 6),
                                  Text(
                                    "Sort by",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),

                          const Spacer(),

                          // 🟢 Last 24h
                          if (_showLast24)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  final bool isExpanded24 =
                                      _isExpandedDatos && _datosFrac >= 0.8;

                                  if (isExpanded24) {
                                    // 🔄 Volver al estado inicial (depende si es mensual o semanal)
                                    _calendarFrac =
                                        _isMonthlyView ? 0.85 : 0.55;
                                    _datosFrac = _isMonthlyView ? 0.15 : 0.45;
                                    _isExpandedDatos = false;
                                    _showSortBy = true;
                                    _showLast24 = true;
                                  } else {
                                    // ⬆ Expandir Datosxdia y ocultar completamente calendario
                                    _isMonthlyView =
                                        false; // 🔹 forzar vista semanal para poder ocultar
                                    _calendarFrac = 0.0;
                                    _datosFrac =
                                        1.0; // ocupar todo el espacio disponible
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

                    // 📊 DATOS X DÍA
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
              builder: (context) {
                // Usamos solo el widget AgregarCitaPage
                return const AgregarCitaPage();
              },
            );
          },
          tooltip: 'Agregar',
          child: const Icon(Icons.add, color: Colors.white),
          backgroundColor: AppTheme.primaryColor,
        ),

        bottomNavigationBar: const MiBottomNav(),
      ),
    );
  }
}
