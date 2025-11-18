import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_indicator.dart';

class OrderDetailsScreen extends StatefulWidget {
  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _loading = true;
  List<dynamic> _orders = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() { _loading = true; _error = null; });

    try {
      final res = await ApiService.instance.get('/orders?page=1&limit=50');

      if (res is Map && res['orders'] != null) {
        setState(() {
          _orders = List<dynamic>.from(res['orders']);
        });
      } else {
        setState(() { _error = "Unexpected API response"; });
      }

    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Widget _orderCard(Map<String, dynamic> order) {
    final id = order['_id'] ?? order['id'] ?? "—";
    final status = order['status'] ?? 'pending';
    final customer = order['customerName'] ?? 'Unknown';
    final items = order['items'] ?? [];

    return Card(
      child: ExpansionTile(
        title: Text("Order $id"),
        subtitle: Text("$customer • ${status.toUpperCase()}"),
        children: [
          ...items.map<Widget>((item) {
            final name = item['name'] ?? item['productName'] ?? "Item";
            final qty = item['quantity'] ?? item['qty'] ?? 0;

            return ListTile(
              title: Text(name),
              trailing: Text("x$qty"),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: _loading
          ? LoadingIndicator(message: "Fetching orders...")
          : _error != null
              ? Center(child: Text("Error: $_error"))
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.separated(
                    itemBuilder: (ctx, i) =>
                        _orderCard(Map<String, dynamic>.from(_orders[i])),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: _orders.length,
                  ),
                ),
    );
  }
}
