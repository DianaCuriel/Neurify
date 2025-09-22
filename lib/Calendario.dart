import 'package:flutter/material.dart';
import 'Fijo/Appbar.dart';
import 'Fijo/BottomNavigator.dart';
import 'Calendario_card.dart';
import 'Fijo/app_theme.dart';

class CalendarioPage extends StatelessWidget {
  const CalendarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MiAppBar(),
      body: Center(
        child: FractionallySizedBox(
          // widthFactor: 0.9,
          heightFactor: 0.6,
          child: const CalendarCard(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return DraggableScrollableSheet(
                initialChildSize: 0.4,
                minChildSize: 0.2,
                maxChildSize: 0.9,
                expand: false,
                builder: (context, scrollController) {
                  final TextEditingController nombreController =
                      TextEditingController();
                  final TextEditingController asuntoController =
                      TextEditingController();
                  final TextEditingController numeroController =
                      TextEditingController();
                  final TextEditingController fechaController =
                      TextEditingController();
                  final TextEditingController horaController =
                      TextEditingController();

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
                                // Indicador visual
                                Container(
                                  width: 40,
                                  height: 4,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                // Fila de cierre y guardar
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
                                        // Crear un mapa con los datos
                                        final datos = {
                                          'nombre': nombreController.text,
                                          'asunto': asuntoController.text,
                                          'numero': numeroController.text,
                                          'fecha': fechaController.text,
                                          'hora': horaController.text,
                                        };

                                        Navigator.pop(
                                          context,
                                          datos,
                                        ); // Enviar datos al cerrar
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                      ),
                                      child: AppTheme.tituloBoton("Guardar"),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),
                                AppTheme.subtitleText('Datos personales'),
                                const SizedBox(height: 8),

                                TextField(
                                  controller: nombreController,
                                  decoration: const InputDecoration(
                                    hintText: "Nombre del cliente",
                                    counterText: "0/20",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                    ),
                                  ),
                                  maxLength: 20,
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: asuntoController,
                                  decoration: const InputDecoration(
                                    hintText: "Asunto",
                                    counterText: "0/20",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                    ),
                                  ),
                                  maxLength: 20,
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: numeroController,
                                  decoration: const InputDecoration(
                                    hintText: "Número",
                                    counterText: "0/20",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                    ),
                                  ),
                                  maxLength: 20,
                                ),
                                const SizedBox(height: 20),
                                AppTheme.subtitleText('Datos del día'),
                                const SizedBox(height: 8),

                                // Fecha y hora
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
                                    DateTime? fecha = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (fecha != null) {
                                      setState(() {
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
                                    TimeOfDay? hora = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (hora != null) {
                                      setState(() {
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
          ).then((datos) {
            if (datos != null) {
              // Aquí recibes los datos cuando el modal se cierra con "Guardar"
              print("Nombre: ${datos['nombre']}");
              print("Asunto: ${datos['asunto']}");
              print("Número: ${datos['numero']}");
              print("Fecha: ${datos['fecha']}");
              print("Hora: ${datos['hora']}");

              // Por ejemplo, enviar los datos a otra página
              // Navigator.push(context, MaterialPageRoute(builder: (_) => OtraPagina(datos: datos)));
            }
          });
        },
        tooltip: 'Agregar',
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: AppTheme.primaryColor,
      ),

      bottomNavigationBar: const MiBottomNav(),
    );
  }
}
