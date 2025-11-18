import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/validators.dart';

class ApiException implements Exception {
  final String message;
  final int? code;
  ApiException(this.message, {this.code});
  @override
  String toString() => 'ApiException($code): $message';
}

/// Generic API service that returns decoded JSON (Map or List).
/// All requests automatically include the Bearer token if present.
class ApiService {
  ApiService._private();
  static final ApiService instance = ApiService._private();

  String get _base => Constants.apiBaseUrl;

  Map<String, String> _defaultHeaders({String? token}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final t = token ?? TokenManager.getToken();
    if (t != null && t.isNotEmpty) headers['Authorization'] = 'Bearer $t';
    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$_base$endpoint');
    final resp = await http.get(url, headers: _defaultHeaders());
    return _process(resp);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$_base$endpoint');
    final resp = await http.post(url, headers: _defaultHeaders(), body: jsonEncode(body));
    return _process(resp);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$_base$endpoint');
    final resp = await http.put(url, headers: _defaultHeaders(), body: jsonEncode(body));
    return _process(resp);
  }

  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('$_base$endpoint');
    final resp = await http.delete(url, headers: _defaultHeaders());
    return _process(resp);
  }

  dynamic _process(http.Response resp) {
    final code = resp.statusCode;
    if (code >= 200 && code < 300) {
      try {
        final decoded = jsonDecode(resp.body);
        return decoded;
      } catch (e) {
        // if server returns empty body, return empty map
        return {};
      }
    } else if (code == 401) {
      // unauthorized -> caller should handle by logging out
      throw ApiException('Unauthorized', code: code);
    } else if (code == 403) {
      throw ApiException('Forbidden', code: code);
    } else {
      // decode server message when possible
      try {
        final body = jsonDecode(resp.body);
        throw ApiException(body['message'] ?? 'Server error', code: code);
      } catch (_) {
        throw ApiException('Server error', code: code);
      }
    }
  }
}
