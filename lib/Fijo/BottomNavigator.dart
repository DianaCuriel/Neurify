import 'package:flutter/material.dart';

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
    );
  }
}
