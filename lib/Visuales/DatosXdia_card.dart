import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Fijo/app_theme.dart';
import '../Modelos/Calendario_model.dart';
import 'Calendario_DatosXdia_editar.dart';

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
    final modelo = context.watch<CalendarioModel>();
    final ahora = DateTime.now();

    // 🔹 Filtrar citas del día actual
    final citasHoy =
        modelo.citas.where((cita) {
          final fecha = cita.fechaHora;
          return fecha.year == ahora.year &&
              fecha.month == ahora.month &&
              fecha.day == ahora.day;
        }).toList();

    // 🔹 Filtrar por búsqueda (nombre o motivo)
    final citasFiltradas =
        citasHoy.where((cita) {
          final query = _searchQuery.toLowerCase();
          return cita.nombreCliente.toLowerCase().contains(query) ||
              cita.motivo.toLowerCase().contains(query);
        }).toList();

    return Column(
      children: [
        // 🔍 Campo de búsqueda
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
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

        // 📅 Si no hay citas
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
          // 📋 Lista de citas
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

  // 🧩 Tarjeta individual
  Widget _buildCard(Cita cita) {
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
            // 🟢 Información de la cita
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
                  if (cita.estado.isNotEmpty)
                    Text("Estado: ${cita.estado}", style: AppTheme.bodyStyle),
                ],
              ),
            ),

            // 🔧 Botones
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    // Editar cita (abre modal)
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => EditarCitaPage(cita: cita),
                    );
                  },
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  tooltip: "Editar cita",
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    final calendarioModel = Provider.of<CalendarioModel>(
                      context,
                      listen: false,
                    );
                    await calendarioModel.removeCita(cita);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cita cancelada')),
                    );
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
