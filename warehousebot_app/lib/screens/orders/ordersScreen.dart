import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../helperFunction/tokenStorage.dart';
import 'orderDetailsScreen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool loading = true;
  List orders = [];
  int totalOrders = 0;
  int pendingOrders = 0;
  int page = 1;
  int totalPages = 1;

  fetchOrders() async {
    setState(() => loading = true);

    try {
      final token = await TokenStorage.getToken() ?? "";
      final res = await ApiClient.get("/api/orders?page=$page&limit=10", token);

      if (mounted) {
        setState(() {
          orders = res["orders"] ?? [];
          totalOrders = res["totalOrders"] ?? 0;
          totalPages = res["totalPages"] ?? 1;
          
          // Count pending orders
          pendingOrders = orders.where((o) => o["status"] == "Pending").length;
          loading = false;
        });
      }
    } catch (e) {
      print("Orders fetch error: $e");
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            )
          : SafeArea(
              child: Column(
                children: [
                  _header(),
                  const SizedBox(height: 15),
                  _statsCards(),
                  const SizedBox(height: 15),
                  Expanded(child: _ordersList()),
                  _pagination(),
                ],
              ),
            ),
    );
  }

  // ------------------ HEADER ------------------
  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 10),
          Text(
            "Orders Overview",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Track and manage all warehouse orders",
            style: TextStyle(fontSize: 15, color: Colors.white70),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  // ------------------ STATS CARDS ------------------
  Widget _statsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _statCard("Pending", pendingOrders.toString(), Colors.orangeAccent, Icons.hourglass_bottom),
          const SizedBox(width: 10),
          _statCard("Total Orders", totalOrders.toString(), Colors.blueAccent, Icons.receipt_long),
        ],
      ),
    );
  }

  Widget _statCard(String title, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        color: color.withOpacity(0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      count,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------ ORDERS LIST ------------------
  Widget _ordersList() {
    if (orders.isEmpty) {
      return const Center(
        child: Text(
          "No orders found.",
          style: TextStyle(color: Colors.white60),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _orderCard(order);
      },
    );
  }

  Widget _orderCard(order) {
    String orderId = order["_id"]?.toString().substring(order["_id"].toString().length - 8).toUpperCase() ?? "N/A";
    String status = order["status"]?.toString() ?? "Unknown";
    int itemCount = (order["items"] as List?)?.length ?? 0;

    Color statusColor;
    switch (status.toLowerCase()) {
      case "completed":
        statusColor = Colors.greenAccent;
        break;
      case "pending":
        statusColor = Colors.orangeAccent;
        break;
      case "in transit":
        statusColor = Colors.blueAccent;
        break;
      default:
        statusColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.receipt,
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order #$orderId",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$itemCount item${itemCount != 1 ? 's' : ''}",
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            _statusChip(status, statusColor),
          ],
        ),
      ),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ PAGINATION ------------------
  Widget _pagination() {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Page $page of $totalPages",
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          Row(
            children: [
              IconButton(
                onPressed: page > 1
                    ? () {
                        setState(() => page--);
                        fetchOrders();
                      }
                    : null,
                icon: const Icon(Icons.chevron_left),
                color: page > 1 ? Colors.blueAccent : Colors.white30,
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: page < totalPages
                    ? () {
                        setState(() => page++);
                        fetchOrders();
                      }
                    : null,
                icon: const Icon(Icons.chevron_right),
                color: page < totalPages ? Colors.blueAccent : Colors.white30,
              ),
            ],
          ),
        ],
      ),
    );
  }
}