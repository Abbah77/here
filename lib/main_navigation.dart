import 'package:flutter/material.dart';
import 'package:here/mainpage.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final GlobalKey<MainPageState> _homePageKey =
      GlobalKey<MainPageState>();

  void _onTap(int index) async {
    if (index == 0) {
      if (_currentIndex == 0) {
        // Already on Home → refresh
        await _homePageKey.currentState?.scrollToTopAndRefresh();
      } else {
        setState(() => _currentIndex = 0);
      }
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          MainPage(key: _homePageKey),
          const Center(child: Text('Profile Page')),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}