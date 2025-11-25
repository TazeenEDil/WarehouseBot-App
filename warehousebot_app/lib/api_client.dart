import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = "http://localhost:4000";

  static Future<dynamic> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl$endpoint"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body);
      } else {
        print("API Error ${res.statusCode}: ${res.body}");
        throw Exception("Request failed: ${res.statusCode}");
      }
    } catch (e) {
      print("API POST Error: $e");
      rethrow;
    }
  }

  static Future<dynamic> get(String endpoint, String token) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl$endpoint"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body);
      } else {
        print("API Error ${res.statusCode}: ${res.body}");
        throw Exception("Request failed: ${res.statusCode}");
      }
    } catch (e) {
      print("API GET Error: $e");
      rethrow;
    }
  }

  static Future<dynamic> login(Map<String, dynamic> data) async {
    return post("/auth/login", data);
  }

  static Future<dynamic> register(Map<String, dynamic> data) async {
    return post("/auth/register", data);
  }

  // Orders / Products / Dashboard
  static Future<dynamic> fetchOrders({
    required String token,
    int page = 1,
    int limit = 10,
  }) async {
    return get("/api/orders?page=$page&limit=$limit", token);
  }

  static Future<dynamic> fetchProducts({
    required String token,
    int page = 1,
    int limit = 10,
  }) async {
    return get("/api/products?page=$page&limit=$limit", token);
  }

  static Future<dynamic> fetchDashboardDetails({required String token}) async {
    return get("/api/dashboard-info", token);
  }

  static Future<dynamic> fetchRobots({required String token}) async {
    return get("/api/fetch-robots?limit=2", token);
  }

  static Future<dynamic> getRobotLogs({required String token}) async {
    return get("/api/get-robot-logs?limit=10", token);
  }

  static Future<dynamic> getJobs({required String token}) async {
    return get("/api/get-jobs?limit=10", token);
  }
}