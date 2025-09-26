import 'package:flutter/material.dart';
import 'app_theme.dart';

class MiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // título dinámico
  final IconData? leadingIcon; // ícono opcional dinámico

  const MiAppBar({super.key, required this.title, this.leadingIcon});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(leadingIcon ?? Icons.handshake),
      ),
      title: Text(title),
      backgroundColor: AppTheme.primaryColor,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
