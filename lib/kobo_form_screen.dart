import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'app_route.dart';
import 'home_page.dart';
import 'auth_service.dart';
import 'login_screen.dart';

// The URL of your KoBoToolbox form
const String koboToolboxUrl = 'https://ee-eu.kobotoolbox.org/x/rdxCVVBo/';

class KoboFormScreen extends StatefulWidget {
  const KoboFormScreen({super.key});

  @override
  State<KoboFormScreen> createState() => _KoboFormScreenState();
}

class _KoboFormScreenState extends State<KoboFormScreen> {
  // 1. Initialize the WebViewController
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

    // 2. Configure the controller
    controller = WebViewController()
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      ) // Important for web functionality
      ..setBackgroundColor(const Color.fromARGB(0, 9, 25, 247))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Optional: You can show a loading indicator here
            debugPrint('WebView is loading (progress: $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) async {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
              Page loading error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
              ''');
          },
        ),
      )
      // 3. Load the initial URL
      ..loadRequest(Uri.parse(koboToolboxUrl));
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
                'FPIC Monitoring Tool',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 23,
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

          // Decorative header that overlays the WebView. Use IgnorePointer so touches pass to WebView.
        ],
      ),
      bottomNavigationBar: AppRouteBar(
        currentIndex: 1,
        onTap: (idx) {
          if (idx == 0) {
            if (AuthService.isLoggedIn) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          } else if (idx == 1) {
            // already on Kobo (Evaluation) screen
          } else if (idx == 2) {
            // Profile / Contact placeholder (mirror HomePage behavior)
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
