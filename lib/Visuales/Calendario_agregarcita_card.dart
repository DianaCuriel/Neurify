import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:neurify/fijo/app_theme.dart';
import 'package:neurify/modelos/calendario_model.dart';

class AgregarCitaPage extends StatefulWidget {
  const AgregarCitaPage({super.key});

  @override
  State<AgregarCitaPage> createState() => _AgregarCitaPageState();
}

class _AgregarCitaPageState extends State<AgregarCitaPage> {
  final nombreController = TextEditingController();
  final telefonoController = TextEditingController();
  final correoController = TextEditingController();
  final motivoController = TextEditingController();
  final fechaController = TextEditingController();
  final horaController = TextEditingController();

  DateTime? selectedFecha;
  TimeOfDay? selectedHora;

  // ---------- Helpers ----------
  DateTime _onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _showBlockingDialog({
    required String title,
    required String line1,
    required String line2,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
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
                  title,
                  textAlign: TextAlign.center,
                  style: AppTheme.sutittleStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  line1,
                  style: AppTheme.bodyStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  line2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Entendido'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  // -----------------------------

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
          final now = DateTime.now();
          final hoy = _onlyDate(now);

          final fecha = await showDatePicker(
            context: context,
            initialDate:
                selectedFecha != null && _onlyDate(selectedFecha!).isAfter(hoy)
                    ? selectedFecha!
                    : hoy,
            // 👉 bloquea elegir fechas anteriores a HOY
            firstDate: hoy,
            lastDate: DateTime(2100),
          );
          if (fecha != null) {
            // (extra) si por algún bug dieran una fecha pasada, lo impedimos
            if (_onlyDate(fecha).isBefore(hoy)) {
              await _showBlockingDialog(
                title: "Fecha inválida",
                line1: "No puedes seleccionar una fecha en el pasado.",
                line2: "Elige una fecha a partir de hoy.",
              );
              return;
            }

            setState(() {
              selectedFecha = fecha;
              fechaController.text =
                  "${fecha.day}/${fecha.month}/${fecha.year}";
              // si ya había hora y ahora la fecha cambió a hoy y la hora quedó en el pasado, limpiamos la hora
              if (selectedHora != null &&
                  _onlyDate(selectedFecha!) == hoy &&
                  _toMinutes(selectedHora!) <=
                      _toMinutes(TimeOfDay.fromDateTime(now))) {
                selectedHora = null;
                horaController.clear();
              }
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
          final now = DateTime.now();
          final hoy = _onlyDate(now);

          // si no hay fecha elegida aún, asumimos hoy para validar hora
          final fechaBase =
              selectedFecha == null ? hoy : _onlyDate(selectedFecha!);

          final hora = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (hora != null) {
            // Si la fecha elegida es HOY, la hora debe ser estrictamente futura
            if (fechaBase == hoy) {
              final selMin = _toMinutes(hora);
              final nowMin = _toMinutes(TimeOfDay.fromDateTime(now));
              if (selMin <= nowMin) {
                await _showBlockingDialog(
                  title: "Hora inválida",
                  line1: "No puedes seleccionar una hora pasada.",
                  line2: "Elige una hora posterior a la hora actual.",
                );
                return;
              }
            }
            setState(() {
              selectedHora = hora;
              horaController.text = hora.format(context);
            });
          }
        },
      ),
    );
  }

  Future<void> _guardarCita() async {
    // Validación básica
    if (selectedFecha == null || selectedHora == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona fecha y hora')));
      return;
    }

    final now = DateTime.now();
    final hoy = _onlyDate(now);
    final fechaHoraFinal = DateTime(
      selectedFecha!.year,
      selectedFecha!.month,
      selectedFecha!.day,
      selectedHora!.hour,
      selectedHora!.minute,
    );

    // Validaciones “anti pasado” también al guardar (por si algo se coló)
    if (_onlyDate(selectedFecha!).isBefore(hoy)) {
      await _showBlockingDialog(
        title: "Fecha inválida",
        line1: "No puedes guardar una cita en el pasado.",
        line2: "Elige una fecha a partir de hoy.",
      );
      return;
    }
    if (!fechaHoraFinal.isAfter(now)) {
      await _showBlockingDialog(
        title: "Fecha y hora inválidas",
        line1: "La cita debe ser posterior a la fecha y hora actual.",
        line2: "Ajusta la hora (o fecha) para poder guardar.",
      );
      return;
    }

    // Crear objeto Cita compatible con tu modelo
    final nuevaCita = Cita(
      idEmpresario: 3,
      nombreCliente: nombreController.text.trim(),
      telefono: telefonoController.text.trim(),
      correo: correoController.text.trim(),
      motivo: motivoController.text.trim(),
      estado: "Pendiente",
      fechaHora: fechaHoraFinal,
    );

    context.read<CalendarioModel>().addCita(nuevaCita);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    nombreController.dispose();
    telefonoController.dispose();
    correoController.dispose();
    motivoController.dispose();
    fechaController.dispose();
    horaController.dispose();
    super.dispose();
  }
}
