import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Fijo/Appbar.dart';
import '../Fijo/BottomNavigator.dart';
import '../Fijo/app_theme.dart';
import '../Modelos/Modificaciones_model.dart';
import '../Visuales/Modificaciones_card.dart';
import 'Modificaciones_agregarbloqueo.dart';

class ModificacionesPage extends StatefulWidget {
  const ModificacionesPage({Key? key}) : super(key: key);

  @override
  State<ModificacionesPage> createState() => _ModificacionesPageState();
}

class _ModificacionesPageState extends State<ModificacionesPage> {
  String filtroTipo = 'Todas';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ModificacionesModel(),
      child: Scaffold(
        appBar: const MiAppBar(title: "Bloqueos"),
        body: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<String>(
                value: filtroTipo,
                decoration: InputDecoration(
                  // labelText: "Filtrar por tipo",
                  filled: true,
                  fillColor: Colors.white, // Fondo blanco
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // bordes redondeados
                    borderSide: BorderSide.none, // sin borde visible
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                dropdownColor: Colors.white, // color del menú desplegable
                items: const [
                  DropdownMenuItem(value: 'Todas', child: Text('Todas')),
                  DropdownMenuItem(value: 'Puntual', child: Text('Puntual')),
                  DropdownMenuItem(
                    value: 'Rango diario',
                    child: Text('Rango diario'),
                  ),
                  DropdownMenuItem(value: 'Semanal', child: Text('Semanal')),
                ],
                onChanged: (val) {
                  setState(() {
                    filtroTipo = val!;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),
            Expanded(
              child: Consumer<ModificacionesModel>(
                builder: (context, modelo, _) {
                  // Filtrado según el dropdown
                  final modificacionesFiltradas =
                      modelo.modificaciones.where((mod) {
                        switch (filtroTipo) {
                          case 'Todas':
                            return true;
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
                    return Center(
                      child: Text(
                        "No hay modificaciones",
                        style: AppTheme.sutittleStyle,
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: modificacionesFiltradas.length,
                    itemBuilder: (context, index) {
                      final mod = modificacionesFiltradas[index];
                      return ModificacionesCard(mod: mod);
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const NuevaModificacionPage(),
            );
          },
          tooltip: 'Agregar bloqueo',
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),

        bottomNavigationBar: const MiBottomNav(),
      ),
    );
  }
}
