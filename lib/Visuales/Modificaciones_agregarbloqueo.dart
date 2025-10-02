import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Fijo/app_theme.dart';
import '../Modelos/Modificaciones_model.dart';

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
  int? diaSeleccionado;

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
            // Encabezado X, Título y Guardar
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

            // Campo Título
            _campoTexto(tituloController, "Título del bloqueo"),

            // Dropdown tipo bloqueo
            _dropdownTipo(),

            // Campos de fecha/hora según tipo
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        dropdownColor: Colors.white,
        items: const [
          DropdownMenuItem(value: 'Puntual', child: Text('Puntual')),
          DropdownMenuItem(value: 'Rango diario', child: Text('Diario')),
          DropdownMenuItem(value: 'Semanal', child: Text('Semanal')),
        ],
        onChanged: (val) => setState(() => tipoBloqueo = val!),
      ),
    );
  }

  // Campos fecha/hora
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
      child: DropdownButtonFormField<int>(
        decoration: InputDecoration(
          labelText: "Día de la semana",
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
        value: diaSeleccionado,
        items: const [
          DropdownMenuItem(value: 0, child: Text('Lunes')),
          DropdownMenuItem(value: 1, child: Text('Martes')),
          DropdownMenuItem(value: 2, child: Text('Miércoles')),
          DropdownMenuItem(value: 3, child: Text('Jueves')),
          DropdownMenuItem(value: 4, child: Text('Viernes')),
          DropdownMenuItem(value: 5, child: Text('Sábado')),
          DropdownMenuItem(value: 6, child: Text('Domingo')),
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
            initialTime: TimeOfDay.now(),
          );
          if (hora != null) onSelect(hora);
        },
      ),
    );
  }

  void _guardarModificacion() {
    if (tituloController.text.isEmpty ||
        horaInicio == null ||
        horaFin == null ||
        (tipoBloqueo == 'Puntual' && fechaInicio == null) ||
        (tipoBloqueo == 'Rango diario' &&
            (fechaInicio == null || fechaFin == null)) ||
        (tipoBloqueo == 'Semanal' && diaSeleccionado == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faltan campos obligatorios')),
      );
      return;
    }

    final model = Provider.of<ModificacionesModel>(context, listen: false);
    model.addModificacion(
      Modificacion(
        titulo: tituloController.text,
        fechaInicio: fechaInicio ?? DateTime.now(),
        fechaFin: fechaFin ?? fechaInicio ?? DateTime.now(),
        horaInicio: horaInicio!,
        horaFin: horaFin!,
        tipo:
            tipoBloqueo == 'Puntual'
                ? TipoModificacion.unica
                : tipoBloqueo == 'Rango diario'
                ? TipoModificacion.rangoDiario
                : TipoModificacion.semanal,
        diasSemana: tipoBloqueo == 'Semanal' ? [diaSeleccionado!] : null,
      ),
    );

    Navigator.pop(context);
  }
}
