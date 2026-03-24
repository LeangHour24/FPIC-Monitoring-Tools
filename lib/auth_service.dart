import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'service/auth_service.dart' as api;

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

/// App-wide authentication helper. This preserves the previous static
/// interface used across the app but delegates authentication actions
/// to the real backend implemented in `lib/service/auth_service.dart`.
class AuthService {
  static bool _isLoggedIn = false;
  static SharedPreferences? _prefs;

  /// Initialize persisted auth state. Call before runApp.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isLoggedIn = _prefs?.getString('jwt') != null;
  }

  static bool get isLoggedIn => _isLoggedIn;

  /// Login using the backend API. Returns the username on success.
  static Future<String> loginWithCredentials(
    String username,
    String password,
  ) async {
    if (username.isEmpty || password.isEmpty) {
      throw AuthException('Please provide username and password');
    }

    final svc = api.AuthService();
    final result = await svc.login(identifier: username, password: password);
    if (result['success'] == true) {
      _isLoggedIn = true;
      _prefs ??= await SharedPreferences.getInstance();
      try {
        await _prefs!.setBool('loggedIn_v1', true);
      } catch (_) {}
      return username;
    }
    throw AuthException(result['message']?.toString() ?? 'Login failed');
  }

  /// Logout locally and remove persisted tokens via backend helper.
  static Future<void> logout() async {
    final svc = api.AuthService();
    await svc.logout();
    _isLoggedIn = false;
    _prefs ??= await SharedPreferences.getInstance();
    try {
      await _prefs!.remove('loggedIn_v1');
    } catch (_) {}
  }
}
