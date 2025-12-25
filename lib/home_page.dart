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

      // Header + WebView with pull-to-refresh
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              try {
                await controller.reload();
              } catch (_) {}
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: WebViewWidget(controller: controller),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 55,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            // Use decoration to apply borderRadius
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 4, 83, 147),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20), // Adjust value as needed
                bottomRight: Radius.circular(20), // Adjust value as needed
              ), // Adjust the radius value as needed
            ),
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            // ),
            // child: Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     const Text(
            //       'FPIC Monitoring Tool for Communities',
            //       style: TextStyle(
            //         fontSize: 18,
            //         fontWeight: FontWeight.w700,
            //       ),
            //     ),
            //   ],
            // ),
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
