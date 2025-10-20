import 'package:flutter/material.dart';

class WorkTickAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSettings;
  final VoidCallback? onLogout;
  
  const WorkTickAppBar({super.key, this.onSettings, this.onLogout});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      toolbarHeight: 100,
      titleSpacing: 16,
      title: Row(
        children: [
          Image.asset(
            'assets/logo/worktick.png',
            height: 180,
            // dla dark ustaw kolor na biały, dla light zostaw naturalny
            color: isDark ? Colors.white : null,
            colorBlendMode: BlendMode.srcIn, // ważne: kolor „wypełni” alfa
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.settings), onPressed: onSettings),
        IconButton(icon: const Icon(Icons.logout), onPressed: onLogout),
      ],
    );
  }
}
