
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ==========================================================
  // BASE URL
  // ==========================================================

  // Linux Desktop
  static const String baseUrl = 'http://127.0.0.1:8000';

  // ==========================================================
  // HEADERS
  // ==========================================================

  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('access_token');

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ==========================================================
  // GET
  // ==========================================================

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
    );

    return _handleResponse(response);
  }

  // ==========================================================
  // POST
  // ==========================================================

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
      body: body == null ? null : jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // ==========================================================
  // PATCH
  // ==========================================================

  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
      body: body == null ? null : jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // ==========================================================
  // DELETE
  // ==========================================================

  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
    );

    return _handleResponse(response);
  }

  // ==========================================================
  // RESPONSE HANDLER
  // ==========================================================

  dynamic _handleResponse(http.Response response) {
    dynamic data;

    try {
      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body);
      }
    } catch (_) {
      data = response.body;
    }

    // --------------------------------------------------------
    // SUCCESS
    // --------------------------------------------------------

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    // --------------------------------------------------------
    // ERROR
    // --------------------------------------------------------

    String message = 'API Error ${response.statusCode}';

    if (data is Map<String, dynamic>) {
      final detail = data['detail'];

      if (detail != null) {
        if (detail is String) {
          message = 'API Error ${response.statusCode}: $detail';
        } else {
          message =
              'API Error ${response.statusCode}: ${jsonEncode(detail)}';
        }
      }
    }

    throw Exception(message);
  }

  // ==========================================================
  // SAVE TOKEN
  // ==========================================================

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'access_token',
      token,
    );
  }

  // ==========================================================
  // GET TOKEN
  // ==========================================================

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('access_token');
  }

  // ==========================================================
  // CLEAR TOKEN
  // ==========================================================

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('access_token');
  }

  // ==========================================================
  // SAVE USER DATA
  // ==========================================================

  Future<void> saveUserData({
    required String userId,
    required String role,
    String? displayName,
    String? email,
    String? phone,
    String? zoneId,
    String? country,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_id', userId);
    await prefs.setString('role', role);

    if (displayName != null) {
      await prefs.setString('display_name', displayName);
    }

    if (email != null) {
      await prefs.setString('email', email);
    }

    if (phone != null) {
      await prefs.setString('phone', phone);
    }

    if (zoneId != null) {
      await prefs.setString('zone_id', zoneId);
    }

    if (country != null) {
      await prefs.setString('country', country);
    }
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('access_token');
    await prefs.remove('user_id');
    await prefs.remove('role');
    await prefs.remove('display_name');
    await prefs.remove('email');
    await prefs.remove('phone');
    await prefs.remove('zone_id');
    await prefs.remove('country');
  }
}


