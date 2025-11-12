import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Modelos/calendario_model.dart';
import '../Modelos/modificaciones_model.dart';

class CalendarCard extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime>? onDateSelected;
  final Color primaryColor;

  const CalendarCard({
    super.key,
    required this.initialDate,
    this.onDateSelected,
    this.primaryColor = Colors.blue,
  });

  @override
  State<CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  bool _isMonthlyView = false;
  late DateTime _startOfWeek;
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _startOfWeek = widget.initialDate.subtract(
      Duration(days: widget.initialDate.weekday - 1),
    );
    _focusedMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final calendario = context.watch<CalendarioModel>();
    final modificaciones = context.watch<ModificacionesModel>();

    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _isMonthlyView
                ? _buildMonthlyView(calendario, modificaciones)
                : _buildWeeklyView(calendario, modificaciones),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final formatter = [
      "Ene",
      "Feb",
      "Mar",
      "Abr",
      "May",
      "Jun",
      "Jul",
      "Ago",
      "Sep",
      "Oct",
      "Nov",
      "Dic",
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              if (_isMonthlyView) {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month - 1,
                );
              } else {
                _startOfWeek = _startOfWeek.subtract(const Duration(days: 7));
              }
            });
          },
        ),
        Column(
          children: [
            Text(
              _isMonthlyView
                  ? "${formatter[_focusedMonth.month - 1]} ${_focusedMonth.year}"
                  : "Semana del ${_startOfWeek.day} ${formatter[_startOfWeek.month - 1]}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => setState(() => _isMonthlyView = !_isMonthlyView),
              child: Text(_isMonthlyView ? "Ver semana" : "Ver mes"),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              if (_isMonthlyView) {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month + 1,
                );
              } else {
                _startOfWeek = _startOfWeek.add(const Duration(days: 7));
              }
            });
          },
        ),
      ],
    );
  }

  // 🔹 VISTA SEMANAL
  Widget _buildWeeklyView(
    CalendarioModel calendario,
    ModificacionesModel modificaciones,
  ) {
    final days = List.generate(7, (i) => _startOfWeek.add(Duration(days: i)));
    final hours = List.generate(12, (i) => i + 8);

    return Column(
      children:
          hours.map((hour) {
            return Row(
              children:
                  days.map((day) {
                    final citasEnHora =
                        calendario.citas
                            .where(
                              (cita) =>
                                  cita.fechaHora.year == day.year &&
                                  cita.fechaHora.month == day.month &&
                                  cita.fechaHora.day == day.day &&
                                  cita.fechaHora.hour == hour,
                            )
                            .toList();

                    final bloqueos =
                        modificaciones.modificaciones.where((mod) {
                          // misma lógica de antes para detectar bloqueos
                          if (mod.tipo == TipoModificacion.unica &&
                              mod.fechaUnica != null) {
                            return mod.fechaUnica!.year == day.year &&
                                mod.fechaUnica!.month == day.month &&
                                mod.fechaUnica!.day == day.day &&
                                hour >= (mod.horaInicio?.hour ?? 0) &&
                                hour < (mod.horaFin?.hour ?? 24);
                          }
                          if (mod.tipo == TipoModificacion.rangoDiario &&
                              mod.fechaInicio != null &&
                              mod.fechaFinal != null) {
                            return day.isAfter(
                                  mod.fechaInicio!.subtract(
                                    const Duration(days: 1),
                                  ),
                                ) &&
                                day.isBefore(
                                  mod.fechaFinal!.add(const Duration(days: 1)),
                                ) &&
                                hour >= (mod.horaInicio?.hour ?? 0) &&
                                hour < (mod.horaFin?.hour ?? 24);
                          }
                          if (mod.tipo == TipoModificacion.semanal &&
                              mod.diaSemana != null) {
                            final dias = {
                              'lunes': 1,
                              'martes': 2,
                              'miércoles': 3,
                              'miercoles': 3,
                              'jueves': 4,
                              'viernes': 5,
                              'sábado': 6,
                              'sabado': 6,
                              'domingo': 7,
                            };
                            return day.weekday ==
                                    (dias[mod.diaSemana!.toLowerCase()] ?? 0) &&
                                hour >= (mod.horaInicio?.hour ?? 0) &&
                                hour < (mod.horaFin?.hour ?? 24);
                          }
                          return false;
                        }).toList();

                    if (citasEnHora.isNotEmpty || bloqueos.isNotEmpty) {
                      return Expanded(
                        child: Column(
                          children: [
                            ...citasEnHora.map(
                              (cita) => Container(
                                height: 22,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.primaryColor.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    cita.nombreCliente,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ...bloqueos.map(
                              (mod) => Container(
                                height: 20,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    mod.titulo,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Expanded(child: SizedBox(height: 50));
                    }
                  }).toList(),
            );
          }).toList(),
    );
  }

  // 🔹 VISTA MENSUAL
  Widget _buildMonthlyView(
    CalendarioModel calendario,
    ModificacionesModel modificaciones,
  ) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final daysBefore = firstDay.weekday - 1;
    final totalDays = lastDay.day + daysBefore;
    final totalWeeks = (totalDays / 7).ceil();

    return Column(
      children: List.generate(totalWeeks, (week) {
        return Row(
          children: List.generate(7, (dayOfWeek) {
            final dayIndex = (week * 7) + dayOfWeek - daysBefore + 1;
            if (dayIndex < 1 || dayIndex > lastDay.day) {
              return Expanded(child: Container(height: 60));
            }

            final date = DateTime(
              _focusedMonth.year,
              _focusedMonth.month,
              dayIndex,
            );

            final citas =
                calendario.citas
                    .where(
                      (cita) =>
                          cita.fechaHora.year == date.year &&
                          cita.fechaHora.month == date.month &&
                          cita.fechaHora.day == date.day,
                    )
                    .toList();

            final bloqueos =
                modificaciones.modificaciones.where((mod) {
                  if (mod.tipo == TipoModificacion.unica &&
                      mod.fechaUnica != null) {
                    return mod.fechaUnica!.year == date.year &&
                        mod.fechaUnica!.month == date.month &&
                        mod.fechaUnica!.day == date.day;
                  }
                  if (mod.tipo == TipoModificacion.rangoDiario &&
                      mod.fechaInicio != null &&
                      mod.fechaFinal != null) {
                    return date.isAfter(
                          mod.fechaInicio!.subtract(const Duration(days: 1)),
                        ) &&
                        date.isBefore(
                          mod.fechaFinal!.add(const Duration(days: 1)),
                        );
                  }
                  if (mod.tipo == TipoModificacion.semanal &&
                      mod.diaSemana != null) {
                    final dias = {
                      'lunes': 1,
                      'martes': 2,
                      'miércoles': 3,
                      'miercoles': 3,
                      'jueves': 4,
                      'viernes': 5,
                      'sábado': 6,
                      'sabado': 6,
                      'domingo': 7,
                    };
                    return date.weekday ==
                        (dias[mod.diaSemana!.toLowerCase()] ?? 0);
                  }
                  return false;
                }).toList();

            return Expanded(
              child: GestureDetector(
                onTap: () => widget.onDateSelected?.call(date),
                child: Container(
                  height: 70,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${date.day}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (citas.isNotEmpty)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (bloqueos.isNotEmpty)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}
