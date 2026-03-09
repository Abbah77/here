import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/auth_provider.dart';
import 'package:here/main_navigation.dart';
import 'package:here/auth_page.dart';

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Show splash screen while loading
    if (authProvider.status == AuthStatus.initial || 
        authProvider.status == AuthStatus.loading) {
      return const SplashScreen();
    }

    // Return the appropriate screen directly (NO NAVIGATION)
    if (authProvider.isAuthenticated) {
      return const MainNavigation();
    } else {
      return const AuthPage();
    }
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'images/logo.png',
              width: 120,
              height: 120,
              errorBuilder: (_, __, ___) => 
                Icon(Icons.location_on, size: 100, color: color),
            ),
            const SizedBox(height: 24),
            Text(
              'Here',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
