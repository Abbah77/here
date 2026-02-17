import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:here/connections.dart';
import 'package:here/login.dart';
import 'package:here/mainpage.dart';
import 'package:here/meetup.dart';
import 'package:here/notification.dart';
import 'package:here/profile.dart';
import 'package:here/providers/auth_provider.dart';
import 'package:here/providers/post_provider.dart';
import 'package:here/providers/notification_provider.dart';
import 'package:here/providers/event_provider.dart'; // Ensure this is imported

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()), // Added for Meetup page
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Here',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
            primary: Colors.orange,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          navigationBarTheme: NavigationBarThemeData(
            // FIXED: Changed withValues(alpha: 0.2) to withOpacity(0.2)
            indicatorColor: Colors.orange.withOpacity(0.2), 
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Select specific values to minimize build triggers
    final authStatus = context.select<AuthProvider, bool>((p) => p.isAuthenticated);
    final isLoading = context.select<AuthProvider, bool>((p) => p.isLoading);

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );
    }
    
    return authStatus ? const MyNavigationBar() : const LoginPage();
  }
}

class MyNavigationBar extends StatefulWidget {
  const MyNavigationBar({super.key});

  @override
  State<MyNavigationBar> createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  int _selectedIndex = 0;
  
  // Const pages to optimize IndexedStack rebuilds
  final List<Widget> _pages = const [
    MainPage(),
    Profile(),
    Connections(),
    Meetup(),
    NotificationPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        elevation: 8,
        backgroundColor: Colors.white,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Network',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Meetup',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }
}
