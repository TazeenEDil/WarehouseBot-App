import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../helperFunction/tokenStorage.dart';
import 'robotDetailAnalyticsScreen.dart'; 


class RobotAnalyticsScreen extends StatefulWidget {
  const RobotAnalyticsScreen({super.key});

  @override
  State<RobotAnalyticsScreen> createState() => _RobotAnalyticsScreenState();
}

class _RobotAnalyticsScreenState extends State<RobotAnalyticsScreen> {
  bool loading = true;
  List robots = [];

  // ------------ FETCH ROBOTS ----------------
  fetchRobots() async {
    setState(() => loading = true);
    try {
      final token = await TokenStorage.getToken() ?? "";

      final robotRes = await ApiClient.get("/api/fetch-robots", token);

      if (mounted) {
        setState(() {
          robots = robotRes["data"] ?? [];
          loading = false;
        });
        print("🤖 Robots fetched: ${robots.length}");
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

  // ============= UI BUILD =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    const SizedBox(height: 25),

                    robots.isEmpty
                        ? _emptyState()
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: robots.length,
                            itemBuilder: (context, index) {
                              return _robotCard(robots[index]);
                            },
                          ),
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
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Robot Analytics",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Select a robot to view details",
            style: TextStyle(color: Colors.white70, fontSize: 15),
          )
        ],
      ),
    );
  }

  // ------------------ ROBOT CARD ------------------
  Widget _robotCard(Map robot) {
    final status = robot["status"]?.toString() ?? "Unknown";
    final name = robot["name"]?.toString() ?? "Robot";
    final robotId = robot["robotId"]?.toString() ?? "N/A";
    final battery = robot["batteryLevel"] ?? 0;
    final model = robot["model"]?.toString() ?? "N/A";

    Color statusColor;
    String statusText;

    switch (status.toLowerCase()) {
      case "busy":
      case "working":
        statusColor = const Color(0xFF10B981);
        statusText = "BUSY";
        break;

      case "idle":
        statusColor = const Color(0xFF3B82F6);
        statusText = "IDLE";
        break;

      case "charging":
        statusColor = const Color(0xFFF59E0B);
        statusText = "CHARGING";
        break;

      default:
        statusColor = Colors.grey;
        statusText = "UNKNOWN";
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RobotDetailAnalyticsScreen(robot: robot),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              statusColor.withOpacity(0.15),
              statusColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: statusColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.2),
              blurRadius: 15,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Robot Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.smart_toy, color: statusColor, size: 28),
            ),

            const Spacer(),

            Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "ID: $robotId",
              style: const TextStyle(fontSize: 13, color: Colors.white54),
            ),

            const SizedBox(height: 12),

            // Status Badge
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
                    statusText,
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

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Text(
                "Check Analytics",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ------------------ EMPTY STATE ------------------
  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.smart_toy_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            const Text(
              "No robots available",
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
