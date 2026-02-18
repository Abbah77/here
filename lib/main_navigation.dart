import 'package:flutter/material.dart';
import 'package:here/mainpage.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isHomeRefreshing = false;
  late final MainPage _homePage = const MainPage();

  // Animation for smooth spinner transition
  late final AnimationController _iconController =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

  void _onTap(int index) async {
    if (index == 0) {
      // Home tapped
      if (_currentIndex == 0) {
        if (_isHomeRefreshing) return;

        setState(() => _isHomeRefreshing = true);
        _iconController.forward(); // Start spinner animation

        await _homePage.scrollToTopAndRefresh();

        _iconController.reverse(); // Stop spinner animation
        setState(() => _isHomeRefreshing = false);
      } else {
        setState(() => _currentIndex = 0);
      }
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homePage,
      const Center(child: Text('Search Page')),
      const Center(child: Text('Profile Page')),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: [
          BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: _isHomeRefreshing
                  ? SizedBox(
                      key: const ValueKey('spinner'),
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.home, key: ValueKey('icon')),
            ),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}