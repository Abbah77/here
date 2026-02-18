import 'package:flutter/material.dart';
import 'package:here/mainpage.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Keep a reference to MainPage
  late final MainPage _homePage = const MainPage();

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.add(_homePage);
    // Add other pages if you have them
    // _pages.add(ProfilePage());
    // _pages.add(SettingsPage());
  }

  void _onTap(int index) async {
    if (index == 0) {
      // Home icon tapped
      if (_currentIndex == 0) {
        // Already on home: refresh
        final state = _homePageKey.currentState;
        if (state != null) {
          await state.scrollToTopAndRefresh();
        }
      } else {
        setState(() => _currentIndex = 0);
      }
    } else {
      setState(() => _currentIndex = index);
    }
  }

  // Key to access MainPageState
  final GlobalKey<_MainPageState> _homePageKey = GlobalKey<_MainPageState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          MainPage(key: _homePageKey), // attach key here
          // Add other pages here
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}