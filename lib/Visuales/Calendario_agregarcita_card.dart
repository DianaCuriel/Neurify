import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Fijo/app_theme.dart';
import '../Modelos/Calendario_model.dart';

class AgregarCitaPage extends StatefulWidget {
  const AgregarCitaPage({super.key});

  @override
  State<AgregarCitaPage> createState() => _AgregarCitaPageState();
}

class _AgregarCitaPageState extends State<AgregarCitaPage> {
  final nombreController = TextEditingController();
  final asuntoController = TextEditingController();
  final numeroController = TextEditingController();
  final fechaController = TextEditingController();
  final horaController = TextEditingController();

  DateTime? selectedFecha;
  TimeOfDay? selectedHora;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedFecha != null && selectedHora != null) {
                      final fechaHoraFinal = DateTime(
                        selectedFecha!.year,
                        selectedFecha!.month,
                        selectedFecha!.day,
                        selectedHora!.hour,
                        selectedHora!.minute,
                      );

                      final nuevaCita = Cliente(
                        nombre: nombreController.text,
                        asunto: asuntoController.text,
                        numero: numeroController.text,
                        fechaHora: fechaHoraFinal,
                      );

                      context.read<CalendarioModel>().addCita(nuevaCita);
                      Navigator.pop(context);
                    }
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
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: asuntoController,
              decoration: const InputDecoration(
                hintText: "Asunto",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: numeroController,
              decoration: const InputDecoration(
                hintText: "Número",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
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
                  borderRadius: BorderRadius.all(Radius.circular(8)),
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
                  borderRadius: BorderRadius.all(Radius.circular(8)),
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
                    horaController.text = hora.format(context);
                  });
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
