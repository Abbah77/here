import 'package:flutter/material.dart';
import 'package:here/mainpage.dart';
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
  bool _isRefreshingHome = false; // For TikTok-style icon spinner

  // Create Home page with callback
  late final MainPage _homePage = MainPage(onHomeIconTap: _refreshHome);

  late final List<Widget> _pages = [
    _homePage,           // Home
    const FriendsPage(),  // Friends
    const ExplorePage(),  // Explore
    const ChatListPage(), // Chat
    const ProfilePage(),  // Profile
  ];

  Future<void> _refreshHome() async {
    if (_isRefreshingHome) return; // prevent double refresh

    setState(() => _isRefreshingHome = true);

    // Trigger MainPage's refresh logic
    if (_homePage.onHomeIconTap != null) {
      await _homePage.onHomeIconTap!();
    }

    setState(() => _isRefreshingHome = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (_currentIndex == 0 && index == 0) {
            // Already on Home → trigger TikTok-style refresh
            _refreshHome();
          } else {
            setState(() => _currentIndex = index);
          }
        },
        backgroundColor: colors.surface,
        elevation: 0,
        indicatorColor: colors.primary.withOpacity(0.1),
        destinations: [
          NavigationDestination(
            icon: _isRefreshingHome
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.home_outlined),
            selectedIcon: _isRefreshingHome
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Friends',
          ),
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          const NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}