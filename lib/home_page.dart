// home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import your KoBo form screen file
import 'kobo_form_screen.dart';
import 'app_route.dart';
import 'auth_service.dart';
import 'login_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// Looker Studio dashboard URL to display on the Home screen
const String lookerStudioUrl =
    'https://lookerstudio.google.com/reporting/da4aeba7-d3c3-46df-9e2e-9afb88277fb1';

class _HomePageState extends State<HomePage> {
  late final WebViewController controller;
  double _pointerStartY = 0.0;
  bool _isRefreshing = false;
  bool _atTop = false;

  Future<void> _doRefresh() async {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
    });
    try {
      await controller.reload();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color.fromARGB(0, 255, 255, 255))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse(lookerStudioUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 83, 147),
        elevation: 4,
        centerTitle: true,
        toolbarHeight: 96,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 45.0),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Image(
                image: AssetImage('assets/fpic_monitoring_tools_v3.png'),
                height: 42,
                width: 42,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.only(top: 50.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Aligns text to the left
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FPIC Monitoring Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              Text(
                'Real-time insights and data analytics', // Your new small text
                style: TextStyle(
                  color: Colors.white70, // Slightly faded for a cleaner look
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            color: Colors.white,
            onPressed: () async {
              final doLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Sign out'),
                    ),
                  ],
                ),
              );
              if (doLogout == true) {
                await AuthService.logout();
                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color.fromARGB(255, 4, 83, 147),
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      // WebView with header overlayed (header visually covers top of WebView)
      body: Stack(
        children: [
          // WebView fills the body
          Positioned.fill(
            child: Stack(
              children: [
                Listener(
                  onPointerDown: (ev) async {
                    _pointerStartY = ev.position.dy;
                    try {
                      final res = await controller.runJavaScriptReturningResult(
                        'window.scrollY',
                      );
                      double scrollY = 0.0;
                      if (res is num)
                        scrollY = res.toDouble();
                      else if (res is String)
                        scrollY = double.tryParse(res) ?? 0.0;
                      _atTop = scrollY <= 1.0;
                    } catch (_) {
                      _atTop = false;
                    }
                  },
                  onPointerMove: (ev) {
                    if (!_atTop || _isRefreshing) return;
                    final dy = ev.position.dy - _pointerStartY;
                    if (dy > 80) {
                      _doRefresh();
                    }
                  },
                  onPointerUp: (_) {
                    _pointerStartY = 0.0;
                  },
                  child: WebViewWidget(controller: controller),
                ),
                // Decorative header that overlays the WebView. Use IgnorePointer so touches pass to WebView.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 4, 83, 147),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_isRefreshing)
                  const Positioned(
                    top: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      // Container(
      //     width: double.infinity,
      //     color: Colors.white,
      //     padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         const Text(
      //           'FPIC Monitoring Tool for Communities',
      //           style: TextStyle(
      //             fontSize: 18,
      //             fontWeight: FontWeight.w700,
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      bottomNavigationBar: AppRouteBar(
        currentIndex: 0,
        onTap: (idx) {
          if (idx == 0) {
            // Dashboard (already here) — do nothing or pop to root
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (idx == 1) {
            // Evaluation -> open KoBo form
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KoboFormScreen()),
            );
          } else if (idx == 2) {
            // Profile / Contact placeholder
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Profile tapped')));
          }
        },
        actions: [],
      ),
    );
  }
}
