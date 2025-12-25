import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:test_app/app_route.dart';
import 'package:test_app/kobo_form_screen.dart';
import 'auth_service.dart';
import 'home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;
  // Links for social/contact icons. Empty = not configured.
  final String phoneLink = '+85523883665';
  final String websiteLink = 'https://www.dpacam.org';
  final String facebookLink = 'https://web.facebook.com/CambodiaDPA';

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _attemptLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final usernameInput = _userController.text.trim();
    final passwordInput = _passController.text;

    // Require both fields — do not fall back to defaults in production.
    if (usernameInput.isEmpty || passwordInput.isEmpty) {
      setState(() {
        _error = 'Please enter both username and password.';
        _loading = false;
      });
      return;
    }

    final username = usernameInput;
    final password = passwordInput;

    try {
      await AuthService.loginWithCredentials(username, password);
      if (!mounted) return;
      // Navigate to dashboard (HomePage) and remove login from the stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } on AuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _error = 'Login failed: ${e.toString()}';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Color(0xFFF8F8EE)],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.08),
                Image.asset(
                  'assets/fpic_monitoring_tools_v3.png',
                  height: 84,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Welcome Back',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sign in to continue to the dashboard',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.05),

                // Card with form
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _userController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Username',
                            prefixIcon: const Icon(Icons.person_outline),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 45),
                        // Align(
                        //   alignment: Alignment.centerRight,
                        //   child: TextButton(
                        //     onPressed: () {
                        //       ScaffoldMessenger.of(context).showSnackBar(
                        //         const SnackBar(
                        //           content: Text('Forgot password flow'),
                        //         ),
                        //       );
                        //     },
                        //     child: const Text('Forgot password?'),
                        //   ),
                        // ),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            onPressed: _loading
                                ? null
                                : () {
                                    _attemptLogin();
                                  },
                            child: _loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Sign in'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: Colors.grey.shade300),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('or contact us'),
                            ),
                            Expanded(
                              child: Divider(color: Colors.grey.shade300),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _socialIconButton(
                              Icons.phone,
                              '',
                              phoneLink,
                              (v) {},
                              const Color(0xFF2E7D32), // green
                            ),
                            _socialIconButton(
                              Icons.language,
                              '',
                              websiteLink,
                              (v) {},
                              const Color(0xFF0288D1), // blue
                            ),
                            _socialIconButton(
                              Icons.facebook,
                              '',
                              facebookLink,
                              (v) {},
                              const Color(0xFF1877F2), // fb blue
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppRouteBar(
        currentIndex: 0,
        onTap: (idx) {
          if (idx == 0) {
            if (AuthService.isLoggedIn) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please sign in first')),
              );
            }
          } else if (idx == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KoboFormScreen()),
            );
          } else if (idx == 2) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Profile tapped')));
          }
        },
        actions: [],
      ),
    );
  }

  Widget _socialIconButton(
    IconData icon,
    String hint,
    String current,
    void Function(String) onSave,
    Color color,
  ) {
    return Column(
      children: [
        InkResponse(
          radius: 28,
          onTap: () async {
            if (current.isEmpty) {
              final v = await _promptForLink(hint, current);
              if (v != null && v.isNotEmpty) onSave(v);
            } else {
              final uri = Uri.tryParse(current);
              if (uri != null)
                launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          onLongPress: () async {
            final v = await _promptForLink(hint, current);
            if (v != null) onSave(v);
          },
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 24, color: color),
          ),
        ),
        const SizedBox(height: 6),
        Text(hint, style: TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Future<String?> _promptForLink(String title, String current) async {
    final controller = TextEditingController(text: current);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set link for $title'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://... or tel:+123...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
