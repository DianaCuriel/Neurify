import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Fijo/app_theme.dart';
import '../Modelos/Modificaciones_model.dart';

class ModificacionesCard extends StatelessWidget {
  const ModificacionesCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final modelo = context.watch<ModificacionesModel>();
    final ahora = DateTime.now();

    // Filtrar citas de hoy que aún no han pasado
    final citasHoy =
        modelo.citas.where((cita) {
          final fecha = cita.fechaHora;
          return fecha.year == ahora.year &&
              fecha.month == ahora.month &&
              fecha.day == ahora.day &&
              fecha.isAfter(ahora);
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
                      "Nombre: ${cita.titulo}",
                      style: AppTheme.sutittleStyle,
                    ),

                    Text(
                      "Hora: ${DateFormat("HH:mm").format(cita.fechaHora)}",
                      style: AppTheme.bodyStyle,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
