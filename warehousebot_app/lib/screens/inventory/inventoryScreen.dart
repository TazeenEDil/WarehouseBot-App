import 'package:flutter/material.dart';
import '../../../api_client.dart';
import '../../helperFunction/tokenStorage.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  bool loading = true;
  List products = [];
  List filteredProducts = [];
  final TextEditingController searchController = TextEditingController();
  
  int page = 1;
  int totalPages = 1;
  int totalProducts = 0;
  
  // Stats data - calculated from all products
  int totalItems = 0;
  int totalCategories = 0;
  int outOfStockItems = 0;

  Future<void> fetchAllProductsForStats() async {
    try {
      final token = await TokenStorage.getToken() ?? "";
      final res = await ApiClient.get("/api/products?limit=1000", token);
      
      if (mounted) {
        List allProducts = res["products"] ?? [];
        
        // Calculate stats
        Set<String> uniqueCategories = {};
        int outOfStock = 0;
        
        for (var item in allProducts) {
          String category = item["category"]?.toString() ?? "Unknown";
          uniqueCategories.add(category);
          
          int quantity = item["quantity"] ?? 0;
          if (quantity == 0) {
            outOfStock++;
          }
        }
        
        setState(() {
          totalItems = allProducts.length;
          totalCategories = uniqueCategories.length;
          outOfStockItems = outOfStock;
        });
      }
    } catch (e) {
      print("Error fetching all products: $e");
    }
  }

  Future<void> fetchProducts() async {
    try {
      final token = await TokenStorage.getToken() ?? "";
      final res = await ApiClient.get("/api/products?page=$page&limit=10", token);
      print("Response: $res");
      if (mounted) {
        setState(() {
          products = res["products"] ?? [];
          filteredProducts = products;
          totalPages = res["pages"] ?? 1;
          totalProducts = res["total"] ?? 0;
          loading = false;
        });
      }
    } catch (e) {
      print("Inventory fetch error: $e");
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllProductsForStats();
    fetchProducts();
    searchController.addListener(() {
      filterProducts(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterProducts(String query) {
    if (query.isEmpty) {
      setState(() => filteredProducts = products);
      return;
    }
    setState(() {
      filteredProducts = products.where((item) {
        final name = item["name"]?.toString().toLowerCase() ?? "";
        final category = item["category"]?.toString().toLowerCase() ?? "";
        return name.contains(query.toLowerCase()) || 
               category.contains(query.toLowerCase());
      }).toList();
    });
  }

  String getStockStatus(int quantity) {
    if (quantity == 0) return "Out of Stock";
    if (quantity < 10) return "Low Stock";
    return "In Stock";
  }

  Color getStockStatusColor(int quantity) {
    if (quantity == 0) return Colors.red;
    if (quantity < 10) return Colors.orange;
    return Colors.green;
  }

  void changePage(int newPage) {
    if (newPage >= 1 && newPage <= totalPages) {
      setState(() {
        page = newPage;
        loading = true;
      });
      fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    const SizedBox(height: 20),
                    _statsCards(),
                    const SizedBox(height: 20),
                    _searchBar(),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: const [
                          Text(
                            "Inventory List",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: filteredProducts.isEmpty
                            ? [
                                const Center(
                                  child: Text(
                                    "No products found.",
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ),
                              ]
                            : filteredProducts
                                .map((item) => _inventoryCard(item))
                                .toList(),
                      ),
                    ),
                    _pagination(),
                  ],
                ),
              ),
            ),
    );
  }

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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Text(
            "Inventory",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Your live product list",
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _statsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: _statCard(
              "Total Items",
              totalItems.toString(),
              Colors.blue.withOpacity(0.2),
              Colors.blueAccent,
              Icons.inventory_2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statCard(
              "Categories",
              totalCategories.toString(),
              Colors.purple.withOpacity(0.2),
              Colors.purpleAccent,
              Icons.category,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statCard(
              "Out of Stock",
              outOfStockItems.toString(),
              Colors.red.withOpacity(0.2),
              Colors.redAccent,
              Icons.warning_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, Color bgColor, Color accentColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 24),
          const SizedBox(height: 10),
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
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        controller: searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search items...",
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _inventoryCard(item) {
    final quantity = item["quantity"] ?? 0;
    final status = getStockStatus(quantity);
    final statusColor = getStockStatusColor(quantity);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item["name"] ?? "Unnamed",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusColor.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  "Category: ${item["category"] ?? "Unknown"}",
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Quantity: ",
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  quantity.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pagination() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Page $page of $totalPages",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: page > 1 ? () => changePage(page - 1) : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: Icon(
                  Icons.chevron_left,
                  color: page > 1 ? Colors.white : Colors.white24,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: page > 1 
                      ? const Color(0xFF2A2A2A) 
                      : const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 8),
              if (totalPages <= 5)
                ...List.generate(totalPages, (index) {
                  int pageNumber = index + 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      onTap: () => changePage(pageNumber),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: page == pageNumber
                              ? Colors.blueAccent
                              : const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(8),
                          gradient: page == pageNumber
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF6A5AE0),
                                    Color(0xFF3A76F0),
                                  ],
                                )
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          pageNumber.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: page == pageNumber
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(width: 8),
              IconButton(
                onPressed: page < totalPages ? () => changePage(page + 1) : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: Icon(
                  Icons.chevron_right,
                  color: page < totalPages ? Colors.white : Colors.white24,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: page < totalPages
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
