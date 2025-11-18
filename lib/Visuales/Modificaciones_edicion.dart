import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:neurify/fijo/app_theme.dart';
import 'package:neurify/modelos/modificaciones_model.dart';

class EditarModificacionPage extends StatefulWidget {
  final Modificacion mod;

  const EditarModificacionPage({Key? key, required this.mod}) : super(key: key);

  @override
  State<EditarModificacionPage> createState() => _EditarModificacionPageState();
}

class _EditarModificacionPageState extends State<EditarModificacionPage> {
  late TextEditingController _tituloController;
  late TipoModificacion _tipo;
  late DateTime? _fechaUnica;
  late DateTime? _fechaInicio;
  late DateTime? _fechaFinal;
  late TimeOfDay? _horaInicio;
  late TimeOfDay? _horaFin;
  String? _diaSemana;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.mod.titulo);
    _tipo = widget.mod.tipo;
    _fechaUnica = widget.mod.fechaUnica;
    _fechaInicio = widget.mod.fechaInicio;
    _fechaFinal = widget.mod.fechaFinal;
    _horaInicio =
        widget.mod.horaInicio != null
            ? TimeOfDay.fromDateTime(widget.mod.horaInicio!)
            : null;
    _horaFin =
        widget.mod.horaFin != null
            ? TimeOfDay.fromDateTime(widget.mod.horaFin!)
            : null;
    _diaSemana = widget.mod.diaSemana;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  // ============== Helpers ==============
  InputDecoration _decoracionCampo(String hint, {IconData? icon}) =>
      InputDecoration(
        hintText: hint,
        suffixIcon: icon != null ? Icon(icon) : null,
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
      );

  String _formatFecha(DateTime? fecha) =>
      fecha == null
          ? "Seleccionar..."
          : "${fecha.day}/${fecha.month}/${fecha.year}";

  String _formatHora(TimeOfDay? hora) =>
      hora == null
          ? "Seleccionar..."
          : "${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}";

  Future<DateTime?> _pickFecha(BuildContext context, DateTime? initial) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    return picked ?? initial;
  }

  Future<TimeOfDay?> _pickHora(BuildContext context, TimeOfDay? initial) async {
    return await showTimePicker(
      context: context,
      initialTime: initial ?? TimeOfDay.now(),
    );
  }

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
  // =====================================

  // ============== UI principal ==============
  @override
  Widget build(BuildContext context) {
    final modelo = Provider.of<ModificacionesModel>(context, listen: false);

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
            _encabezado(context, modelo),
            const SizedBox(height: 20),
            AppTheme.subtitleText('Detalles del bloqueo'),
            const SizedBox(height: 12),
            _campoTexto(_tituloController, "Título del bloqueo"),

            // Tipo bloqueado (no editable)
            AbsorbPointer(
              absorbing: true,
              child: Opacity(
                opacity: 0.6,
                child: DropdownButtonFormField<TipoModificacion>(
                  value: _tipo,
                  decoration: _decoracionCampo("Tipo de bloqueo"),
                  items:
                      TipoModificacion.values
                          .map(
                            (e) =>
                                DropdownMenuItem(value: e, child: Text(e.name)),
                          )
                          .toList(),
                  onChanged: null,
                ),
              ),
            ),

            const SizedBox(height: 20),
            AppTheme.subtitleText('Configuración de tiempo'),
            const SizedBox(height: 12),

            if (_tipo == TipoModificacion.unica)
              _campoFechaEditable("Fecha única", _fechaUnica, (val) {
                setState(() => _fechaUnica = val);
              }),

            if (_tipo == TipoModificacion.rangoDiario) ...[
              _campoFechaEditable("Fecha de inicio", _fechaInicio, (val) {
                setState(() => _fechaInicio = val);
              }),
              _campoFechaEditable("Fecha final", _fechaFinal, (val) {
                setState(() => _fechaFinal = val);
              }),
            ],

            if (_tipo == TipoModificacion.semanal) _campoDiaSemana(),

            _campoHoraEditable("Hora inicio", _horaInicio, (val) {
              setState(() => _horaInicio = val);
            }),
            _campoHoraEditable("Hora fin", _horaFin, (val) {
              setState(() => _horaFin = val);
            }),
          ],
        ),
      ),
    );
  }

  // ============== Componentes ==============
  Widget _encabezado(BuildContext context, ModificacionesModel modelo) {
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
              onPressed: () async {
                // ===== Validaciones (idénticas a "agregar") =====
                if (_tituloController.text.trim().isEmpty) {
                  await _showBlockingDialog(
                    title: "Datos incompletos",
                    line1: "Falta el título del bloqueo.",
                    line2: "Completa el título para continuar.",
                  );
                  return;
                }

                // Campos requeridos por tipo
                if (_tipo == TipoModificacion.unica) {
                  if (_fechaUnica == null ||
                      _horaInicio == null ||
                      _horaFin == null) {
                    await _showBlockingDialog(
                      title: "Datos incompletos",
                      line1:
                          "Para un bloqueo puntual debes elegir fecha, hora inicio y hora fin.",
                      line2: "Completa los campos faltantes.",
                    );
                    return;
                  }
                } else if (_tipo == TipoModificacion.rangoDiario) {
                  if (_fechaInicio == null ||
                      _fechaFinal == null ||
                      _horaInicio == null ||
                      _horaFin == null) {
                    await _showBlockingDialog(
                      title: "Datos incompletos",
                      line1:
                          "Para un bloqueo diario debes elegir fecha inicio, fecha fin, hora inicio y hora fin.",
                      line2: "Completa los campos faltantes.",
                    );
                    return;
                  }
                } else if (_tipo == TipoModificacion.semanal) {
                  if (_diaSemana == null ||
                      _horaInicio == null ||
                      _horaFin == null) {
                    await _showBlockingDialog(
                      title: "Datos incompletos",
                      line1:
                          "Para un bloqueo semanal debes elegir el día y las horas.",
                      line2: "Completa los campos faltantes.",
                    );
                    return;
                  }
                }

                // Hora fin > hora inicio (en todos los tipos)
                if (_horaInicio != null && _horaFin != null) {
                  if (_toMinutes(_horaFin!) <= _toMinutes(_horaInicio!)) {
                    await _showBlockingDialog(
                      title: "Hora inválida",
                      line1:
                          "La hora de fin no puede ser anterior o igual a la hora de inicio.",
                      line2: "Elige una hora de fin posterior.",
                    );
                    return;
                  }
                }

                // Rango de fechas válido: fechaFinal >= fechaInicio
                if (_tipo == TipoModificacion.rangoDiario &&
                    _fechaInicio != null &&
                    _fechaFinal != null &&
                    _fechaFinal!.isBefore(_fechaInicio!)) {
                  await _showBlockingDialog(
                    title: "Rango de fechas inválido",
                    line1:
                        "La fecha de fin no puede ser anterior a la fecha de inicio.",
                    line2: "Selecciona una fecha de fin posterior o igual.",
                  );
                  return;
                }
                // ===== Fin validaciones =====

                // Construir objeto actualizado
                final now = DateTime.now();
                final updated = Modificacion(
                  idBloqueo: widget.mod.idBloqueo,
                  titulo: _tituloController.text.trim(),
                  tipo: _tipo,
                  diaSemana:
                      _tipo == TipoModificacion.semanal ? _diaSemana : null,
                  fechaUnica:
                      _tipo == TipoModificacion.unica ? _fechaUnica : null,
                  fechaInicio:
                      _tipo == TipoModificacion.rangoDiario
                          ? _fechaInicio
                          : null,
                  fechaFinal:
                      _tipo == TipoModificacion.rangoDiario
                          ? _fechaFinal
                          : null,
                  // Guardamos horas como DateTime (solo para serializar HH:mm:ss)
                  horaInicio:
                      _horaInicio == null
                          ? null
                          : DateTime(
                            now.year,
                            now.month,
                            now.day,
                            _horaInicio!.hour,
                            _horaInicio!.minute,
                          ),
                  horaFin:
                      _horaFin == null
                          ? null
                          : DateTime(
                            now.year,
                            now.month,
                            now.day,
                            _horaFin!.hour,
                            _horaFin!.minute,
                          ),
                );

                await modelo.updateBloqueo(updated);
                if (context.mounted) Navigator.pop(context);
              },
              child: AppTheme.tituloBoton("Guardar"),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 48,
            child: Text(
              "Editar bloqueo",
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
        decoration: _decoracionCampo(hint),
      ),
    );
  }

  Widget _campoFechaEditable(
    String label,
    DateTime? fecha,
    Function(DateTime?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        readOnly: true,
        controller: TextEditingController(text: _formatFecha(fecha)),
        decoration: _decoracionCampo(label, icon: Icons.calendar_month),
        onTap: () async {
          final picked = await _pickFecha(context, fecha);
          onChanged(picked);
        },
      ),
    );
  }

  Widget _campoHoraEditable(
    String label,
    TimeOfDay? hora,
    Function(TimeOfDay?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        readOnly: true,
        controller: TextEditingController(text: _formatHora(hora)),
        decoration: _decoracionCampo(label, icon: Icons.access_time),
        onTap: () async {
          final picked = await _pickHora(context, hora);
          onChanged(picked);
        },
      ),
    );
  }

  Widget _campoDiaSemana() {
    final dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _diaSemana,
        decoration: _decoracionCampo("Día de la semana"),
        items:
            dias
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
        onChanged: (val) => setState(() => _diaSemana = val),
      ),
    );
  }
}
