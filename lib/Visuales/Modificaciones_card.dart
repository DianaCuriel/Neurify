import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Fijo/app_theme.dart';
import '../Modelos/Modificaciones_model.dart';

class ModificacionesCard extends StatelessWidget {
  final Modificacion mod;
  const ModificacionesCard({Key? key, required this.mod}) : super(key: key);

  String _formatearFecha(DateTime fecha) =>
      DateFormat("dd/MM/yyyy").format(fecha);

  String _formatearHora(TimeOfDay hora) {
    final dt = DateTime(0, 0, 0, hora.hour, hora.minute);
    return DateFormat("HH:mm").format(dt);
  }

  String _descripcionTipo(Modificacion mod) {
    switch (mod.tipo) {
      case TipoModificacion.unica:
        return "Única";
      case TipoModificacion.rangoDiario:
        return "Rango diario";
      case TipoModificacion.semanal:
        final dias =
            mod.diasSemana
                ?.map((d) {
                  const nombres = [
                    "Lun",
                    "Mar",
                    "Mié",
                    "Jue",
                    "Vie",
                    "Sáb",
                    "Dom",
                  ];
                  return nombres[d];
                })
                .join(", ") ??
            "";
        return "Semanal ($dias)";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.caja,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mod.titulo, style: AppTheme.sutittleStyle),
                  const SizedBox(height: 4),
                  Text(
                    mod.fechaInicio == mod.fechaFin
                        ? "Fecha: ${_formatearFecha(mod.fechaInicio)}"
                        : "Del ${_formatearFecha(mod.fechaInicio)} al ${_formatearFecha(mod.fechaFin)}",
                    style: AppTheme.bodyStyle,
                  ),
                  Text(
                    "Hora: ${_formatearHora(mod.horaInicio)} - ${_formatearHora(mod.horaFin)}",
                    style: AppTheme.bodyStyle,
                  ),
                  Text(
                    "Tipo: ${_descripcionTipo(mod)}",
                    style: AppTheme.bodyStyle,
                  ),
                ],
              ),
            ),

            // Botones
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    // Editar
                  },
                  icon: const Icon(Icons.edit),
                ),
                ElevatedButton(
                  onPressed: () {
                    final modelo = Provider.of<ModificacionesModel>(
                      context,
                      listen: false,
                    );
                    modelo.removeModificacion(mod);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
