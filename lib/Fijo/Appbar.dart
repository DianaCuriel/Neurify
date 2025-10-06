import 'package:flutter/material.dart';
import 'app_theme.dart';

class MiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLogout;

  const MiAppBar({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // --- MODIFICACIÓN ---
      // Cambiamos la ruta para que apunte a tu nueva imagen.
      title: Image.asset('assets/images/app_bar.png', height: 40),
      centerTitle: true,
      backgroundColor: AppTheme.primaryColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: onLogout,
          tooltip: 'Cerrar sesión',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
