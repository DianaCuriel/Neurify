import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:neurify/fijo/app_theme.dart';
import 'package:neurify/modelos/calendario_model.dart';
import 'package:neurify/modelos/modificaciones_model.dart';
import 'package:neurify/visuales/calendario_utils.dart';

typedef OnDateSelected = void Function(DateTime date);

class CalendarWeekView extends StatelessWidget {
  final DateTime monday; // lunes base de la semana
  final PageController controller; // para cambiar semanas
  final OnDateSelected? onDateSelected;
  final Color primaryColor;

  CalendarWeekView({
    super.key,
    required this.monday,
    required this.controller,
    this.onDateSelected,
    this.primaryColor = AppTheme.primaryColor,
  });

  final List<int> _hours = List<int>.generate(24, (i) => i, growable: false);

  List<DateTime> _getWeekDays(DateTime monday) =>
      List.generate(7, (i) => monday.add(Duration(days: i)));

  String _formatHour(int hour24) {
    final period = hour24 >= 12 ? "PM" : "AM";
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return "$hour12 $period";
  }

  // Helper para saber si una cita está cancelada
  bool _isCancelled(String? estado) =>
      (estado ?? '').trim().toLowerCase() == 'cancelada';

  @override
  Widget build(BuildContext context) {
    final cal = context.watch<CalendarioModel>();
    final mods = context.watch<ModificacionesModel>().modificaciones;

    final weekDays = _getWeekDays(monday);

    return Column(
      children: [
        Text(
          '${DateFormat("d MMM").format(weekDays.first)} - ${DateFormat("d MMM").format(weekDays.last)}',
          style: const TextStyle(color: AppTheme.accentColor),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                border: TableBorder.all(color: AppTheme.caja),
                defaultColumnWidth: const IntrinsicColumnWidth(),
                children: [
                  // Encabezado
                  TableRow(
                    children: [
                      const SizedBox(),
                      for (var day in weekDays)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              '${DateFormat('EEE').format(day)} ${day.day}',
                              style: const TextStyle(
                                color: AppTheme.accentColor,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Horas
                  for (var hour in _hours)
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _formatHour(hour),
                            style: const TextStyle(color: AppTheme.accentColor),
                          ),
                        ),
                        for (var day in weekDays)
                          Builder(
                            builder: (context) {
                              // 🔹 Citas (filtrando canceladas)
                              final citasEnHora =
                                  cal.citas.where((cita) {
                                    final f = cita.fechaHora;
                                    final esMismaHora =
                                        f.year == day.year &&
                                        f.month == day.month &&
                                        f.day == day.day &&
                                        f.hour == hour;
                                    final noCancelada =
                                        !_isCancelled(cita.estado);
                                    return esMismaHora && noCancelada;
                                  }).toList();

                              // 🔹 Bloqueos
                              final bloqueosEnHora =
                                  mods
                                      .where(
                                        (m) => isBlockedAt(
                                          day: day,
                                          hour: hour,
                                          mod: m,
                                        ),
                                      )
                                      .toList();

                              if (bloqueosEnHora.isEmpty &&
                                  citasEnHora.isEmpty) {
                                return const SizedBox(height: 50, width: 70);
                              }

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 4,
                                ),
                                constraints: const BoxConstraints(
                                  minHeight: 50,
                                  minWidth: 70,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Bloqueo
                                    if (bloqueosEnHora.isNotEmpty)
                                      Container(
                                        height: 24,
                                        margin: const EdgeInsets.only(
                                          bottom: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent.withOpacity(
                                            0.85,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          bloqueosEnHora.first.titulo.isEmpty
                                              ? 'Bloqueado'
                                              : bloqueosEnHora.first.titulo,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    // Citas (solo no canceladas)
                                    if (citasEnHora.isNotEmpty)
                                      ...citasEnHora.map(
                                        (cita) => GestureDetector(
                                          onTap:
                                              () => onDateSelected?.call(
                                                cita.fechaHora,
                                              ),
                                          child: Container(
                                            height: 22,
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: primaryColor.withOpacity(
                                                0.8,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              cita.nombreCliente,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
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
  }
}
