import 'package:flutter/material.dart';
import '../../../api_client.dart';
import '../../helperFunction/tokenStorage.dart';

// ---------------------------- BLINKING WIDGET ----------------------------
class BlinkingWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const BlinkingWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<BlinkingWidget> createState() => _BlinkingWidgetState();
}

class _BlinkingWidgetState extends State<BlinkingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.3).animate(_controller),
      child: widget.child,
    );
  }
}

// ---------------------------- PULSE WIDGET ----------------------------
class PulseWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const PulseWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.15).animate(_controller),
      child: widget.child,
    );
  }
}

// ========================================================================
//                           MAIN SCREEN
// ========================================================================
class RobotDetailsScreen extends StatefulWidget {
  final String robotId;

  const RobotDetailsScreen({super.key, required this.robotId});

  @override
  State<RobotDetailsScreen> createState() => _RobotDetailsScreenState();
}

class _RobotDetailsScreenState extends State<RobotDetailsScreen> {
  bool loading = true;
  Map robot = {};
  Map latestLog = {};

  Future<void> fetchDetails() async {
    try {
      final token = await TokenStorage.getToken() ?? "";

      final robotRes = await ApiClient.get("/api/fetch-robots", token);
      List robotsList = robotRes["data"] ?? [];

      robot = robotsList.firstWhere(
        (r) => r["robotId"].toString() == widget.robotId,
        orElse: () => {},
      );

      final logRes = await ApiClient.get(
        "/api/get-robot-logs?robotId=${widget.robotId}",
        token,
      );

      latestLog = logRes["data"] != null && logRes["data"].isNotEmpty
          ? logRes["data"][0]
          : {};

      if (mounted) setState(() => loading = false);
    } catch (e) {
      print("❌ Error: $e");
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  // ---------------------------- STATUS COLOR ----------------------------
  Color getStatusColor(String s) {
    switch (s.toLowerCase()) {
      case "busy":
      case "working":
        return Colors.greenAccent;
      case "idle":
        return Colors.blueAccent;
      case "charging":
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }

  // ---------------------------- STATUS GRADIENT ----------------------------
  Gradient getHeaderGradient(String status) {
    status = status.toLowerCase();

    if (status == "busy" || status == "working") {
      return const LinearGradient(
        colors: [Colors.greenAccent, Colors.green],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (status == "idle") {
      return const LinearGradient(
        colors: [Colors.blueAccent, Colors.blue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (status == "charging") {
      return const LinearGradient(
        colors: [Colors.orangeAccent, Colors.deepOrange],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: [Colors.grey, Colors.black26],
    );
  }

  // ---------------------------- BATTERY WIDGET ----------------------------
  Widget batteryIcon(int level) {
    if (level < 30) {
      return BlinkingWidget(
        child: const Icon(Icons.battery_alert, color: Colors.redAccent, size: 26),
      );
    } else if (level >= 80) {
      return BlinkingWidget(
        child: const Icon(Icons.battery_full, color: Colors.greenAccent, size: 26),
      );
    } else {
      return PulseWidget(
        child: const Icon(Icons.battery_5_bar, color: Colors.yellowAccent, size: 26),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = robot["status"]?.toString() ?? "unknown";
    final battery = robot["batteryLevel"] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(robot["name"] ?? "Robot Details"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _robotHeader(status, battery),
                  const SizedBox(height: 25),
                  _sectionTitle("Robot Information"),
                  _infoTile("Robot ID", widget.robotId),
                  _infoTile("Model", robot["model"] ?? "Unknown"),
                  _infoTile("Status", status,
                      icon: Icons.circle,
                      iconColor: getStatusColor(status)),
                  _infoTile("Battery", "$battery%", iconWidget: batteryIcon(battery)),
                  _infoTile("Current Job",
                      robot["currentJob"]?.toString() ?? "None",
                      icon: Icons.work),

                  const SizedBox(height: 30),
                  _sectionTitle("Live Position"),
                  _infoTile("X", latestLog["position"]?["x"]?.toString() ?? "N/A",
                      icon: Icons.location_on, iconColor: Colors.red),
                  _infoTile("Y", latestLog["position"]?["y"]?.toString() ?? "N/A",
                      icon: Icons.location_on, iconColor: Colors.red),
                  _infoTile("Last Updated",
                      latestLog["timestamp"]?.toString() ?? "Unknown",
                      icon: Icons.update),

                  const SizedBox(height: 30),
                  _sectionTitle("System Metrics"),
                  _infoTile("Error Rate",
                      robot["errorRate"]?.toString() ?? "N/A",
                      icon: Icons.warning_amber),
                ],
              ),
            ),
    );
  }

  // ========================================================================
  //                               ROBOT HEADER
  // ========================================================================
  Widget _robotHeader(String status, int battery) {
    final gradient = getHeaderGradient(status);

    Widget headerContent = Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: gradient,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.smart_toy, size: 45, color: Colors.white),
          ),
          const SizedBox(width: 16),

          // NAME + MODEL
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  robot["name"] ?? "Unknown Robot",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  robot["model"] ?? "",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // STATUS CIRCLE
          status.toLowerCase() == "busy"
              ? BlinkingWidget(
                  child: Icon(Icons.circle, color: Colors.greenAccent, size: 22),
                )
              : status.toLowerCase() == "charging"
                  ? PulseWidget(
                      child: Icon(Icons.circle,
                          color: Colors.orangeAccent, size: 22),
                    )
                  : Icon(Icons.circle,
                      color: Colors.blueAccent, size: 22)
        ],
      ),
    );

    if (status.toLowerCase() == "busy") {
      return BlinkingWidget(child: headerContent);
    }

    return status.toLowerCase() == "charging"
        ? PulseWidget(child: headerContent)
        : headerContent;
  }

  // ========================================================================
  //                            REUSABLE TILE
  // ========================================================================
  Widget _infoTile(String title, String value,
      {IconData? icon, Color? iconColor, Widget? iconWidget}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          if (iconWidget != null) iconWidget,

          if (icon != null)
            Icon(icon, color: iconColor ?? Colors.white70, size: 22),

          if (icon != null || iconWidget != null)
            const SizedBox(width: 12),

          Expanded(
            child: Text(title,
                style: const TextStyle(color: Colors.white70, fontSize: 15)),
          ),

          Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
