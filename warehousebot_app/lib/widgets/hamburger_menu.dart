import 'package:flutter/material.dart';

class AppHamburgerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu, color: Colors.white, size: 28),
      onPressed: () {
        // TODO: Add Drawer or Side Menu Navigation
        // Example:
        // Scaffold.of(context).openDrawer();
      },
    );
  }
}
