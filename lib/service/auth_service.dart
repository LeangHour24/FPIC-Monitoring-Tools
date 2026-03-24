import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://fpicbackend.analyticalx.org';

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/local'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'identifier': identifier,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt', data['jwt']);
      await prefs.setString('user', jsonEncode(data['user']));

      return {
        'success': true,
        'jwt': data['jwt'],
        'user': data['user'],
      };
    } else {
      return {
        'success': false,
        'message': data.toString(),
      };
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    await prefs.remove('user');
  }
}