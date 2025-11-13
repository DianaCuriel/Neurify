// ==========================================
// lib/visuales/datosxdia_card.dart  (FIX)
// ==========================================
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ✅ SIEMPRE absolutos y en minúsculas
import 'package:neurify/fijo/app_theme.dart';
import 'package:neurify/modelos/calendario_model.dart';
import 'package:neurify/visuales/calendario_datosxdia_editar.dart';

class DatosxdiaCard extends StatefulWidget {
  final bool isExpanded;
  const DatosxdiaCard({Key? key, this.isExpanded = false}) : super(key: key);

  @override
  State<DatosxdiaCard> createState() => _DatosxdiaCardState();
}

class _DatosxdiaCardState extends State<DatosxdiaCard> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final modelo = context.watch<CalendarioModel>(); // ← ahora coincide
    final ahora = DateTime.now();

    final citasHoy =
        modelo.citas.where((cita) {
          final fecha = cita.fechaHora;
          return fecha.year == ahora.year &&
              fecha.month == ahora.month &&
              fecha.day == ahora.day;
        }).toList();

    final query = _searchQuery.toLowerCase();
    final citasFiltradas =
        citasHoy.where((cita) {
          return cita.nombreCliente.toLowerCase().contains(query) ||
              cita.motivo.toLowerCase().contains(query);
        }).toList();

    return Column(
      children: [
        if (widget.isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar por nombre o motivo...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
        if (citasHoy.isEmpty)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: AppTheme.caja,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "No hay citas para hoy",
                style: AppTheme.sutittleStyle,
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount:
                  widget.isExpanded
                      ? citasFiltradas.length
                      : citasFiltradas.take(3).length,
              itemBuilder: (context, index) {
                final cita = citasFiltradas[index];
                return _buildCard(cita);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildCard(Cita cita) {
    final estaCancelada = cita.estado.toLowerCase() == "cancelada";
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cita.motivo.isNotEmpty ? cita.motivo : "Sin motivo",
                    style: AppTheme.sutittleStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    cita.nombreCliente.isNotEmpty
                        ? cita.nombreCliente
                        : "Sin nombre",
                    style: AppTheme.sutittleStyle,
                  ),
                  Text(
                    DateFormat("hh:mm a").format(cita.fechaHora),
                    style: AppTheme.bodyStyle,
                  ),
                  if (cita.telefono.isNotEmpty)
                    Text("Tel: ${cita.telefono}", style: AppTheme.bodyStyle),
                  Text(
                    "Estado: ${cita.estado}",
                    style: TextStyle(
                      color: estaCancelada ? Colors.redAccent : Colors.black87,
                      fontWeight:
                          estaCancelada ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (!estaCancelada)
              Column(
                children: [
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => EditarCitaPage(cita: cita),
                      );
                    },
                    icon: const Icon(Icons.edit, color: Colors.black),
                    tooltip: "Editar cita",
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final confirmar = await showDialog<bool>(
                        context: context,
                        builder: (_) {
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
                                    "¿Seguro que quieres cancelar esta cita?",
                                    textAlign: TextAlign.center,
                                    style: AppTheme.sutittleStyle.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Deberás contactar con tu cliente:",
                                    style: AppTheme.bodyStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    cita.nombreCliente.isNotEmpty
                                        ? cita.nombreCliente
                                        : "Sin nombre",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    cita.telefono.isNotEmpty
                                        ? "Tel: ${cita.telefono}"
                                        : "Teléfono no disponible",
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
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
                                        child: const Text("Sí, cancelar"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                      if (confirmar == true && mounted) {
                        await context.read<CalendarioModel>().cancelarCita(
                          cita,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Cita cancelada correctamente',
                              ),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      }
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
