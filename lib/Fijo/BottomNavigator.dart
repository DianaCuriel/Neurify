import 'package:flutter/material.dart';
import 'package:neurify/Visuales/Modificaciones.dart';
import 'package:neurify/Visuales/calendario.dart';
import 'package:neurify/Visuales/estadisticas_page.dart';
import 'package:neurify/Visuales/CerrarSesion.dart';
import 'app_theme.dart';

class MiBottomNav extends StatefulWidget {
  final int currentIndex; // índice inicial

  const MiBottomNav({super.key, this.currentIndex = 0});

  @override
  State<MiBottomNav> createState() => _MiBottomNavState();
}

class _MiBottomNavState extends State<MiBottomNav> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex; // inicializamos con el parámetro
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navegación
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CalendarioPage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ModificacionesPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EstadisticasPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CerrarsesionPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      backgroundColor: Colors.white,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.calendar_month,
            color: _selectedIndex == 0 ? AppTheme.primaryColor : Colors.grey,
          ),
          label: "Calendario",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.stop_circle,
            color: _selectedIndex == 1 ? AppTheme.primaryColor : Colors.grey,
          ),
          label: "Bloqueos",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.bar_chart,
            color: _selectedIndex == 2 ? AppTheme.primaryColor : Colors.grey,
          ),
          label: "Estadísticas",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.gps_fixed,
            color: _selectedIndex == 3 ? AppTheme.primaryColor : Colors.grey,
          ),
          label: "Configuraciones",
        ),
      ],
    );
  }
}
