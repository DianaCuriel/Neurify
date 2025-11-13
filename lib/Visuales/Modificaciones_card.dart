// Reemplaza estos imports en tu archivo:
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ✅ Correctos (absolutos + minúsculas)
import 'package:neurify/fijo/app_theme.dart';
import 'package:neurify/modelos/modificaciones_model.dart';
import 'package:neurify/visuales/modificaciones_edicion.dart';

class ModificacionesCard extends StatelessWidget {
  final Modificacion mod;
  const ModificacionesCard({Key? key, required this.mod}) : super(key: key);

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return "-";
    return DateFormat("dd/MM/yyyy").format(fecha);
  }

  String _formatearHora(DateTime? fechaHora) {
    if (fechaHora == null) return "-";
    return DateFormat("HH:mm").format(fechaHora);
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
        int index = _diaSemanaIndex(mod.diaSemana!);
        return "Semanal (${nombres[index]})";
    }
  }

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

                  // Fechas
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

                  // Horario
                  Text(
                    "Hora: ${_formatearHora(mod.horaInicio)} - ${_formatearHora(mod.horaFin)}",
                    style: AppTheme.bodyStyle,
                  ),

                  // Tipo
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
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder:
                          (_) => ChangeNotifierProvider.value(
                            value: Provider.of<ModificacionesModel>(
                              context,
                              listen: false,
                            ),
                            child: EditarModificacionPage(mod: mod),
                          ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                ),
                ElevatedButton(
                  onPressed: () {
                    final modelo = Provider.of<ModificacionesModel>(
                      context,
                      listen: false,
                    );
                    modelo.removeBloqueo(mod.idBloqueo);
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
