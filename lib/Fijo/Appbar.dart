import 'package:flutter/material.dart';
import 'app_theme.dart';

class MiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // título dinámico

  const MiAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // quita la flecha de regreso
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          'assets/images/app_bar.png', // <-- ruta de tu imagen directamente aquí
          fit: BoxFit.contain,
        ),
      ),
      title: Text(title),
      backgroundColor: AppTheme.primaryColor,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
