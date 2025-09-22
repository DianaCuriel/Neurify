import 'package:flutter/material.dart';
import 'app_theme.dart';

class MiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MiAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.handshake),
      ),
      title: const Text("Calendario"),
      backgroundColor: AppTheme.primaryColor,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
