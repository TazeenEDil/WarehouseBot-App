import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../api_client.dart';
import '../../helperFunction/tokenStorage.dart';

class RobotAnalyticsScreen extends StatefulWidget {
  const RobotAnalyticsScreen({super.key});

  @override
  State<RobotAnalyticsScreen> createState() => _RobotAnalyticsScreenState();
}

class _RobotAnalyticsScreenState extends State<RobotAnalyticsScreen> {
  bool loading = true;
  List robots = [];
  List robotLogs = [];

  fetchRobots() async {
    try {
      final token = await TokenStorage.getToken() ?? "";
      
      final robotRes = await ApiClient.get("/fetch-robots", token);
      final logsRes = await ApiClient.get("/get-robot-logs", token);

      if (mounted) {
        setState(() {
          robots = robotRes["robots"] ?? [];
          robotLogs = logsRes["logs"] ?? [];
          loading = false;
        });
      }
    } catch (e) {
      print("Robot analytics fetch error: $e");
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRobots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    const SizedBox(height: 20),
                    _quickStats(),
                    const SizedBox(height: 25),
                    _sectionTitle("Active Robots"),
                    const SizedBox(height: 10),
                    _robotDetailsList(),
                    const SizedBox(height: 25),
                    _sectionTitle("Recent Activity Logs"),
                    const SizedBox(height: 10),
                    _robotLogsList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A5AE0), Color(0xFF3A76F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Robot Analytics",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Monitor fleet performance",
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _quickStats() {
    int activeRobots = robots.where((r) => r["Status"] == "Active").length;
    int idleRobots = robots.where((r) => r["Status"] == "Idle").length;
    int chargingRobots = robots.where((r) => r["Status"] == "Charging").length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statCard("Active", activeRobots.toString(), Colors.greenAccent),
        _statCard("Idle", idleRobots.toString(), Colors.blueAccent),
        _statCard("Charging", chargingRobots.toString(), Colors.orangeAccent),
      ],
    );
  }

  Widget _statCard(String title, String count, Color glowColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.25),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _robotDetailsList() {
    if (robots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          "No robot data available.",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: robots.length,
      itemBuilder: (context, i) {
        final r = robots[i];
        Color statusColor = r["Status"] == "Active"
            ? Colors.greenAccent
            : r["Status"] == "Charging"
                ? Colors.orangeAccent
                : Colors.blueAccent;

        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    r["RobotID"] ?? "Unknown",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  _statusChip(r["Status"] ?? "Unknown", statusColor),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoChip(Icons.battery_charging_full, "Battery", "${r["BatteryLevel"] ?? "N/A"}%"),
                  _infoChip(Icons.work_outline, "Job", r["CurrentJobID"] ?? "None"),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _robotLogsList() {
    if (robotLogs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          "No recent logs available.",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: robotLogs.length > 10 ? 10 : robotLogs.length,
      itemBuilder: (context, i) {
        final log = robotLogs[i];
        return Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: log["Action"] == "Error" ? Colors.redAccent : Colors.blueAccent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${log["RobotID"]} - ${log["Action"]}",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      log["Timestamp"] ?? "",
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
        color: color.withOpacity(0.12),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(width: 6),
        Text(
          "$label: ",
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}