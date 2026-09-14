import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ============================================================
  // BASE URL
  // ============================================================

  // Linux Desktop
  static const String baseUrl = 'http://127.0.0.1:8000';

  // ============================================================
  // STORAGE KEYS
  // ============================================================

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _roleKey = 'user_role';
  static const String _displayNameKey = 'display_name';
  static const String _emailKey = 'user_email';
  static const String _phoneKey = 'user_phone';
  static const String _zoneIdKey = 'zone_id';
  static const String _countryKey = 'country';

  // ============================================================
  // HEADERS
  // ============================================================

  Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // GET
  // ============================================================

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _authHeaders(),
    );

    return _handleResponse(response);
  }

  // ============================================================
  // POST
  // ============================================================

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _authHeaders(),
      body: body == null ? null : jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // ============================================================
  // PUT
  // ============================================================

  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _authHeaders(),
      body: body == null ? null : jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // ============================================================
  // PATCH
  // ============================================================

  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _authHeaders(),
      body: body == null ? null : jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _authHeaders(),
    );

    return _handleResponse(response);
  }

  // ============================================================
  // SAVE TOKEN
  // ============================================================

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _tokenKey,
      token,
    );
  }

  // ============================================================
  // GET TOKEN
  // ============================================================

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_tokenKey);
  }

  // ============================================================
  // SAVE USER DATA
  // ============================================================

  Future<void> saveUserData({
    required String userId,
    required String role,
    required String displayName,
    required String email,
    String? phone,
    String? zoneId,
    String? country,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _userIdKey,
      userId,
    );

    await prefs.setString(
      _roleKey,
      role,
    );

    await prefs.setString(
      _displayNameKey,
      displayName,
    );

    await prefs.setString(
      _emailKey,
      email,
    );

    if (phone != null) {
      await prefs.setString(
        _phoneKey,
        phone,
      );
    }

    if (zoneId != null) {
      await prefs.setString(
        _zoneIdKey,
        zoneId,
      );
    }

    if (country != null) {
      await prefs.setString(
        _countryKey,
        country,
      );
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);

    await prefs.remove(_userIdKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_displayNameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_zoneIdKey);
    await prefs.remove(_countryKey);
  }

  // ============================================================
  // RESPONSE HANDLER
  // ============================================================

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    // ------------------------------------------------------------
    // SUCCESS
    // ------------------------------------------------------------

    if (statusCode >= 200 && statusCode < 300) {
      if (body.trim().isEmpty) {
        return null;
      }

      try {
        return jsonDecode(body);
      } catch (_) {
        return body;
      }
    }

    // ------------------------------------------------------------
    // ERROR
    // ------------------------------------------------------------

    String errorMessage = body;

    if (body.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(body);

        if (decoded is Map<String, dynamic>) {
          if (decoded['detail'] != null) {
            errorMessage = decoded['detail'].toString();
          } else if (decoded['message'] != null) {
            errorMessage = decoded['message'].toString();
          }
        }
      } catch (_) {
        // Keep original response body.
      }
    }

    throw Exception(
      'API Error $statusCode: $errorMessage',
    );
  }
}
