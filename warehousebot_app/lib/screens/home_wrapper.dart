import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'order_details_screen.dart';
import 'inventory_screen.dart';
import 'robot_analytics_screen.dart';
import '../utils/constants.dart';

class HomeWrapper extends StatefulWidget {
  static const String routeName = '/home';

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    DashboardScreen(),
    RobotAnalyticsScreen(),
    InventoryScreen(),
    OrderDetailsScreen(),
  ];

  void _onTabTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: "Analytics",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: "Inventory",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Orders",
          ),
        ],
      ),
    );
  }
}
