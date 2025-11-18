import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:neurify/fijo/app_theme.dart';
import 'package:neurify/modelos/modificaciones_model.dart';
import 'package:neurify/visuales/modificaciones_edicion.dart';

class ModificacionesCard extends StatelessWidget {
  final Modificacion mod;
  const ModificacionesCard({Key? key, required this.mod}) : super(key: key);

  String _formatearFecha(DateTime? fecha) =>
      fecha == null ? "-" : DateFormat("dd/MM/yyyy").format(fecha);

  String _formatearHora(DateTime? fechaHora) =>
      fechaHora == null ? "-" : DateFormat("HH:mm").format(fechaHora);

  int _diaSemanaIndex(String dia) {
    switch (dia.toLowerCase()) {
      case 'lunes':
        return 0;
      case 'martes':
        return 1;
      case 'miércoles':
      case 'miercoles':
        return 2;
      case 'jueves':
        return 3;
      case 'viernes':
        return 4;
      case 'sábado':
      case 'sabado':
        return 5;
      case 'domingo':
        return 6;
      default:
        return 0;
    }
  }

  String _descripcionTipo(Modificacion mod) {
    switch (mod.tipo) {
      case TipoModificacion.unica:
        return "Única";
      case TipoModificacion.rangoDiario:
        return "Rango diario";
      case TipoModificacion.semanal:
        if (mod.diaSemana == null) return "Semanal";
        const nombres = [
          "Lunes",
          "Martes",
          "Miércoles",
          "Jueves",
          "Viernes",
          "Sábado",
          "Domingo",
        ];
        final idx = _diaSemanaIndex(mod.diaSemana!);
        return "Semanal (${nombres[idx]})";
    }
  }

  /// Resumen bonito para el diálogo de confirmación
  String _resumenBloqueo(Modificacion m) {
    switch (m.tipo) {
      case TipoModificacion.unica:
        return 'Única · ${_formatearFecha(m.fechaUnica)} · ${_formatearHora(m.horaInicio)} - ${_formatearHora(m.horaFin)}';
      case TipoModificacion.rangoDiario:
        return 'Rango diario · ${_formatearFecha(m.fechaInicio)} → ${_formatearFecha(m.fechaFinal)} · ${_formatearHora(m.horaInicio)} - ${_formatearHora(m.horaFin)}';
      case TipoModificacion.semanal:
        final dia = (m.diaSemana ?? '-');
        final diaCap =
            dia.isEmpty
                ? '-'
                : '${dia[0].toUpperCase()}${dia.substring(1).toLowerCase()}';
        return 'Semanal ($diaCap) · ${_formatearHora(m.horaInicio)} - ${_formatearHora(m.horaFin)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final modModel = context.read<ModificacionesModel>(); // instancia global

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
            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mod.titulo, style: AppTheme.sutittleStyle),
                  const SizedBox(height: 4),

                  if (mod.tipo == TipoModificacion.unica &&
                      mod.fechaUnica != null)
                    Text(
                      "Fecha: ${_formatearFecha(mod.fechaUnica)}",
                      style: AppTheme.bodyStyle,
                    )
                  else if (mod.tipo == TipoModificacion.rangoDiario)
                    Text(
                      "Del ${_formatearFecha(mod.fechaInicio)} al ${_formatearFecha(mod.fechaFinal)}",
                      style: AppTheme.bodyStyle,
                    )
                  else if (mod.tipo == TipoModificacion.semanal)
                    Text(
                      "Día: ${mod.diaSemana ?? '-'}",
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

            // Acciones
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => EditarModificacionPage(mod: mod),
                    );
                  },
                  icon: const Icon(Icons.edit),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.orange,
                                  size: 60,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "¿Seguro que quieres eliminar este bloqueo?",
                                  textAlign: TextAlign.center,
                                  style: AppTheme.sutittleStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Se eliminará de tu calendario:",
                                  style: AppTheme.bodyStyle,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),

                                // Detalle del bloqueo
                                Text(
                                  mod.titulo.isNotEmpty
                                      ? mod.titulo
                                      : "Sin título",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Text(
                                //   _resumenBloqueo(mod),
                                //   textAlign: TextAlign.center,
                                //   style: const TextStyle(color: Colors.black54),
                                // ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[300],
                                        foregroundColor: Colors.black87,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                      ),
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text("No, volver"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                      ),
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text("Sí, eliminar"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );

                    if (confirmar == true) {
                      try {
                        await modModel.removeBloqueo(mod.idBloqueo);
                        // Para quedar 100% sincronizados con backend (por si hay lógica extra)
                        await modModel.fetchBloqueos();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bloqueo eliminado correctamente'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al eliminar: $e'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    "Eliminar",
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
