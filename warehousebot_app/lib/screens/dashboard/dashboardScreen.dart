import 'package:flutter/material.dart';
import '../../helperFunction/tokenStorage.dart';
import '../../../api_client.dart';
import '../robots/robotDetailsScreen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool loading = true;
  List robots = [];
  int totalOrders = 0;
  int pendingOrders = 0;
  int completedOrders = 0;
  int inTransitOrders = 0;

  fetchData() async {
    setState(() => loading = true);

    try {
      final token = await TokenStorage.getToken() ?? "";

      // Fetch robots - API returns {success, message, data: [...]}
      final robotRes = await ApiClient.get("/api/fetch-robots", token);
      
      // Fetch orders - API returns {totalOrders, orders: [...]}
      final orderRes = await ApiClient.get("/api/orders?limit=1000", token);

      if (mounted) {
        final allOrders = orderRes["orders"] ?? [];
        
        setState(() {
          // Extract robots from the "data" field
          robots = robotRes["data"] ?? [];
          totalOrders = orderRes["totalOrders"] ?? allOrders.length;
          
          // Count orders by status (lowercase)
          pendingOrders = allOrders.where((o) => o["status"]?.toString().toLowerCase() == "pending").length;
          completedOrders = allOrders.where((o) => o["status"]?.toString().toLowerCase() == "completed").length;
          inTransitOrders = allOrders.where((o) => o["status"]?.toString().toLowerCase() == "in transit").length;
          
          loading = false;
        });
        
        // Debug print
        print("📊 Dashboard Stats:");
        print("Total Orders: $totalOrders");
        print("Pending: $pendingOrders");
        print("Completed: $completedOrders");
        print("In Transit: $inTransitOrders");
        print("Active Robots: ${robots.length}");
      }
    } catch (e) {
      print("❌ Dashboard fetch error: $e");
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blueAccent,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    const SizedBox(height: 25),
                    _quickStats(),
                    const SizedBox(height: 30),
                    const Text(
                      "Active Robots",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _robotsList(),
                  ],
                ),
              ),
            ),
    );
  }

  // ------------------ HEADER ------------------
  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.blueAccent.withOpacity(0.35),
            Colors.deepPurpleAccent.withOpacity(0.25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.25),
            blurRadius: 25,
            spreadRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Live Operations",
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Real-time warehouse monitoring",
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // ------------------ QUICK STATS ------------------
  Widget _quickStats() {
    return Column(
      children: [
        Row(
          children: [
            _statCard(
              "Active Robots",
              robots.length.toString(),
              const Color(0xFF3B82F6), // Blue
              Icons.smart_toy,
            ),
            const SizedBox(width: 12),
            _statCard(
              "In Transit",
              inTransitOrders.toString(),
              const Color(0xFFA855F7), // Purple
              Icons.local_shipping,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _statCard(
              "Completed",
              completedOrders.toString(),
              const Color(0xFF10B981), // Green
              Icons.check_circle,
            ),
            const SizedBox(width: 12),
            _statCard(
              "Pending",
              pendingOrders.toString(),
              const Color(0xFFEF4444), // Red
              Icons.hourglass_bottom,
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String title, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 14),
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
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------ ROBOTS LIST ------------------
  // ------------------ ROBOTS LIST ------------------
Widget _robotsList() {
  if (robots.isEmpty) {
    return const Padding(
      padding: EdgeInsets.only(top: 20),
      child: Center(
        child: Text(
          "No active robots found.",
          style: TextStyle(color: Colors.white60, fontSize: 15),
        ),
      ),
    );
  }

  return ListView.builder(
    itemCount: robots.length,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemBuilder: (context, i) {
      final r = robots[i];
      String status = r["status"] ?? "Unknown";
      String name = r["name"] ?? "Unknown";
      String model = r["model"] ?? "N/A";
      String robotId = r["robotId"] ?? "N/A";
      int battery = r["batteryLevel"] ?? 0;
      String currentJob = r["currentJob"]?.toString() ?? "None";

      Color statusColor;
      switch (status.toLowerCase()) {
        case "busy":
        case "working":
          statusColor = const Color(0xFF10B981);
          break;
        case "idle":
          statusColor = const Color(0xFF3B82F6);
          break;
        default:
          statusColor = Colors.grey;
      }

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RobotDetailsScreen(robotId: robotId),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: statusColor.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.15),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.smart_toy,
                    size: 32, color: statusColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      model,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Row(
                          children: [
                            Icon(Icons.battery_full,
                                size: 14,
                                color: battery > 50
                                    ? Colors.greenAccent
                                    : battery > 20
                                        ? Colors.orangeAccent
                                        : Colors.redAccent),
                            const SizedBox(width: 4),
                            Text(
                              "$battery%",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    if (currentJob != "None") ...[
                      const SizedBox(height: 6),
                      Text(
                        "Job: $currentJob",
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
}