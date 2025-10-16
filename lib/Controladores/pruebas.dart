import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../Modelos/Calendario_model.dart';
import '../Fijo/app_theme.dart';

class TestDBPage extends StatelessWidget {
  const TestDBPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final modelo = context.watch<CalendarioModel>();
    final citas = modelo.citas; // Accede a todas las citas

    return Scaffold(
      appBar: AppBar(
        title: const Text("Simulación Base de Datos"),
        backgroundColor: AppTheme.primaryColor,
      ),
      body:
          citas.isEmpty
              ? const Center(
                child: Text(
                  "No hay citas en la base de datos",
                  style: TextStyle(fontSize: 16),
                ),
              )
              : ListView.builder(
                itemCount: citas.length,
                itemBuilder: (context, index) {
                  final cita = citas[index];
                  final fechaFormateada = DateFormat(
                    "dd/MM/yyyy HH:mm",
                  ).format(cita.fechaHora);

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: AppTheme.caja,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Nombre: ${cita.nombre}",
                            style: AppTheme.sutittleStyle,
                          ),
                          Text(
                            "Asunto: ${cita.asunto}",
                            style: AppTheme.bodyStyle,
                          ),
                          Text(
                            "Fecha/Hora: $fechaFormateada",
                            style: AppTheme.bodyStyle,
                          ),
                          Text(
                            "Número: ${cita.numero}",
                            style: AppTheme.bodyStyle,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Simular agregar una cita
          modelo.addCita(
            Cliente(
              nombre: "Prueba",
              asunto: "Test DB",
              numero: "1234567890",
              fechaHora: DateTime.now().add(const Duration(hours: 2)),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
