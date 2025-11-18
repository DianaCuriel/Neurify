import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:neurify/fijo/appbar.dart';
import 'package:neurify/fijo/bottomnavigator.dart';
import 'package:neurify/fijo/app_theme.dart';
import 'package:neurify/modelos/modificaciones_model.dart';

import 'package:neurify/visuales/modificaciones_card.dart';
import 'package:neurify/visuales/modificaciones_agregarbloqueo.dart';

class ModificacionesPage extends StatefulWidget {
  const ModificacionesPage({Key? key}) : super(key: key);

  @override
  State<ModificacionesPage> createState() => _ModificacionesPageState();
}

class _ModificacionesPageState extends State<ModificacionesPage> {
  String filtroTipo = 'Todas';

  @override
  void initState() {
    super.initState();
    // Llama al fetch usando la instancia GLOBAL (ya provista en main.dart)
    // Usamos un microtask para que el context ya esté montado.
    Future.microtask(() => context.read<ModificacionesModel>().fetchBloqueos());
  }

  @override
  Widget build(BuildContext context) {
    //  NO ENVUELVAS con otro ChangeNotifierProvider aquí.
    return Scaffold(
      appBar: const MiAppBar(title: "Bloqueos"),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: filtroTipo,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Todas', child: Text('Todas')),
                DropdownMenuItem(value: 'Puntual', child: Text('Día puntual')),
                DropdownMenuItem(
                  value: 'Rango diario',
                  child: Text('Rango diario'),
                ),
                DropdownMenuItem(value: 'Semanal', child: Text('Semanal')),
              ],
              onChanged: (val) => setState(() => filtroTipo = val!),
            ),
          ),
          const SizedBox(height: 16),

          // Consumimos el modelo global
          Expanded(
            child: Consumer<ModificacionesModel>(
              builder: (context, modelo, _) {
                final modificacionesFiltradas =
                    modelo.modificaciones.where((mod) {
                      switch (filtroTipo) {
                        case 'Puntual':
                          return mod.tipo == TipoModificacion.unica;
                        case 'Rango diario':
                          return mod.tipo == TipoModificacion.rangoDiario;
                        case 'Semanal':
                          return mod.tipo == TipoModificacion.semanal;
                        default:
                          return true;
                      }
                    }).toList();

                if (modificacionesFiltradas.isEmpty) {
                  return const Center(child: Text("No hay modificaciones"));
                }

                return ListView.builder(
                  itemCount: modificacionesFiltradas.length,
                  itemBuilder:
                      (_, i) =>
                          ModificacionesCard(mod: modificacionesFiltradas[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const NuevaModificacionPage(),
          );
          // Recarga desde el MISMO provider global
          await context.read<ModificacionesModel>().fetchBloqueos();
        },
        tooltip: 'Agregar bloqueo',
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const MiBottomNav(currentIndex: 1),
    );
  }
}
