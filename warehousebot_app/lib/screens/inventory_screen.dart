import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_indicator.dart';

class InventoryScreen extends StatefulWidget {
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  bool _loading = true;
  List<dynamic> _items = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() { _loading = true; _error = null; });

    try {
      final res = await ApiService.instance.get('/products?page=1&limit=50');

      if (res is Map && res['products'] != null) {
        setState(() {
          _items = List<dynamic>.from(res['products']);
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

  Widget _tile(Map<String, dynamic> item) {
    final name = item['productName'] ?? item['name'] ?? 'Unnamed';
    final qty = item['stock'] ?? item['qty'] ?? item['quantity'] ?? 0;
    final loc = item['location'] ?? item['position'] ?? 'N/A';

    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(name.isNotEmpty ? name[0] : '?')),
        title: Text(name),
        subtitle: Text('Location: $loc'),
        trailing: Text(qty.toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: _loading
          ? LoadingIndicator(message: "Loading inventory...")
          : _error != null
              ? Center(child: Text("Error: $_error"))
              : RefreshIndicator(
                  onRefresh: _loadInventory,
                  child: ListView.separated(
                    itemBuilder: (ctx, i) =>
                        _tile(Map<String, dynamic>.from(_items[i])),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: _items.length,
                  ),
                ),
    );
  }
}
