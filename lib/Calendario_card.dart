import 'package:flutter/material.dart';
import 'Fijo/app_theme.dart';

typedef OnDateSelected = void Function(DateTime date);

class CalendarCard extends StatefulWidget {
  final DateTime? initialDate;
  final OnDateSelected? onDateSelected;
  final Color primaryColor;

  const CalendarCard({
    Key? key,
    this.initialDate,
    this.onDateSelected,
    this.primaryColor = AppTheme.primaryColor,
  }) : super(key: key);

  @override
  _CalendarCardState createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  late DateTime _selectedDate;

  final List<String> _days = ["Lun", "Mar", "Mie", "Jue", "Vie", "Sab", "Dom"];
  final List<String> _hours = [
    "12 AM",
    "1 AM",
    "2 AM",
    "3 AM",
    "4 AM",
    "5 AM",
    "6 AM",
    "7 AM",
    "8 AM",
    "9 AM",
    "10 AM",
    "11 AM",
    "12 PM",
    "1 PM",
    "2 PM",
    "3 PM",
    "4 PM",
    "5 PM",
    "6 PM",
    "7 PM",
    "8 PM",
    "9 PM",
    "10 PM",
    "11 PM",
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.all(16),
      color: AppTheme.caja,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Icono y título
            Stack(
              alignment: Alignment.center, // centra el texto
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: widget.primaryColor),
                    const SizedBox(width: 8),
                  ],
                ),
                AppTheme.subtitleText("VISTA SEMANAL"),
              ],
            ),

            const SizedBox(height: 16),
            // Tabla de horas vs días
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    border: TableBorder.all(color: AppTheme.caja),
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                    children: [
                      // Encabezados de días
                      TableRow(
                        children: [
                          const SizedBox(), // esquina vacía
                          for (var day in _days)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  day,
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
                            // Hora
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                hour,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentColor,
                                ),
                              ),
                            ),
                            // Solo un contenedor por fila (por ejemplo para el primer día)
                            GestureDetector(
                              onTap: () {
                                final selectedDate = DateTime(
                                  _selectedDate.year,
                                  _selectedDate.month,
                                  _selectedDate.day, // solo el primer día
                                );
                                if (widget.onDateSelected != null) {
                                  widget.onDateSelected!(selectedDate);
                                }
                              },
                              child: Container(
                                height: 50,
                                width: 70, // ancho fijo
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: widget.primaryColor.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Cita", // ya no repite i+1
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Puedes repetirlo manualmente para cada día si quieres
                            // o dejar SizedBox() para las otras celdas vacías
                            for (var i = 1; i < _days.length; i++)
                              const SizedBox(height: 50, width: 70),
                          ],
                        ),

                      // Filas de horas
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
