// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Change this URL when your backend changes
  static const String baseUrl = 'http://localhost:8000/api';
  
  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  String? _authToken;
  
  // Token management
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Map<String, String> get _headersWithAuth {
    final Map<String, String> authHeaders = Map.from(headers);
    if (_authToken != null) {
      authHeaders['Authorization'] = 'Bearer $_authToken';
    }
    return authHeaders;
  }

  // HTTP Methods
  Future<dynamic> get(String endpoint, {bool requiresAuth = true}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: requiresAuth ? _headersWithAuth : headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data, {bool requiresAuth = true}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: requiresAuth ? _headersWithAuth : headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data, {bool requiresAuth = true}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: requiresAuth ? _headersWithAuth : headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> data, {bool requiresAuth = true}) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$endpoint'),
        headers: requiresAuth ? _headersWithAuth : headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> delete(String endpoint, {bool requiresAuth = true}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: requiresAuth ? _headersWithAuth : headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }
}
