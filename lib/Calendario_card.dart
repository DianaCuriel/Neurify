import 'package:flutter/material.dart';
import 'Fijo/app_theme.dart';
import 'Modelos/Calendario_model.dart';
import 'package:intl/intl.dart';

typedef OnDateSelected = void Function(DateTime date);

class CalendarCard extends StatefulWidget {
  final DateTime? initialDate;
  final OnDateSelected? onDateSelected;
  final Color primaryColor;
  final List<Cliente> citas;

  const CalendarCard({
    Key? key,
    this.initialDate,
    this.onDateSelected,
    this.primaryColor = AppTheme.primaryColor,
    this.citas = const [],
  }) : super(key: key);

  @override
  State<CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  late DateTime _monday; // lunes de la semana
  Map<String, Cliente> citasMap = {};

  final List<int> _hours = List.generate(24, (i) => i);

  @override
  void initState() {
    super.initState();
    final now = widget.initialDate ?? DateTime.now();
    _monday = now.subtract(Duration(days: now.weekday - 1));
    _loadCitas(widget.citas);
  }

  // Método para cargar citas en el mapa
  void _loadCitas(List<Cliente> lista) {
    citasMap.clear();
    for (var cita in lista) {
      try {
        final fecha = DateFormat("dd/MM/yyyy").parse(cita.fecha);
        final horaParts = cita.hora.split(":");
        final h = int.parse(horaParts[0]);
        final m = int.parse(horaParts[1]);
        final dt = DateTime(fecha.year, fecha.month, fecha.day, h, m);
        final key = DateFormat("dd-MM-yyyy HH:mm").format(dt);
        citasMap[key] = cita;
      } catch (e) {
        debugPrint("Error parseando cita: $e");
      }
    }
  }

  // Se llama cuando el widget padre cambia la lista de citas
  @override
  void didUpdateWidget(covariant CalendarCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.citas != widget.citas) {
      _loadCitas(widget.citas);
      setState(() {});
    }
  }

  List<DateTime> _getWeekDays() {
    return List.generate(7, (i) => _monday.add(Duration(days: i)));
  }

  String _formatHour(int hour24) {
    final period = hour24 >= 12 ? "PM" : "AM";
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return "$hour12 $period";
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeekDays();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.all(16),
      color: AppTheme.caja,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Semana del ${DateFormat("d MMM yyyy").format(weekDays.first)}"
              " - ${DateFormat("d MMM yyyy").format(weekDays.last)}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    border: TableBorder.all(color: AppTheme.caja),
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                    children: [
                      // Encabezados
                      TableRow(
                        children: [
                          const SizedBox(),
                          for (var day in weekDays)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  "${DateFormat('EEE').format(day)} ${day.day}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.accentColor,
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
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _formatHour(hour),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentColor,
                                ),
                              ),
                            ),
                            for (var day in weekDays)
                              Builder(
                                builder: (context) {
                                  final dt = DateTime(
                                    day.year,
                                    day.month,
                                    day.day,
                                    hour,
                                  );
                                  final key = DateFormat(
                                    "dd-MM-yyyy HH:mm",
                                  ).format(dt);
                                  final cita = citasMap[key];

                                  if (cita != null) {
                                    return GestureDetector(
                                      onTap: () {
                                        if (widget.onDateSelected != null) {
                                          widget.onDateSelected!(dt);
                                        }
                                      },
                                      child: Container(
                                        height: 50,
                                        width: 70,
                                        margin: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: widget.primaryColor
                                              .withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            cita.nombre,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
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
        ),
      ),
    );
  }
}
