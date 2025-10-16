import 'package:flutter/material.dart';
import 'app_theme.dart';

class MiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const MiAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        // CORRECCIÓN: Apuntamos al archivo de imagen correcto.
        child: Image.asset('lib/assets/images/app_bar.png'),
      ),

      // Evita que Flutter ponga un botón de regreso automático.
      automaticallyImplyLeading: false,

      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppTheme.primaryColor,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
