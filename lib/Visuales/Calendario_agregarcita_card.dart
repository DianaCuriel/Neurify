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
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con X y Guardar
            SizedBox(
              height: 80,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                      ),
                      onPressed: _guardarCita,
                      child: AppTheme.tituloBoton("Guardar"),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 48,
                    child: Text(
                      "Nueva cita",
                      style: AppTheme.sutittleStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sección Datos personales
            AppTheme.subtitleText('Datos personales'),
            const SizedBox(height: 12),
            _campoTexto(nombreController, "Nombre del cliente"),
            _campoTexto(asuntoController, "Asunto"),
            _campoTexto(numeroController, "Número"),

            const SizedBox(height: 20),
            // Sección Datos del día
            AppTheme.subtitleText('Datos del día'),
            const SizedBox(height: 12),
            _campoFecha(),
            _campoHora(),
          ],
        ),
      ),
    );
  }

  Widget _campoTexto(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _campoFecha() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: fechaController,
        readOnly: true,
        decoration: InputDecoration(
          hintText: "Día",
          suffixIcon: const Icon(Icons.calendar_today),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
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
    );
  }

  Widget _campoHora() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: horaController,
        readOnly: true,
        decoration: InputDecoration(
          hintText: "Hora",
          suffixIcon: const Icon(Icons.access_time),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
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
    );
  }

  void _guardarCita() {
    if (selectedFecha == null || selectedHora == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona fecha y hora')));
      return;
    }

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
}
