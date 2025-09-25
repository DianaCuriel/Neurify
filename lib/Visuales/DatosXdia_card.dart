import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Fijo/app_theme.dart';
import '../Modelos/Calendario_model.dart';

class DatosxdiaCard extends StatelessWidget {
  const DatosxdiaCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final modelo = context.watch<CalendarioModel>();
    final ahora = DateTime.now();

    // Filtrar citas de hoy que aún no han pasado
    final citasHoy =
        modelo.citas.where((cita) {
          try {
            final fecha = DateFormat("dd/MM/yyyy").parse(cita.fecha);
            final horaParts = cita.hora.split(":");
            final h = int.parse(horaParts[0]);
            final m = int.parse(horaParts[1]);

            final fechaHoraCita = DateTime(
              fecha.year,
              fecha.month,
              fecha.day,
              h,
              m,
            );

            return fechaHoraCita.year == ahora.year &&
                fechaHoraCita.month == ahora.month &&
                fechaHoraCita.day == ahora.day &&
                fechaHoraCita.isAfter(ahora);
          } catch (e) {
            return false;
          }
        }).toList();

    if (citasHoy.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        margin: const EdgeInsets.all(16),
        color: AppTheme.caja,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text("No hay citas para hoy", style: AppTheme.sutittleStyle),
        ),
      );
    }

    return Column(
      children:
          citasHoy.map((cita) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.caja,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nombre: ${cita.nombre}",
                      style: AppTheme.sutittleStyle,
                    ),
                    Text("Asunto: ${cita.asunto}", style: AppTheme.bodyStyle),
                    Text("Hora: ${cita.hora}", style: AppTheme.bodyStyle),
                    Text("Número: ${cita.numero}", style: AppTheme.bodyStyle),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
