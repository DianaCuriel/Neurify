import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../Fijo/app_theme.dart';
import '../Modelos/Calendario_model.dart';

typedef OnDateSelected = void Function(DateTime date);

class CalendarCard extends StatefulWidget {
  final DateTime? initialDate;
  final OnDateSelected? onDateSelected;
  final Color primaryColor;
  final bool isMonthlyView;
  final VoidCallback onToggleView;

  // --- CORRECCIÓN 1: Se moderniza el constructor ---
  const CalendarCard({
    super.key, // Se usa 'super.key' en lugar de 'Key? key'
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
  final List<int> _hours = List.generate(24, (i) => i);
  final PageController _pageController = PageController(initialPage: 1000);

  // Para calendario mensual
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

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

  List<DateTime> _getWeekDays(DateTime monday) {
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  String _formatHour(int hour24) {
    final period = hour24 >= 12 ? "PM" : "AM";
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return "$hour12 $period";
  }

  @override
  Widget build(BuildContext context) {
    // --- CORRECCIÓN 2: Se eliminaron las variables no utilizadas ---
    // 'modelo' y 'weekDays' se declaraban aquí pero no se usaban.
    // Se obtienen directamente donde se necesitan.

    final monday = _getMondayForPage(
      _pageController.hasClients ? _pageController.page?.toInt() ?? 1000 : 1000,
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.all(16),
      color: AppTheme.caja,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Subtítulo toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: widget.onToggleView,
                  child: Text(
                    widget.isMonthlyView ? "Vista mensual" : "Vista semanal",
                    style: AppTheme.sutittleStyle.copyWith(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Encabezado fechas de la semana
            if (!widget.isMonthlyView)
              Column(
                children: [
                  Text(
                    DateFormat("MMMM yyyy").format(monday),
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
                      ? TableCalendar(
                        firstDay: DateTime(2000),
                        lastDay: DateTime(2100),
                        focusedDay: _focusedDay,
                        selectedDayPredicate:
                            (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                          widget.onDateSelected?.call(selectedDay);
                        },
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Month',
                        },
                        headerVisible: true,
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          todayDecoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      : PageView.builder(
                        controller: _pageController,
                        scrollDirection:
                            Axis.horizontal, // 👈 se asegura scroll lateral
                        onPageChanged: (_) => setState(() {}),
                        itemBuilder: (context, index) {
                          final monday = _getMondayForPage(index);
                          final weekDays = _getWeekDays(monday);

                          return Column(
                            children: [
                              Text(
                                "${DateFormat("d MMM").format(weekDays.first)} - ${DateFormat("d MMM").format(weekDays.last)}",
                                style: const TextStyle(
                                  color: AppTheme.accentColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Table(
                                      border: TableBorder.all(
                                        color: AppTheme.caja,
                                      ),
                                      defaultColumnWidth:
                                          const IntrinsicColumnWidth(),
                                      children: [
                                        // Fila de encabezados
                                        TableRow(
                                          children: [
                                            const SizedBox(),
                                            for (var day in weekDays)
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "${DateFormat('EEE').format(day)} ${day.day}",
                                                    style: const TextStyle(
                                                      color:
                                                          AppTheme.accentColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        // Filas de horas
                                        for (var hour in _hours)
                                          TableRow(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Text(
                                                  _formatHour(hour),
                                                  style: const TextStyle(
                                                    color: AppTheme.accentColor,
                                                  ),
                                                ),
                                              ),
                                              for (var day in weekDays)
                                                Builder(
                                                  builder: (context) {
                                                    // Buscar todas las citas en ese día y hora (independientemente de los minutos)
                                                    final citasEnHora =
                                                        context.read<CalendarioModel>().citas.where((
                                                          cita,
                                                        ) {
                                                          return cita
                                                                      .fechaHora
                                                                      .year ==
                                                                  day.year &&
                                                              cita
                                                                      .fechaHora
                                                                      .month ==
                                                                  day.month &&
                                                              cita
                                                                      .fechaHora
                                                                      .day ==
                                                                  day.day &&
                                                              cita
                                                                      .fechaHora
                                                                      .hour ==
                                                                  hour;
                                                        }).toList();

                                                    if (citasEnHora
                                                        .isNotEmpty) {
                                                      return Column(
                                                        children:
                                                            citasEnHora.map((
                                                              cita,
                                                            ) {
                                                              return GestureDetector(
                                                                onTap:
                                                                    () => widget
                                                                        .onDateSelected
                                                                        ?.call(
                                                                          cita.fechaHora,
                                                                        ),
                                                                child: Container(
                                                                  height:
                                                                      24, // ajustar altura según cuántas citas quieras mostrar
                                                                  margin:
                                                                      const EdgeInsets.symmetric(
                                                                        vertical:
                                                                            2,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color: widget
                                                                        .primaryColor
                                                                        .withOpacity(
                                                                          0.8,
                                                                        ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          8,
                                                                        ),
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(
                                                                      cita.nombre,
                                                                      style: const TextStyle(
                                                                        color:
                                                                            Colors.white,
                                                                        fontSize:
                                                                            10,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }).toList(),
                                                      );
                                                    } else {
                                                      return const SizedBox(
                                                        height: 50,
                                                        width: 70,
                                                      );
                                                    }
                                                  },
                                                ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
