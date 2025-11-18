import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/robot_service.dart';
import '../../utils/constants.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> robots = [];
  bool isLoading = true;

  Map<String, String> quickStats = {
    'battery': '—',
    'speed': '—',
    'tasks': '—',
  };

  @override
  void initState() {
    super.initState();
    _loadRobotData();
  }

  void _loadRobotData() async {
    try {
      final result = await RobotService.fetchRobots(1);

      if (result.isNotEmpty) {
        setState(() {
          final robot = result[0];

          quickStats['battery'] = robot['batteryLevel'].toString();
          quickStats['speed'] = "2.4 m/s";
          quickStats['tasks'] = "12";

          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading robots: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topCards = [
      {'title': 'Battery', 'value': quickStats['battery'] ?? '—'},
      {'title': 'Speed', 'value': quickStats['speed'] ?? '—'},
      {'title': 'Tasks', 'value': quickStats['tasks'] ?? '—'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // === QUICK STATS ROW ===
          isLoading
              ? const CircularProgressIndicator()
              : Row(
                  children: topCards.map((c) {
                    return Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 12),
                          child: Column(
                            children: [
                              Text(
                                c['title']!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                c['value']!,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
