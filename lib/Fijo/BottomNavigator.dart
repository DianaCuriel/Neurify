import 'package:flutter/material.dart';
import 'app_theme.dart';

class MiBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MiBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: AppTheme.primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildNavItem(
            icon: Icons.calendar_month,
            label: "Calendario",
            index: 0,
          ),
          // Dejamos un espacio visual para el botón flotante
          const SizedBox(width: 40),
          _buildNavItem(icon: Icons.bar_chart, label: "Estadísticas", index: 2),
        ],
      ),
    );
  }

  // Widget auxiliar para construir cada botón
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    // Comprueba si este es el ítem seleccionado para resaltarlo
    final isSelected = currentIndex == index;
    final color = isSelected ? Colors.white : Colors.white.withOpacity(0.6);

    return IconButton(
      icon: Icon(icon, color: color, size: 28),
      // Al presionar, llama a la función onTap con el índice de este botón
      onPressed: () => onTap(index),
      tooltip: label,
    );
  }
}
