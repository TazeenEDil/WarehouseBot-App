import 'package:flutter/material.dart';
import '../screens/dashboard/dashboardScreen.dart';
import '../screens/inventory/inventoryScreen.dart';
import '../screens/robots/robotAnalyticsScreen.dart';
import '../screens/orders/ordersScreen.dart';
import '../screens/jobs/jobTrackingScreen.dart';

class BottomNav extends StatefulWidget {
  final int currentIndex;
  const BottomNav({super.key, this.currentIndex = 0});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    DashboardScreen(),
    JobTrackingScreen(),
    InventoryScreen(),
    RobotAnalyticsScreen(),
    OrdersScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        height: 65,
        backgroundColor: Colors.black,
        indicatorColor: Colors.blueGrey.shade800,
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.home, color: Colors.white),
            label: "Dashboard",
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.assignment, color: Colors.white),
            label: "Jobs",
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.inventory_2, color: Colors.white),
            label: "Inventory",
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.smart_toy, color: Colors.white),
            label: "Robots",
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_checkout_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.shopping_cart_checkout, color: Colors.white),
            label: "Orders",
          ),
        ],
      ),
    );
  }
}