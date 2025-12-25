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
          onPageFinished: (String url) {
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

      // Header + WebView
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
