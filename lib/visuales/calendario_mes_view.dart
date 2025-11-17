import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:neurify/fijo/app_theme.dart';
import 'package:neurify/modelos/modificaciones_model.dart';
import 'package:neurify/visuales/calendario_utils.dart';

typedef OnDateSelected = void Function(DateTime date);

class CalendarMonthView extends StatefulWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final OnDateSelected? onDateSelected;

  const CalendarMonthView({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    this.onDateSelected,
  });

  @override
  State<CalendarMonthView> createState() => _CalendarMonthViewState();
}

class _CalendarMonthViewState extends State<CalendarMonthView> {
  @override
  Widget build(BuildContext context) {
    final mods = context.watch<ModificacionesModel>().modificaciones;

    return TableCalendar(
      firstDay: DateTime(2000),
      lastDay: DateTime(2100),
      focusedDay: widget.focusedDay,
      selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        widget.onDateSelected?.call(selectedDay);
      },
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
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
          final hasBlock = anyBlockOnDay(day, mods);
          if (!hasBlock) return null;
          return Stack(
            alignment: Alignment.center,
            children: [
              Text('${day.day}'),
              Positioned(
                bottom: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          );
        },
        todayBuilder: (context, day, focusedDay) {
          final hasBlock = anyBlockOnDay(day, mods);
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
                  '${day.day}',
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
    );
  }
}
