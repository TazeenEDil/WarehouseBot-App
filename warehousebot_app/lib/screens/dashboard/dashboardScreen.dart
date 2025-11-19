import 'package:flutter/material.dart';
import '../../helperFunction/tokenStorage.dart';
import '../../../api_client.dart';

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

  fetchData() async {
    setState(() => loading = true);

    try {
      final token = await TokenStorage.getToken() ?? "";

      final robotRes = await ApiClient.get("/api/fetch-robots", token);
      final orderRes = await ApiClient.get("/api/orders", token);

      if (mounted) {
        setState(() {
          robots = robotRes["robots"] ?? [];
          totalOrders = orderRes["orders"]?.length ?? 0;
          pendingOrders = (orderRes["orders"] ?? [])
              .where((o) => o["Status"] == "Pending")
              .length;
          loading = false;
        });
      }
    } catch (e) {
      print("Dashboard fetch error: $e");
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
      // REMOVED: bottomNavigationBar - BottomNav handles this!
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
            "Dashboard",
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Warehouse Operations Overview",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ------------------ QUICK STATS ------------------
  Widget _quickStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statCard("Total Orders", totalOrders.toString(), Colors.blueAccent),
        _statCard("Pending", pendingOrders.toString(), Colors.orangeAccent),
        _statCard("Robots", robots.length.toString(), Colors.greenAccent),
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

  // ------------------ ROBOTS LIST ------------------
  Widget _robotsList() {
    if (robots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Center(
          child: Text(
            "No active robots found.",
            style: TextStyle(color: Colors.white60),
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
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.18),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.smart_toy,
                size: 42,
                color: Colors.lightBlueAccent,
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r["RobotID"].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Status: ${r["Status"]}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    "Job ID: ${r["JobID"] ?? "None"}",
                    style: const TextStyle(color: Colors.white38),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}