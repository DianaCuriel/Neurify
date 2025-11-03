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
  late DateTime _fechaInicio;
  late DateTime _fechaFin;
  late TimeOfDay _horaInicio;
  late TimeOfDay _horaFin;
  late List<int> _diasSemana;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.mod.titulo);
    _tipo = widget.mod.tipo;
    _fechaInicio = widget.mod.fechaInicio;
    _fechaFin = widget.mod.fechaFin;
    _horaInicio = widget.mod.horaInicio;
    _horaFin = widget.mod.horaFin;
    _diasSemana = widget.mod.diasSemana ?? [];
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  Future<void> _pickFechaInicio() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fechaInicio,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
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
          ],
        ),
      ),
    );
  }

  // ==== Widgets reutilizables ====

  InputDecoration _decoracionCampo(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
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
      ),
    );
  }

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
      ),
    );
  }
}
