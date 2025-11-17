import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:neurify/fijo/app_theme.dart';
import 'package:neurify/modelos/modificaciones_model.dart';
import 'package:neurify/visuales/calendario_mes_view.dart';
import 'package:neurify/visuales/calendario_semana_view.dart';

typedef OnDateSelected = void Function(DateTime date);

class CalendarCard extends StatefulWidget {
  final DateTime? initialDate;
  final OnDateSelected? onDateSelected;
  final Color primaryColor;
  final bool isMonthlyView;
  final VoidCallback onToggleView;

  const CalendarCard({
    super.key,
    this.initialDate,
    this.onDateSelected,
    this.primaryColor = AppTheme.primaryColor,
    required this.isMonthlyView,
    required this.onToggleView,
  });

  @override
  State<CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  late DateTime _baseMonday;
  final PageController _pageController = PageController(initialPage: 1000);
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _fetchedMods = false;

  @override
  void initState() {
    super.initState();
    final now = widget.initialDate ?? DateTime.now();
    _baseMonday = now.subtract(Duration(days: now.weekday - 1));
  }

  DateTime _getMondayForPage(int pageIndex) {
    final diff = pageIndex - 1000;
    return _baseMonday.add(Duration(days: diff * 7));
  }

  @override
  Widget build(BuildContext context) {
    // Carga de bloqueos una sola vez
    final modsModel = context.watch<ModificacionesModel>();
    if (!_fetchedMods && modsModel.modificaciones.isEmpty) {
      _fetchedMods = true;
      Future.microtask(
        () => context.read<ModificacionesModel>().fetchBloqueos(),
      );
    }

    final currentIndex =
        _pageController.hasClients
            ? _pageController.page?.toInt() ?? 1000
            : 1000;
    final monday = _getMondayForPage(currentIndex);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.all(16),
      color: AppTheme.caja,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header con toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: widget.onToggleView,
                  child: Text(
                    widget.isMonthlyView ? 'Vista mensual' : 'Vista semanal',
                    style: AppTheme.sutittleStyle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!widget.isMonthlyView)
              Column(
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(monday),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Contenido
            Expanded(
              child:
                  widget.isMonthlyView
                      ? CalendarMonthView(
                        focusedDay: _focusedDay,
                        selectedDay: _selectedDay,
                        onDateSelected: (selected) {
                          setState(() {
                            _selectedDay = selected;
                            _focusedDay = selected;
                          });
                          widget.onDateSelected?.call(selected);
                        },
                      )
                      : PageView.builder(
                        controller: _pageController,
                        scrollDirection: Axis.horizontal,
                        onPageChanged: (_) => setState(() {}),
                        itemBuilder: (context, index) {
                          final monday = _getMondayForPage(index);
                          return CalendarWeekView(
                            monday: monday,
                            controller: _pageController,
                            onDateSelected: widget.onDateSelected,
                            primaryColor: widget.primaryColor,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
