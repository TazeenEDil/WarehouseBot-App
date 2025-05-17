import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WarehouseSimulationScreen(),
    );
  }
}

class WarehouseSimulationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A2E),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              child: Text('T'),
            ),
            SizedBox(width: 8),
            Text(
              'Tazeen-e-Dil',
              style: TextStyle(color: Colors.white),
            ),
            Spacer(),
            Icon(Icons.exit_to_app, color: Color(0xFF4AFFCD)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Color(0xFF1A1A2E),
            padding: EdgeInsets.all(16),
            child: Text(
              'Warehouse Simulation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4AFFCD),
              ),
            ),
          ),
          Container(
            height: 300,
            color: Color(0xFF1A1A2E),
            child: Image.asset('assets/images/simulation.png'),
             
          ),
          Container(
            color: Color(0xFF1A1A2E),
            padding: EdgeInsets.all(16),
            child: Text(
              'Current Operations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4AFFCD),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            color: Color(0xFF2E2E3A),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Robot 1', style: TextStyle(color: Colors.white)),
                    Text('Idle', style: TextStyle(color: Colors.white)),
                    Text('Job ID: Null', style: TextStyle(color: Colors.white)),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Robot 2', style: TextStyle(color: Colors.white)),
                    Text('Busy', style: TextStyle(color: Color(0xFFFF0000))),
                    Text('Job ID: 1214', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF1A1A2E),
        selectedItemColor: Color(0xFF4AFFCD),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: ''),
        ],
      ),
    );
  }
}