import 'package:flutter/material.dart';
class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    Center(child: Text("Dashboard Screen")),
    Center(child: Text("Robots Screen")),
    Center(child: Text("Orders Screen")),
    Center(child: Text("Inventory Screen")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // updates screen
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: "Robots"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: "Inventory"),
        ],
      ),
    );
  }
}
