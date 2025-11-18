import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Imports absolutos en minúsculas
import 'package:neurify/fijo/app_theme.dart';
import 'package:neurify/modelos/modificaciones_model.dart';

class NuevaModificacionPage extends StatefulWidget {
  const NuevaModificacionPage({Key? key}) : super(key: key);

  @override
  State<NuevaModificacionPage> createState() => _NuevaModificacionPageState();
}

class _NuevaModificacionPageState extends State<NuevaModificacionPage> {
  final tituloController = TextEditingController();
  final fechaInicioController = TextEditingController();
  final fechaFinController = TextEditingController();
  final horaInicioController = TextEditingController();
  final horaFinController = TextEditingController();

  DateTime? fechaInicio;
  DateTime? fechaFin;
  TimeOfDay? horaInicio;
  TimeOfDay? horaFin;

  String tipoBloqueo = 'Puntual';
  String? diaSeleccionado; // <-- ahora String (Lunes, Martes, ...)

  // Helpers ---------------

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _showValidationDialog({
    required String titulo,
    required String mensajeSuperior,
    required String mensajeDetalle,
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
                  titulo,
                  textAlign: TextAlign.center,
                  style: AppTheme.sutittleStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  mensajeSuperior,
                  style: AppTheme.bodyStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  mensajeDetalle,
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

  // UI --------------------

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
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        elevation: 4,
                      ),
                      onPressed: _guardarModificacion,
                      child: Text("Guardar", style: AppTheme.TituloBoton),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 48,
                    child: Text(
                      "Nuevo bloqueo",
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

            _campoTexto(tituloController, "Título del bloqueo"),
            _dropdownTipo(),

            if (tipoBloqueo == 'Puntual' || tipoBloqueo == 'Rango diario')
              _campoFechaInicio(),
            if (tipoBloqueo == 'Rango diario') _campoFechaFin(),
            if (tipoBloqueo == 'Semanal') _campoDiaSemana(),

            _campoHoraInicio(),
            _campoHoraFin(),
          ],
        ),
      ),
    );
  }

  // ----- Campos UI -----

  Widget _campoTexto(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
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

  Widget _dropdownTipo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: tipoBloqueo,
        decoration: InputDecoration(
          labelText: "Tipo de bloqueo",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        dropdownColor: Colors.white,
        items: const [
          DropdownMenuItem(value: 'Puntual', child: Text('Día puntual')),
          DropdownMenuItem(value: 'Rango diario', child: Text('Diario')),
          DropdownMenuItem(value: 'Semanal', child: Text('Semanal')),
        ],
        onChanged: (val) => setState(() => tipoBloqueo = val!),
      ),
    );
  }

  Widget _campoFechaInicio() =>
      _campoFecha(fechaInicioController, "Fecha inicio", (fecha) {
        setState(() {
          fechaInicio = fecha;
          fechaInicioController.text =
              "${fecha.day}/${fecha.month}/${fecha.year}";
        });
      });

  Widget _campoFechaFin() =>
      _campoFecha(fechaFinController, "Fecha fin", (fecha) {
        setState(() {
          fechaFin = fecha;
          fechaFinController.text = "${fecha.day}/${fecha.month}/${fecha.year}";
        });
      });

  Widget _campoFecha(
    TextEditingController controller,
    String label,
    Function(DateTime) onSelect,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today),
          filled: true,
          fillColor: Colors.white,
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
          if (fecha != null) onSelect(fecha);
        },
      ),
    );
  }

  Widget _campoDiaSemana() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: diaSeleccionado,
        decoration: InputDecoration(
          labelText: "Día de la semana",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        items: const [
          DropdownMenuItem(value: 'Lunes', child: Text('Lunes')),
          DropdownMenuItem(value: 'Martes', child: Text('Martes')),
          DropdownMenuItem(value: 'Miércoles', child: Text('Miércoles')),
          DropdownMenuItem(value: 'Jueves', child: Text('Jueves')),
          DropdownMenuItem(value: 'Viernes', child: Text('Viernes')),
          DropdownMenuItem(value: 'Sábado', child: Text('Sábado')),
          DropdownMenuItem(value: 'Domingo', child: Text('Domingo')),
        ],
        onChanged: (val) => setState(() => diaSeleccionado = val),
      ),
    );
  }

  Widget _campoHoraInicio() =>
      _campoHora(horaInicioController, "Hora inicio", (hora) {
        setState(() {
          horaInicio = hora;
          horaInicioController.text = hora.format(context);
        });
      });

  Widget _campoHoraFin() => _campoHora(horaFinController, "Hora fin", (hora) {
    setState(() {
      horaFin = hora;
      horaFinController.text = hora.format(context);
    });
  });

  Widget _campoHora(
    TextEditingController controller,
    String label,
    Function(TimeOfDay) onSelect,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.access_time),
          filled: true,
          fillColor: Colors.white,
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
          if (hora != null) onSelect(hora);
        },
      ),
    );
  }

  // ----- GUARDAR -----
  Future<void> _guardarModificacion() async {
    // Campos obligatorios
    if (tituloController.text.isEmpty ||
        horaInicio == null ||
        horaFin == null ||
        (tipoBloqueo == 'Puntual' && fechaInicio == null) ||
        (tipoBloqueo == 'Rango diario' &&
            (fechaInicio == null || fechaFin == null)) ||
        (tipoBloqueo == 'Semanal' && diaSeleccionado == null)) {
      await _showValidationDialog(
        titulo: "Faltan campos obligatorios",
        mensajeSuperior: "Por favor completa todos los campos requeridos.",
        mensajeDetalle:
            "Verifica título, fecha(s), hora(s) y el día de la semana según el tipo.",
      );
      return;
    }

    // Validación de horas (aplica a los 3 tipos)
    final hi = _toMinutes(horaInicio!);
    final hf = _toMinutes(horaFin!);
    if (hf <= hi) {
      await _showValidationDialog(
        titulo: "Hora fin inválida",
        mensajeSuperior:
            "La hora de fin debe ser posterior a la hora de inicio.",
        mensajeDetalle: "Selecciona una hora mayor para finalizar el bloqueo.",
      );
      return;
    }

    // Validación de fechas para Rango diario
    if (tipoBloqueo == 'Rango diario' &&
        fechaInicio != null &&
        fechaFin != null) {
      final fi = DateTime(
        fechaInicio!.year,
        fechaInicio!.month,
        fechaInicio!.day,
      );
      final ff = DateTime(fechaFin!.year, fechaFin!.month, fechaFin!.day);

      if (ff.isBefore(fi)) {
        await _showValidationDialog(
          titulo: "Rango de fechas inválido",
          mensajeSuperior:
              "La fecha de fin no puede ser anterior a la fecha de inicio.",
          mensajeDetalle:
              "Elige una fecha de finalización igual o posterior a la inicial.",
        );
        return;
      }

      if (ff.isAtSameMomentAs(fi) && hf <= hi) {
        // Mismo día en rango: además exigimos hora fin > inicio
        await _showValidationDialog(
          titulo: "Hora fin inválida (mismo día)",
          mensajeSuperior:
              "Para un rango en el mismo día, la hora de fin debe ser posterior a la hora de inicio.",
          mensajeDetalle: "Elige una hora de fin mayor a la hora de inicio.",
        );
        return;
      }
    }

    // Armar fecha/hora para serializar
    DateTime? inicioCompleto;
    DateTime? finCompleto;

    if (tipoBloqueo != 'Semanal') {
      // Puntual o Rango: combinamos con fecha elegida
      if (fechaInicio != null && horaInicio != null) {
        inicioCompleto = DateTime(
          fechaInicio!.year,
          fechaInicio!.month,
          fechaInicio!.day,
          horaInicio!.hour,
          horaInicio!.minute,
        );
      }
      final baseFin = (fechaFin ?? fechaInicio);
      if (baseFin != null && horaFin != null) {
        finCompleto = DateTime(
          baseFin.year,
          baseFin.month,
          baseFin.day,
          horaFin!.hour,
          horaFin!.minute,
        );
      }
    } else {
      // Semanal: usamos una fecha dummy (hoy) solo para formar HH:mm:ss
      final hoy = DateTime.now();
      inicioCompleto = DateTime(
        hoy.year,
        hoy.month,
        hoy.day,
        horaInicio!.hour,
        horaInicio!.minute,
      );
      finCompleto = DateTime(
        hoy.year,
        hoy.month,
        hoy.day,
        horaFin!.hour,
        horaFin!.minute,
      );
    }

    final tipo =
        tipoBloqueo == 'Puntual'
            ? TipoModificacion.unica
            : tipoBloqueo == 'Rango diario'
            ? TipoModificacion.rangoDiario
            : TipoModificacion.semanal;

    final mod = Modificacion(
      idBloqueo: 0,
      titulo: tituloController.text.trim(),
      tipo: tipo,
      diaSemana: tipo == TipoModificacion.semanal ? diaSeleccionado : null,
      fechaUnica: tipo == TipoModificacion.unica ? inicioCompleto : null,
      fechaInicio: tipo == TipoModificacion.rangoDiario ? fechaInicio : null,
      fechaFinal: tipo == TipoModificacion.rangoDiario ? fechaFin : null,
      // Guardamos horas como DateTime para serializar "HH:mm:ss"
      horaInicio: inicioCompleto,
      horaFin: finCompleto,
    );

    // Log útil
    debugPrint(
      '🟦 Guardando bloqueo: '
      'tipo=$tipoBloqueo, '
      'dia=${mod.diaSemana}, '
      'fUnica=${mod.fechaUnica}, '
      'fIni=${mod.fechaInicio}, '
      'fFin=${mod.fechaFinal}, '
      'hIni=${mod.horaInicio}, '
      'hFin=${mod.horaFin}',
    );

    await context.read<ModificacionesModel>().addBloqueo(mod);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    tituloController.dispose();
    fechaInicioController.dispose();
    fechaFinController.dispose();
    horaInicioController.dispose();
    horaFinController.dispose();
    super.dispose();
  }
}
