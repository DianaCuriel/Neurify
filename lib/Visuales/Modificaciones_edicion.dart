import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Fijo/app_theme.dart';
import '../Modelos/Modificaciones_model.dart';

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
  late DateTime? _horaInicio;
  late DateTime? _horaFin;
  String? _diaSemana;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.mod.titulo);
    _tipo = widget.mod.tipo;
    _fechaUnica = widget.mod.fechaUnica;
    _fechaInicio = widget.mod.fechaInicio;
    _fechaFinal = widget.mod.fechaFinal;
    _horaInicio = widget.mod.horaInicio;
    _horaFin = widget.mod.horaFin;
    _diaSemana = widget.mod.diaSemana;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  // ====== Funciones para seleccionar fecha y hora ======

  Future<DateTime?> _pickDateTime(
    BuildContext context,
    DateTime? initial,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null) return initial;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial ?? DateTime.now()),
    );
    if (time == null) return DateTime(date.year, date.month, date.day);

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Seleccionar...';
    return "${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final modelo = Provider.of<ModificacionesModel>(context, listen: false);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
            // ===== Encabezado =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  "Editar bloqueo",
                  style: AppTheme.sutittleStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    final updated = Modificacion(
                      idBloqueo: widget.mod.idBloqueo,
                      titulo: _tituloController.text,
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
                      horaInicio: _horaInicio,
                      horaFin: _horaFin,
                    );
                    modelo.addBloqueo(updated);
                    Navigator.pop(context);
                  },
                  child: Text("Guardar", style: AppTheme.TituloBoton),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _campoTexto(_tituloController, "Título del bloqueo"),

            DropdownButtonFormField<TipoModificacion>(
              value: _tipo,
              decoration: _decoracionCampo("Tipo de bloqueo"),
              items:
                  TipoModificacion.values
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.name)),
                      )
                      .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _tipo = val);
              },
            ),

            const SizedBox(height: 16),

            if (_tipo == TipoModificacion.unica)
              _campoFechaHora(
                "Fecha única",
                _fechaUnica,
                (val) => setState(() => _fechaUnica = val),
              ),

            if (_tipo == TipoModificacion.rangoDiario) ...[
              _campoFechaHora(
                "Fecha inicio",
                _fechaInicio,
                (val) => setState(() => _fechaInicio = val),
              ),
              _campoFechaHora(
                "Fecha final",
                _fechaFinal,
                (val) => setState(() => _fechaFinal = val),
              ),
            ],

            if (_tipo == TipoModificacion.semanal) _campoDiaSemana(),

            const SizedBox(height: 16),

            _campoFechaHora(
              "Hora inicio",
              _horaInicio,
              (val) => setState(() => _horaInicio = val),
            ),
            _campoFechaHora(
              "Hora fin",
              _horaFin,
              (val) => setState(() => _horaFin = val),
            ),
          ],
        ),
      ),
    );
  }

  // ====== Widgets auxiliares ======

  InputDecoration _decoracionCampo(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );

  Widget _campoTexto(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: _decoracionCampo(label),
      ),
    );
  }

  Widget _campoFechaHora(
    String label,
    DateTime? valor,
    Function(DateTime?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final dt = await _pickDateTime(context, valor);
          onChanged(dt);
        },
        child: InputDecorator(
          decoration: _decoracionCampo(label),
          child: Text(_formatDateTime(valor)),
        ),
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
    return DropdownButtonFormField<String>(
      value: _diaSemana,
      decoration: _decoracionCampo("Día de la semana"),
      items:
          dias.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
      onChanged: (val) => setState(() => _diaSemana = val),
    );
  }
}
