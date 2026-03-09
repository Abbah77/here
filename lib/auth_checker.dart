import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/auth_provider.dart';
import 'package:here/main_navigation.dart';
import 'package:here/auth_page.dart';

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasNavigated = false; // Prevent multiple navigations

  @override
  void initState() {
    super.initState();

    // Splash animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    // Initial auth check
    _checkAuthWithTimeout();
  }

  Future<void> _checkAuthWithTimeout() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted || _hasNavigated) return;
    
    final authProvider = context.read<AuthProvider>();

    int maxAttempts = 50;
    int currentAttempt = 0;

    while ((authProvider.status == AuthStatus.initial || authProvider.isLoading) && 
           currentAttempt < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 100));
      currentAttempt++;
    }

    _navigateBasedOnAuth(authProvider);
  }

  void _navigateBasedOnAuth(AuthProvider authProvider) {
    if (!mounted || _hasNavigated) return;
    
    _hasNavigated = true;
    
    Widget nextScreen = authProvider.isAuthenticated 
        ? const MainNavigation() 
        : const AuthPage();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth changes and navigate when authenticated
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // If we haven't navigated yet and user becomes authenticated, navigate
        if (!_hasNavigated && authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_hasNavigated) {
              _hasNavigated = true;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainNavigation()),
              );
            }
          });
        }
        
        final color = Theme.of(context).colorScheme.primary;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Center(
            child: FadeTransition(
              opacity: _controller,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'images/logo.png',
                      width: 120,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) => 
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
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
