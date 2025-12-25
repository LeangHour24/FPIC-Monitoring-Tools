import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  static const _kLoggedInKey = 'loggedIn_v1';
  static const _kCredentialsKey = 'credentials_v1';
  static bool _isLoggedIn = false;
  static SharedPreferences? _prefs;
  static final Map<String, String> _credentials = {};

  /// Initialize persisted auth state. Call before runApp.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isLoggedIn = _prefs?.getBool(_kLoggedInKey) ?? false;
    // Load persisted credentials (JSON map). If missing, create a default dev user.
    final credsJson = _prefs?.getString(_kCredentialsKey);
    if (credsJson != null) {
      try {
        final decoded = jsonDecode(credsJson) as Map<String, dynamic>;
        _credentials.clear();
        decoded.forEach((k, v) => _credentials[k] = v?.toString() ?? '');
      } catch (_) {
        _credentials.clear();
      }
    }
    if (_credentials.isEmpty) {
      // default developer credentials (seeded list)
      _credentials.addAll({
        'Admin': 'admin1234',
        'cord': 'C0rd@1',
        'supervisor': 'Sup3r!',
        'supervisor2': 'Sup3r2!',
        'coordinator': 'C0ord!',
        'coordinato2': 'C0ord2!',
        'manager': 'M@ng3r!',
        'manager2': 'M@ng2r!',
        'analyst': 'An@ly1!',
        'analyst2': 'An@ly2!',
        'officer': '0ff1c3!',
        'officer2': '0ff1c2!',
      });
      try {
        await _prefs?.setString(_kCredentialsKey, jsonEncode(_credentials));
      } catch (_) {}
    }
  }

  static bool get isLoggedIn => _isLoggedIn;

  /// Simple credential-based login helper.
  /// Accepts any non-empty username/password and returns the username.
  /// Replace with real backend call as needed.
  static Future<String> loginWithCredentials(
    String username,
    String password,
  ) async {
    // Simulate a short network delay for responsiveness during development
    await Future.delayed(const Duration(seconds: 1));
    if (username.isEmpty || password.isEmpty) {
      throw AuthException('Please provide username and password');
    }
    // Validate against the local credential store. Replace with backend in prod.
    final stored = _credentials[username];
    if (stored != null && password == stored) {
      _isLoggedIn = true;
      try {
        await _prefs?.setBool(_kLoggedInKey, true);
      } catch (_) {}
      return username;
    }
    throw AuthException('Invalid username or password');
  }

  /// Add a new username/password pair to the local credential store and persist it.
  /// Throws [AuthException] if inputs are invalid or username already exists.
  static Future<void> addCredential(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      throw AuthException('Username and password must not be empty');
    }
    if (_credentials.containsKey(username)) {
      throw AuthException('Username already exists');
    }
    _credentials[username] = password;
    try {
      await _prefs?.setString(_kCredentialsKey, jsonEncode(_credentials));
    } catch (_) {
      // best-effort persistence
    }
  }

  /// Remove a username from the local credential store.
  static Future<void> removeCredential(String username) async {
    if (_credentials.remove(username) != null) {
      try {
        await _prefs?.setString(_kCredentialsKey, jsonEncode(_credentials));
      } catch (_) {}
    }
  }

  /// Returns a list of registered usernames.
  static List<String> get registeredUsernames =>
      _credentials.keys.toList(growable: false);

  /// Clears persisted login state.
  static Future<void> logout() async {
    _isLoggedIn = false;
    try {
      await _prefs?.remove(_kLoggedInKey);
    } catch (_) {}
  }
}
