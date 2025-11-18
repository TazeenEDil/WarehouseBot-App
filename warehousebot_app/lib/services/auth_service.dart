import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/validators.dart';

class AuthService {
  static const String BASE_URL = "http://localhost:4000";

  /// Login user and save JWT token using TokenManager
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
    required String role,
  }) async {
    final Uri url = Uri.parse("$BASE_URL/auth/login");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save token using TokenManager from validators.dart
        if (data['token'] != null) {
          await TokenManager.saveToken(data['token']);
        }

        return {
          'success': true,
          'data': data,
        };
      } else {
        String message = 'Login failed';
        try {
          final error = jsonDecode(response.body);
          message = error['message'] ?? message;
        } catch (_) {}
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong: $e'};
    }
  }

  /// Logout user and delete token
  static Future<void> logout() async {
    await TokenManager.deleteToken();
  }

  /// Check if user is logged in
  static bool isLoggedIn() {
    final token = TokenManager.getToken();
    if (token == null) return false;

    // validate token format & expiry
    final tokenError = Validators.validateTokenFormat(token);
    if (tokenError != null) return false;

    if (TokenManager.isExpired()) return false;

    return true;
  }
}
