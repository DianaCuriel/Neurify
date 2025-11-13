// lib/visuales/calendario_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';

import 'package:neurify/fijo/app_theme.dart';
import 'package:neurify/modelos/calendario_model.dart';
import 'package:neurify/modelos/modificaciones_model.dart';

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
  final List<int> _hours = List.generate(24, (i) => i);
  final PageController _pageController = PageController(initialPage: 1000);
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  bool _triedFetchMods = false;

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

  List<DateTime> _getWeekDays(DateTime monday) =>
      List.generate(7, (i) => monday.add(Duration(days: i)));

  String _formatHour(int hour24) {
    final period = hour24 >= 12 ? "PM" : "AM";
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return "$hour12 $period";
  }

  int? _weekdayFromSpanish(String? dia) {
    if (dia == null) return null;
    final d = dia.trim().toLowerCase();
    switch (d) {
      case 'lunes':
        return DateTime.monday;
      case 'martes':
        return DateTime.tuesday;
      case 'miércoles':
      case 'miercoles':
        return DateTime.wednesday;
      case 'jueves':
        return DateTime.thursday;
      case 'viernes':
        return DateTime.friday;
      case 'sábado':
      case 'sabado':
        return DateTime.saturday;
      case 'domingo':
        return DateTime.sunday;
      default:
        return null;
    }
  }

  /// LÍMITE CERRADO-ABIERTO: [start, end)
  /// Evita pintar la celda de la hora **fin**.
  bool _hourInRange(DateTime target, DateTime? start, DateTime? end) {
    final tM = target.hour * 60 + target.minute;
    final sM = start == null ? null : start.hour * 60 + start.minute;
    final eM = end == null ? null : end.hour * 60 + end.minute;

    if (sM != null && tM < sM) return false;
    if (eM != null && tM >= eM) return false; // <-- fin EXCLUSIVO
    return true;
  }

  bool _dateInRange(DateTime day, DateTime? start, DateTime? end) {
    DateTime onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);
    final d = onlyDate(day);
    final s = start == null ? null : onlyDate(start);
    final e = end == null ? null : onlyDate(end);
    if (s != null && d.isBefore(s)) return false;
    if (e != null && d.isAfter(e)) return false;
    return true;
  }

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isBlockedAt({
    required DateTime day,
    required int hour,
    required Modificacion mod,
  }) {
    final target = DateTime(day.year, day.month, day.day, hour, 0);

    switch (mod.tipo) {
      case TipoModificacion.unica:
        if (mod.fechaUnica == null) return false;
        if (!_sameDate(day, mod.fechaUnica!)) return false;
        final ok = _hourInRange(target, mod.horaInicio, mod.horaFin);
        if (ok)
          debugPrint(
            '⛔ match Única ${mod.titulo} @ ${DateFormat.Hm().format(target)}',
          );
        return ok;

      case TipoModificacion.rangoDiario:
        if (!_dateInRange(day, mod.fechaInicio, mod.fechaFinal)) return false;
        final ok = _hourInRange(target, mod.horaInicio, mod.horaFin);
        if (ok)
          debugPrint(
            '⛔ match Diario ${mod.titulo} @ ${DateFormat.Hm().format(target)}',
          );
        return ok;

      case TipoModificacion.semanal:
        final w = _weekdayFromSpanish(mod.diaSemana);
        if (w == null || day.weekday != w) return false;
        final ok = _hourInRange(target, mod.horaInicio, mod.horaFin);
        if (ok)
          debugPrint(
            '⛔ match Semanal ${mod.titulo} @ ${DateFormat.Hm().format(target)}',
          );
        return ok;
    }
  }

  bool _anyBlockOnDay(DateTime day, List<Modificacion> mods) {
    for (final m in mods) {
      switch (m.tipo) {
        case TipoModificacion.unica:
          if (m.fechaUnica != null && _sameDate(day, m.fechaUnica!))
            return true;
          break;
        case TipoModificacion.rangoDiario:
          if (_dateInRange(day, m.fechaInicio, m.fechaFinal)) return true;
          break;
        case TipoModificacion.semanal:
          final w = _weekdayFromSpanish(m.diaSemana);
          if (w != null && day.weekday == w) return true;
          break;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final cal = context.watch<CalendarioModel>();
    final modsModel = context.watch<ModificacionesModel>();
    final mods = modsModel.modificaciones;

    if (mods.isEmpty && !_triedFetchMods) {
      _triedFetchMods = true;
      debugPrint('🟡 mods vacío; fetchBloqueos()…');
      Future.microtask(
        () => context.read<ModificacionesModel>().fetchBloqueos(),
      );
    }

    final currentIndex =
        _pageController.hasClients
            ? _pageController.page?.toInt() ?? 1000
            : 1000;
    final monday = _getMondayForPage(currentIndex);
    final weekDays = _getWeekDays(monday);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.all(16),
      color: AppTheme.caja,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: widget.onToggleView,
                  child: Text(
                    widget.isMonthlyView ? "Vista mensual" : "Vista semanal",
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
                    DateFormat("MMMM yyyy").format(monday),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
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
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            final hasBlock = _anyBlockOnDay(day, mods);
                            if (!hasBlock) return null;
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Text("${day.day}"),
                                Positioned(
                                  bottom: 4,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.primaryColor.withOpacity(
                                        0.9,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                          todayBuilder: (context, day, focusedDay) {
                            final hasBlock = _anyBlockOnDay(day, mods);
                            return Container(
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Text(
                                    "${day.day}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (hasBlock)
                                    const Positioned(
                                      bottom: 4,
                                      child: CircleAvatar(
                                        radius: 3,
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                      : PageView.builder(
                        controller: _pageController,
                        scrollDirection: Axis.horizontal,
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
                                                    final citasEnHora =
                                                        context
                                                            .read<
                                                              CalendarioModel
                                                            >()
                                                            .citas
                                                            .where((cita) {
                                                              final f =
                                                                  cita.fechaHora;
                                                              return f.year ==
                                                                      day.year &&
                                                                  f.month ==
                                                                      day.month &&
                                                                  f.day ==
                                                                      day.day &&
                                                                  f.hour ==
                                                                      hour;
                                                            })
                                                            .toList();

                                                    final bloqueosEnHora =
                                                        mods
                                                            .where(
                                                              (m) =>
                                                                  _isBlockedAt(
                                                                    day: day,
                                                                    hour: hour,
                                                                    mod: m,
                                                                  ),
                                                            )
                                                            .toList();

                                                    if (bloqueosEnHora
                                                            .isEmpty &&
                                                        citasEnHora.isEmpty) {
                                                      return const SizedBox(
                                                        height: 50,
                                                        width: 70,
                                                      );
                                                    }

                                                    return Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 2,
                                                            horizontal: 4,
                                                          ),
                                                      constraints:
                                                          const BoxConstraints(
                                                            minHeight: 50,
                                                            minWidth: 70,
                                                          ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          if (bloqueosEnHora
                                                              .isNotEmpty)
                                                            Container(
                                                              height: 24,
                                                              margin:
                                                                  const EdgeInsets.only(
                                                                    bottom: 2,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: Colors
                                                                    .redAccent
                                                                    .withOpacity(
                                                                      0.85,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      6,
                                                                    ),
                                                              ),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Text(
                                                                bloqueosEnHora
                                                                        .first
                                                                        .titulo
                                                                        .isEmpty
                                                                    ? "Bloqueado"
                                                                    : bloqueosEnHora
                                                                        .first
                                                                        .titulo,
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ),
                                                          if (citasEnHora
                                                              .isNotEmpty)
                                                            ...citasEnHora.map((
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
                                                                  height: 22,
                                                                  margin:
                                                                      const EdgeInsets.symmetric(
                                                                        vertical:
                                                                            1,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color: widget
                                                                        .primaryColor
                                                                        .withOpacity(
                                                                          0.8,
                                                                        ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          6,
                                                                        ),
                                                                  ),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Text(
                                                                    cita.nombreCliente,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: const TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                      fontSize:
                                                                          10,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }),
                                                        ],
                                                      ),
                                                    );
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
