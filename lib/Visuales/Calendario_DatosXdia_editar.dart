import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Fijo/app_theme.dart';
import '../Modelos/Calendario_model.dart';

class EditarCitaPage extends StatefulWidget {
  final Cita cita;

  const EditarCitaPage({super.key, required this.cita});

  @override
  State<EditarCitaPage> createState() => _EditarCitaPageState();
}

class _EditarCitaPageState extends State<EditarCitaPage> {
  late TextEditingController nombreController;
  late TextEditingController telefonoController;
  late TextEditingController correoController;
  late TextEditingController motivoController;
  late TextEditingController fechaController;
  late TextEditingController horaController;

  DateTime? selectedFecha;
  TimeOfDay? selectedHora;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.cita.nombreCliente);
    telefonoController = TextEditingController(text: widget.cita.telefono);
    correoController = TextEditingController(text: widget.cita.correo);
    motivoController = TextEditingController(text: widget.cita.motivo);
    fechaController = TextEditingController(
      text:
          "${widget.cita.fechaHora.day}/${widget.cita.fechaHora.month}/${widget.cita.fechaHora.year}",
    );
    horaController = TextEditingController(
      text: TimeOfDay.fromDateTime(widget.cita.fechaHora).format(context),
    );

    selectedFecha = widget.cita.fechaHora;
    selectedHora = TimeOfDay.fromDateTime(widget.cita.fechaHora);
  }

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
            _encabezado(context),
            const SizedBox(height: 20),
            AppTheme.subtitleText('Datos personales'),
            const SizedBox(height: 12),
            _campoTexto(nombreController, "Nombre del cliente"),
            _campoTexto(telefonoController, "Teléfono"),
            _campoTexto(correoController, "Correo electrónico"),
            _campoTexto(motivoController, "Motivo o asunto de la cita"),
            const SizedBox(height: 20),
            AppTheme.subtitleText('Datos del día'),
            const SizedBox(height: 12),
            _campoFecha(),
            _campoHora(),
          ],
        ),
      ),
    );
  }

  Widget _encabezado(BuildContext context) {
    return SizedBox(
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
              onPressed: _actualizarCita,
              child: AppTheme.tituloBoton("Actualizar"),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 48,
            child: Text(
              "Editar cita",
              style: AppTheme.sutittleStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
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
          hintText: "Seleccionar día",
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
            initialDate: selectedFecha ?? DateTime.now(),
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
          hintText: "Seleccionar hora",
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
            initialTime: selectedHora ?? TimeOfDay.now(),
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

  void _actualizarCita() {
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

    final citaEditada = widget.cita.copyWith(
      nombreCliente: nombreController.text.trim(),
      telefono: telefonoController.text.trim(),
      correo: correoController.text.trim(),
      motivo: motivoController.text.trim(),
      fechaHora: fechaHoraFinal,
    );

    context.read<CalendarioModel>().updateCita(citaEditada);
    Navigator.pop(context);
  }
}
