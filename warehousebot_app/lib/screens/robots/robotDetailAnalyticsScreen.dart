import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../helperFunction/tokenStorage.dart';

class RobotDetailAnalyticsScreen extends StatefulWidget {
  final Map robot;

  const RobotDetailAnalyticsScreen({super.key, required this.robot});

  @override
  State<RobotDetailAnalyticsScreen> createState() =>
      _RobotDetailAnalyticsScreenState();
}

class _RobotDetailAnalyticsScreenState
    extends State<RobotDetailAnalyticsScreen> {
  bool loading = true;
  List robotLogs = [];

  fetchRobotLogs() async {
    setState(() => loading = true);

    try {
      final token = await TokenStorage.getToken() ?? "";

      // Fetch robot logs - Updated endpoint to match your API
      final logsRes = await ApiClient.get("/api/get-robot-logs", token);

      if (mounted) {
        setState(() {
          // Filter logs for this specific robot using data array
          String robotId = widget.robot["robotId"]?.toString() ?? "";
          robotLogs = (logsRes["data"] ?? [])
              .where((log) => log["robotId"] == robotId)
              .toList();
          loading = false;
        });

        print("📋 Logs for ${widget.robot['name']}: ${robotLogs.length}");
      }
    } catch (e) {
      print("❌ Logs fetch error: $e");
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRobotLogs();
  }

  // Calculate stats from logs
  int get tasksCompleted => robotLogs
      .where((log) => 
          log["status"]?.toString().toLowerCase() == "free" ||
          (log["message"]?.toString().toLowerCase().contains("completed") ?? false))
      .length;

  int get errorCount => robotLogs
      .where((log) => log["status"]?.toString().toLowerCase() == "error")
      .length;

  double get errorRate {
    if (robotLogs.isEmpty) return 0;
    return (errorCount / robotLogs.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.robot["status"]?.toString() ?? "Unknown";
    final name = widget.robot["name"]?.toString() ?? "Robot";
    final robotId = widget.robot["robotId"]?.toString() ?? "N/A";
    final battery = widget.robot["batteryLevel"] ?? 0;
    final model = widget.robot["model"]?.toString() ?? "N/A";

    Color statusColor;
    switch (status.toLowerCase()) {
      case "busy":
      case "working":
        statusColor = const Color(0xFF10B981);
        break;
      case "idle":
      case "free":
        statusColor = const Color(0xFF3B82F6);
        break;
      case "charging":
        statusColor = const Color(0xFFF59E0B);
        break;
      default:
        statusColor = Colors.grey;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent))
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  await fetchRobotLogs();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Robot Info Header
                      _robotInfoHeader(statusColor),
                      const SizedBox(height: 25),

                      // Stats Cards
                      _sectionTitle("Pick n Place Status"),
                      const SizedBox(height: 15),
                      _statsSection(battery, statusColor),
                      const SizedBox(height: 25),

                      // Activity Overview
                      _activityOverview(),
                      const SizedBox(height: 25),

                      // Recent Logs
                      _sectionTitle("Recent Activity Logs"),
                      const SizedBox(height: 15),
                      _logsSection(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ------------------ ROBOT INFO HEADER ------------------
  Widget _robotInfoHeader(Color statusColor) {
    final status = widget.robot["status"]?.toString() ?? "Unknown";
    final robotId = widget.robot["robotId"]?.toString() ?? "N/A";
    final model = widget.robot["model"]?.toString() ?? "N/A";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.2),
            statusColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.smart_toy,
              color: statusColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  robotId,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  model,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ STATS SECTION ------------------
  Widget _statsSection(int battery, Color statusColor) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                "Battery Level",
                "$battery%",
                "Runtime: ${(battery / 12.5).toStringAsFixed(0)}h",
                const Color(0xFF10B981),
                Icons.battery_charging_full,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                "Error Rate",
                "${errorRate.toStringAsFixed(1)}%",
                errorCount > 0 ? "Last: 2h ago" : "No errors",
                const Color(0xFFEF4444),
                Icons.error_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _statCard(
          "Tasks Completed Today",
          tasksCompleted.toString(),
          "Avg time: 8 min",
          const Color(0xFF3B82F6),
          Icons.task_alt,
          isLarge: true,
        ),
      ],
    );
  }

  Widget _statCard(
    String label,
    String value,
    String subtitle,
    Color color,
    IconData icon, {
    bool isLarge = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: isLarge
          ? Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
    );
  }

  // ------------------ ACTIVITY OVERVIEW ------------------
  Widget _activityOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Activity Overview"),
        const SizedBox(height: 8),
        const Text(
          "Pick n Place Activity",
          style: TextStyle(fontSize: 13, color: Colors.white54),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Text(
              robotLogs.length.toString(),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "Today +15%",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF10B981),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Graph
        Container(
          height: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.white.withOpacity(0.05),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      const times = ['8AM', '12PM', '4PM', '8PM'];
                      if (value.toInt() >= 0 && value.toInt() < times.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            times[value.toInt()],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 10,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 3,
              minY: 0,
              maxY: 6,
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 3),
                    FlSpot(1, 1.5),
                    FlSpot(2, 4),
                    FlSpot(3, 3.5),
                  ],
                  isCurved: true,
                  color: const Color(0xFF3B82F6),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF3B82F6).withOpacity(0.3),
                        const Color(0xFF3B82F6).withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ------------------ LOGS SECTION ------------------
  Widget _logsSection() {
    if (robotLogs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: const Center(
          child: Text(
            "No activity logs available",
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: robotLogs.length > 10 ? 10 : robotLogs.length,
      itemBuilder: (context, i) {
        final log = robotLogs[i];
        final status = log["status"]?.toString() ?? "Unknown";
        final message = log["message"]?.toString() ?? "No message";
        final timestamp = log["timestamp"]?.toString() ?? "";

        return Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: status.toLowerCase() == "error"
                      ? const Color(0xFFEF4444)
                      : status.toLowerCase() == "free"
                          ? const Color(0xFF10B981)
                          : const Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Status: $status • $timestamp",
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
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

  // ------------------ SECTION TITLE ------------------
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}