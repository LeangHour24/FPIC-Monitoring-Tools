import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login_screen.dart';
import 'home_page.dart';

/// Minimal, robust AppRouteBar showing Khmer on first line and English below.
class AppRouteBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const AppRouteBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    required List<IconButton> actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final isKhmer = locale.toLowerCase().startsWith('km');

    final khmerLabels = ['ផ្ទាំងព័ត៌មាន', 'ទម្រង់វាយតម្លៃ'];
    final engLabels = ['Dashboard', 'Evaluation'];

    // If not authenticated, display the first tab as a "Sign in" action.
    final dashKhmer = AuthService.isLoggedIn ? khmerLabels[0] : 'ផ្ទាំងព័ត៌មាន';
    final dashEng = AuthService.isLoggedIn ? engLabels[0] : 'Dashboard';

    final bg =
        backgroundColor ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    final activeColor = selectedItemColor ?? Color.fromARGB(255, 4, 83, 147);
    final inactiveColor = unselectedItemColor ?? Colors.black54;

    Widget itemColumn(IconData icon, String khmer, String eng, bool selected) {
      final color = selected ? activeColor : inactiveColor;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                khmer,
                style: TextStyle(
                  fontFamily: isKhmer ? 'Khmer' : 'battambang',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                eng,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Container(
      color: bg,
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (idx) {
            // Handle Dashboard centrally so per-page handlers can't bypass auth.
            if (idx == 0) {
              if (AuthService.isLoggedIn) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
                );
              } else {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
              return;
            }
            onTap(idx);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: activeColor,
          unselectedItemColor: inactiveColor,
          items: [
            BottomNavigationBarItem(
              icon: itemColumn(
                Icons.dashboard,
                dashKhmer,
                dashEng,
                currentIndex == 0,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: itemColumn(
                Icons.assignment,
                khmerLabels[1],
                engLabels[1],
                currentIndex == 1,
              ),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
