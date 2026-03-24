import 'package:flutter/material.dart';
import 'package:test_app/kobo_form_screen.dart';
import 'auth_service.dart';
import 'login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AuthService.init().then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Khmer'),
      // Always show the login screen on startup per user request.
      home: const KoboFormScreen(),
    );
  }
}
