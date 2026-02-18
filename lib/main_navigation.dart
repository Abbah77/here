import 'package:flutter/material.dart';
import 'package:here/mainpage.dart'; // Ensure this file defines MainPage
import 'package:here/friends_page.dart';
import 'package:here/explore_page.dart';
import 'package:here/chat_list_page.dart';
import 'package:here/profile.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  
  // FIXED: Changed to GlobalKey<MainPageState> so the compiler recognizes .scrollToTop()
  // Note: Ensure _MainPageState in mainpage.dart is renamed to MainPageState (no underscore)
  final GlobalKey<MainPageState> _homeKey = GlobalKey<MainPageState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      MainPage(key: _homeKey), 
      const FriendsPage(),
      const ExplorePage(),
      const ChatListPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == 0 && _currentIndex == 0) {
            // This will now work without "method not found" errors
            _homeKey.currentState?.scrollToTop();
          } else {
            setState(() => _currentIndex = index);
          }
        },
        backgroundColor: colors.surface,
        elevation: 0,
        // Using withOpacity for Codemagic compatibility
        indicatorColor: colors.primary.withOpacity(0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Friends',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
