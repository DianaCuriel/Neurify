import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Fijo/Appbar.dart';
import '../Fijo/BottomNavigator.dart';
import '../Fijo/app_theme.dart';
import '../Modelos/Calendario_model.dart';

class EditarCitaPage extends StatefulWidget {
  final Cliente cita;

  const EditarCitaPage({super.key, required this.cita});

  @override
  _EditarCitaPageState createState() => _EditarCitaPageState();
}

class _EditarCitaPageState extends State<EditarCitaPage> {
  late TextEditingController _nombreController;
  late TextEditingController _asuntoController;
  late TextEditingController _numeroController;
  late DateTime _fechaHora;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.cita.nombre);
    _asuntoController = TextEditingController(text: widget.cita.asunto);
    _numeroController = TextEditingController(text: widget.cita.numero);
    _fechaHora = widget.cita.fechaHora;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _asuntoController.dispose();
    _numeroController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fechaHora,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fechaHora),
    );
    if (time == null) return;

    setState(() {
      _fechaHora = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final calendarioModel = Provider.of<CalendarioModel>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: const MiAppBar(title: "Modificar Cita"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: "Nombre"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _asuntoController,
                decoration: const InputDecoration(labelText: "Asunto"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _numeroController,
                decoration: const InputDecoration(labelText: "Número"),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("Fecha y hora: ${_fechaHora.toString()}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDateTime,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                onPressed: () async {
                  final updatedCita = Cliente(
                    id: widget.cita.id,
                    nombre: _nombreController.text,
                    asunto: _asuntoController.text,
                    numero: _numeroController.text,
                    fechaHora: _fechaHora,
                  );

                  // Actualizamos el modelo y la BD si existe la función
                  await calendarioModel.updateCita(updatedCita);

                  Navigator.pop(context);
                },
                child: const Text("Guardar cambios"),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  await calendarioModel.removeCita(widget.cita);
                  Navigator.pop(context);
                },
                child: const Text("Eliminar cita"),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MiBottomNav(currentIndex: 0),
    );
  }
}
