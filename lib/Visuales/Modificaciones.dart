import 'package:flutter/material.dart';
import 'package:neurify/Visuales/Modificaciones_card.dart';
import 'package:provider/provider.dart';
import '../Fijo/Appbar.dart';
import '../Fijo/BottomNavigator.dart';
import '../Fijo/app_theme.dart';
import '../Modelos/Modificaciones_model.dart';

class ModificacionesPage extends StatefulWidget {
  const ModificacionesPage({super.key});

  @override
  _ModificacionesPageState createState() => _ModificacionesPageState();
}

class _ModificacionesPageState extends State<ModificacionesPage> {
  bool _isMonthlyView = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ModificacionesModel(),
      child: Scaffold(
        appBar: const MiAppBar(title: "Bloqueos"),
        body: SingleChildScrollView(
          child: Column(children: [const ModificacionesCard()]),
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) {
                final tituloController = TextEditingController();
                final fechaController = TextEditingController();
                final horaController = TextEditingController();

                DateTime? selectedFecha;
                TimeOfDay? selectedHora;

                return DraggableScrollableSheet(
                  initialChildSize: 0.4,
                  minChildSize: 0.2,
                  maxChildSize: 0.9,
                  expand: false,
                  builder: (context, scrollController) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (selectedFecha != null &&
                                              selectedHora != null) {
                                            final fechaHoraFinal = DateTime(
                                              selectedFecha!.year,
                                              selectedFecha!.month,
                                              selectedFecha!.day,
                                              selectedHora!.hour,
                                              selectedHora!.minute,
                                            );

                                            final nuevaCita = Modificiones(
                                              titulo: tituloController.text,
                                              fechaHora: fechaHoraFinal,
                                            );

                                            context
                                                .read<ModificacionesModel>()
                                                .addCita(nuevaCita);

                                            Navigator.pop(context);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppTheme.primaryColor,
                                        ),
                                        child: AppTheme.tituloBoton("Guardar"),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  AppTheme.subtitleText('Datos del día'),
                                  const SizedBox(height: 20),
                                  TextField(
                                    controller: tituloController,
                                    decoration: const InputDecoration(
                                      hintText: "Agregar titulo",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: fechaController,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      hintText: "Día",
                                      suffixIcon: Icon(Icons.calendar_today),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                      ),
                                    ),
                                    onTap: () async {
                                      final fecha = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );
                                      if (fecha != null) {
                                        setState(() {
                                          selectedFecha = fecha;
                                          fechaController.text =
                                              "${fecha.day}/${fecha.month}/${fecha.year}";
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: horaController,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      hintText: "Hora",
                                      suffixIcon: Icon(Icons.access_time),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                      ),
                                    ),
                                    onTap: () async {
                                      final hora = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                      if (hora != null) {
                                        setState(() {
                                          selectedHora = hora;
                                          horaController.text = hora.format(
                                            context,
                                          );
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
          tooltip: 'Agregar',
          child: const Icon(Icons.add, color: Colors.white),
          backgroundColor: AppTheme.primaryColor,
        ),

        bottomNavigationBar: const MiBottomNav(),
      ),
    );
  }
}
