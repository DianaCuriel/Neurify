import 'package:flutter/material.dart';
import 'package:neurify/Visuales/Modificaciones.dart';
import 'package:neurify/Visuales/calendario.dart';

class MiBottomNav extends StatelessWidget {
  const MiBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: "Calendario",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.stop_circle),
          label: "Bloqueos",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: "Estadísticas",
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CalendarioPage()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ModificacionesPage()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EstadisticasPage()),
            );
            break;
        }
      },
    );
  }
}

// Página de ejemplo para Estadísticas
class EstadisticasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Estadísticas")),
      body: const Center(child: Text("Aquí van las estadísticas")),
    );
  }
}
