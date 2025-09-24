import 'package:flutter/material.dart';
import '../Fijo/Appbar.dart';
import '../Fijo/BottomNavigator.dart';
import 'Calendario_card.dart';
import '../Fijo/app_theme.dart';
import '../Modelos/Calendario_model.dart';

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});

  @override
  _CalendarioPageState createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  bool _isMonthlyView = false;

  List<Cliente> citas = [
    Cliente(
      nombre: "Juan Pérez",
      asunto: 'prueba',
      numero: 'prueba',
      fecha: "22/09/2025",
      hora: "3:00",
    ),
    Cliente(
      nombre: "María López",
      asunto: 'prueba',
      numero: 'prueba',
      fecha: "23/09/2025",
      hora: "1:00",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MiAppBar(),
      body: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height:
              _isMonthlyView
                  ? MediaQuery.of(context).size.height * 0.75
                  : MediaQuery.of(context).size.height * 0.55,
          child: CalendarCard(
            citas: citas,
            initialDate: DateTime.now(),
            isMonthlyView: _isMonthlyView,
            onToggleView: () {
              setState(() {
                _isMonthlyView = !_isMonthlyView;
              });
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              final nombreController = TextEditingController();
              final asuntoController = TextEditingController();
              final numeroController = TextEditingController();
              final fechaController = TextEditingController();
              final horaController = TextEditingController();

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
                                Container(
                                  width: 40,
                                  height: 4,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
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
                                        // Crear cliente y añadir a la lista
                                        setState(() {
                                          final nuevaCita = Cliente(
                                            nombre: nombreController.text,
                                            asunto: asuntoController.text,
                                            numero: numeroController.text,
                                            fecha: fechaController.text,
                                            hora: horaController.text,
                                          );
                                          citas.add(nuevaCita);
                                        });
                                        Navigator.pop(context);
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
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: asuntoController,
                                  decoration: const InputDecoration(
                                    hintText: "Asunto",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: numeroController,
                                  decoration: const InputDecoration(
                                    hintText: "Número",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                AppTheme.subtitleText('Datos del día'),
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
    );
  }
}
