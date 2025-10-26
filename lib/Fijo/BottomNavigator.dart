import 'package:flutter/material.dart';
import 'package:neurify/Visuales/Modificaciones.dart';
import 'package:neurify/Visuales/calendario.dart';
import 'package:neurify/Visuales/estadisticas_page.dart';
// Importa tu AppTheme si quieres usar el color primario
import 'package:neurify/Fijo/app_theme.dart';

class MiBottomNav extends StatelessWidget {
  // 1. AÑADE ESTA LÍNEA: Declara la variable para el índice
  final int currentIndex;

  // 2. MODIFICA EL CONSTRUCTOR: Haz que pida el 'currentIndex'
  const MiBottomNav({
    super.key,
    required this.currentIndex, // <-- Esto soluciona el error
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      // 3. USA LA VARIABLE: Pasa el 'currentIndex' al widget de Flutter
      currentIndex: currentIndex,

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

      // 4. (Recomendado) Añade estos estilos
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: Colors.grey[600],
      type:
          BottomNavigationBarType
              .fixed, // Asegura que todos los 3 items se vean

      onTap: (index) {
        // 5. (Recomendado) Evita navegar si ya estamos en esa página
        if (index == currentIndex) {
          return;
        }

        Widget page;
        switch (index) {
          case 0:
            page = CalendarioPage(); // Asumo que existe
            break;
          case 1:
            page = ModificacionesPage(); // Asumo que existe
            break;
          case 2:
          default:
            page = const EstadisticasPage();
            break;
        }

        // 6. (Recomendado) Usa pushReplacement para NO apilar pantallas
        Navigator.pushReplacement(
          context,
          // Ruta sin animación para que se sienta como un Tab
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => page,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
    );
  }
}
