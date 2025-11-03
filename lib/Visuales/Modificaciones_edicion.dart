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
      spacing: 6,
      children: List.generate(7, (i) {
        final selected = _diasSemana.contains(i);
        return ChoiceChip(
          label: Text(dias[i]),
          selected: selected,
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
    final modelo = Provider.of<ModificacionesModel>(context, listen: false);

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Editar Bloqueo",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: "Título"),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TipoModificacion>(
                value: _tipo,
                items:
                    TipoModificacion.values
                        .map(
                          (e) =>
                              DropdownMenuItem(value: e, child: Text(e.name)),
                        )
                        .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _tipo = val);
                },
                decoration: const InputDecoration(labelText: "Tipo"),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  "Fecha inicio: ${_fechaInicio.toLocal().toIso8601String().split('T').first}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickFechaInicio,
              ),
              if (_tipo != TipoModificacion.unica)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    "Fecha fin: ${_fechaFin.toLocal().toIso8601String().split('T').first}",
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickFechaFin,
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("Hora inicio: ${_horaInicio.format(context)}"),
                trailing: const Icon(Icons.access_time),
                onTap: _pickHoraInicio,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("Hora fin: ${_horaFin.format(context)}"),
                trailing: const Icon(Icons.access_time),
                onTap: _pickHoraFin,
              ),
              if (_tipo == TipoModificacion.semanal) ...[
                const SizedBox(height: 8),
                Text("Días de la semana"),
                _buildDiasSemanaSelector(),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
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
                        _tipo == TipoModificacion.semanal ? _diasSemana : null,
                  );
                  modelo.removeModificacion(widget.mod);
                  modelo.addModificacion(updated);
                  Navigator.pop(context);
                },
                child: const Text("Guardar cambios"),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  modelo.removeModificacion(widget.mod);
                  Navigator.pop(context);
                },
                child: const Text("Eliminar bloqueo"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
