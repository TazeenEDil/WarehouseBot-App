import 'dart:convert';
import 'package:http/http.dart' as http;

class RobotService {
  static const String baseUrl = "http://10.0.2.2:5000"; // Android emulator
  // If testing on real device: replace with PC IP e.g. "http://192.168.0.106:5000"

  static Future<List<dynamic>> fetchRobots(int limit) async {
    final url = Uri.parse("$baseUrl/robot/fetch/$limit");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body["data"];  // list of robots
    } else {
      throw Exception("Failed to load robots");
    }
  }
}
