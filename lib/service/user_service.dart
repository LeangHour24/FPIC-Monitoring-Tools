import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class UserService {
  static const String baseUrl = 'https://fpicbackend.analyticalx.org';
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await _authService.getToken();

    if (token == null) {
      print('No token found');
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      print('Get user failed: ${response.body}');
      return null;
    }
  }
}