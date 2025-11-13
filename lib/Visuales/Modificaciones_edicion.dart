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

  // ==================== Helpers ====================

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

  String _formatFecha(DateTime? fecha) {
    if (fecha == null) return "Seleccionar...";
    return "${fecha.day}/${fecha.month}/${fecha.year}";
  }

  String _formatHora(TimeOfDay? hora) {
    if (hora == null) return "Seleccionar...";
    final h = hora.hour.toString().padLeft(2, '0');
    final m = hora.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  Future<DateTime?> _pickFecha(BuildContext context, DateTime? initial) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    return picked ?? initial;
  }

  Future<TimeOfDay?> _pickHora(BuildContext context, TimeOfDay? initial) async {
    return await showTimePicker(
      context: context,
      initialTime: initial ?? TimeOfDay.now(),
    );
  }

  // ==================== UI principal ====================

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

  // ==================== Componentes ====================

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
                final now = DateTime.now();
                final updated = Modificacion(
                  idBloqueo: widget.mod.idBloqueo,
                  titulo: _tituloController.text,
                  tipo: _tipo,
                  diaSemana:
                      _tipo == TipoModificacion.semanal ? _diaSemana : null,
                  fechaUnica: _fechaUnica,
                  fechaInicio: _fechaInicio,
                  fechaFinal: _fechaFinal,
                  horaInicio:
                      _horaInicio != null
                          ? DateTime(
                            now.year,
                            now.month,
                            now.day,
                            _horaInicio!.hour,
                            _horaInicio!.minute,
                          )
                          : null,
                  horaFin:
                      _horaFin != null
                          ? DateTime(
                            now.year,
                            now.month,
                            now.day,
                            _horaFin!.hour,
                            _horaFin!.minute,
                          )
                          : null,
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
