import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // =========================
  // GET
  // =========================

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    return _handleResponse(response);
  }

  // =========================
  // POST
  // =========================

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: body != null ? jsonEncode(body) : null,
    );

    return _handleResponse(response);
  }

  // =========================
  // PATCH
  // =========================

  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: body != null ? jsonEncode(body) : null,
    );

    return _handleResponse(response);
  }

  // =========================
  // Handle Response
  // =========================

  dynamic _handleResponse(http.Response response) {
    final data = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw Exception(
      'API Error ${response.statusCode}: ${response.body}',
    );
  }
}
