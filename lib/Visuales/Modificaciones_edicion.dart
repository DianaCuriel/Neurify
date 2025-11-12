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
<<<<<<< HEAD
  late DateTime _fechaInicio;
  late DateTime _fechaFin;
  late TimeOfDay _horaInicio;
  late TimeOfDay _horaFin;
  late List<int> _diasSemana;
=======
  late DateTime? _fechaUnica;
  late DateTime? _fechaInicio;
  late DateTime? _fechaFinal;
  late DateTime? _horaInicio;
  late DateTime? _horaFin;
  String? _diaSemana;
>>>>>>> parent of 5a2e870 (mal)

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.mod.titulo);
    _tipo = widget.mod.tipo;
    _fechaInicio = widget.mod.fechaInicio;
<<<<<<< HEAD
    _fechaFin = widget.mod.fechaFin;
    _horaInicio = widget.mod.horaInicio;
    _horaFin = widget.mod.horaFin;
    _diasSemana = widget.mod.diasSemana ?? [];
=======
    _fechaFinal = widget.mod.fechaFinal;
    _horaInicio = widget.mod.horaInicio;
    _horaFin = widget.mod.horaFin;
    _diaSemana = widget.mod.diaSemana;
>>>>>>> parent of 5a2e870 (mal)
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
<<<<<<< HEAD
  Future<void> _pickFechaInicio() async {
=======
=======
>>>>>>> parent of 5a2e870 (mal)
  // ====== Funciones para seleccionar fecha y hora ======

  Future<DateTime?> _pickDateTime(
    BuildContext context,
    DateTime? initial,
  ) async {
<<<<<<< HEAD
>>>>>>> parent of 5a2e870 (mal)
=======
>>>>>>> parent of 5a2e870 (mal)
    final date = await showDatePicker(
      context: context,
      initialDate: _fechaInicio,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
<<<<<<< HEAD
<<<<<<< HEAD
    if (date != null) setState(() => _fechaInicio = date);
  }

  Future<void> _pickFechaFin() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fechaFin,
      firstDate: _fechaInicio,
      lastDate: DateTime(2030),
    );
    if (date != null) setState(() => _fechaFin = date);
  }

  Future<void> _pickHoraInicio() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _horaInicio,
    );
    if (time != null) setState(() => _horaInicio = time);
  }

  Future<void> _pickHoraFin() async {
    final time = await showTimePicker(context: context, initialTime: _horaFin);
    if (time != null) setState(() => _horaFin = time);
  }

  Widget _buildDiasSemanaSelector() {
    final dias = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: List.generate(7, (i) {
        final selected = _diasSemana.contains(i);
        return ChoiceChip(
          label: Text(dias[i]),
          selected: selected,
          selectedColor: AppTheme.primaryColor.withOpacity(0.2),
          labelStyle: TextStyle(
            color: selected ? AppTheme.primaryColor : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          onSelected: (val) {
            setState(() {
              if (val) {
                _diasSemana.add(i);
              } else {
                _diasSemana.remove(i);
              }
            });
          },
        );
      }),
    );
=======
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
>>>>>>> parent of 5a2e870 (mal)
=======
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
>>>>>>> parent of 5a2e870 (mal)
  }

  @override
  Widget build(BuildContext context) {
    final Map<TipoModificacion, String> nombresTipo = {
      TipoModificacion.unica: "Día puntual",
      TipoModificacion.rangoDiario: "Rango diario",
      TipoModificacion.semanal: "Semanal",
    };

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
<<<<<<< HEAD
<<<<<<< HEAD
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
                      onPressed: () {
                        final updated = Modificacion(
                          titulo: _tituloController.text,
                          fechaInicio: _fechaInicio,
                          fechaFin: _fechaFin,
                          horaInicio: _horaInicio,
                          horaFin: _horaFin,
                          tipo: _tipo,
                          diasSemana:
                              _tipo == TipoModificacion.semanal
                                  ? _diasSemana
                                  : null,
                        );
                        modelo.removeModificacion(widget.mod);
                        modelo.addModificacion(updated);
                        Navigator.pop(context);
                      },
                      child: Text("Guardar", style: AppTheme.TituloBoton),
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
            ),
            const SizedBox(height: 20),

            // Campo Título
            _campoTexto(_tituloController, "Título del bloqueo"),

            // Tipo de modificación
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DropdownButtonFormField<TipoModificacion>(
                value: _tipo,
                decoration: _decoracionCampo("Tipo de bloqueo"),
                dropdownColor: Colors.white,
                items:
                    TipoModificacion.values
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(nombresTipo[e] ?? e.name),
                          ),
                        )
                        .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _tipo = val);
                },
              ),
=======
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
>>>>>>> parent of 5a2e870 (mal)
            ),

            // Fechas y horas
            _campoFecha("Fecha inicio", _fechaInicio, _pickFechaInicio),
            if (_tipo != TipoModificacion.unica)
              _campoFecha("Fecha fin", _fechaFin, _pickFechaFin),
            _campoHora("Hora inicio", _horaInicio, _pickHoraInicio),
            _campoHora("Hora fin", _horaFin, _pickHoraFin),

            if (_tipo == TipoModificacion.semanal) ...[
              const SizedBox(height: 8),
              Text(
                "Días de la semana",
                style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              _buildDiasSemanaSelector(),
            ],
            const SizedBox(height: 24),
=======
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
<<<<<<< HEAD
>>>>>>> parent of 5a2e870 (mal)
=======
>>>>>>> parent of 5a2e870 (mal)
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
<<<<<<< HEAD
  // ==== Widgets reutilizables ====
=======
  // ====== Widgets auxiliares ======
>>>>>>> parent of 5a2e870 (mal)
=======
  // ====== Widgets auxiliares ======
>>>>>>> parent of 5a2e870 (mal)

  InputDecoration _decoracionCampo(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
<<<<<<< HEAD
<<<<<<< HEAD
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
=======
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
>>>>>>> parent of 5a2e870 (mal)
=======
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
>>>>>>> parent of 5a2e870 (mal)
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

<<<<<<< HEAD
<<<<<<< HEAD
  Widget _campoFecha(String label, DateTime fecha, Function() onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        readOnly: true,
        decoration: _decoracionCampo(label).copyWith(
          suffixIcon: const Icon(Icons.calendar_today),
          hintText: "${fecha.day}/${fecha.month}/${fecha.year}",
        ),
        onTap: onTap,
=======
=======
>>>>>>> parent of 5a2e870 (mal)
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
<<<<<<< HEAD
>>>>>>> parent of 5a2e870 (mal)
      ),
    );
  }

<<<<<<< HEAD
  Widget _campoHora(String label, TimeOfDay hora, Function() onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        readOnly: true,
        decoration: _decoracionCampo(label).copyWith(
          suffixIcon: const Icon(Icons.access_time),
          hintText: hora.format(context),
        ),
        onTap: onTap,
=======
>>>>>>> parent of 5a2e870 (mal)
      ),
=======
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
<<<<<<< HEAD
>>>>>>> parent of 5a2e870 (mal)
=======
>>>>>>> parent of 5a2e870 (mal)
    );
  }
}
