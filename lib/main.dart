import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:here/providers/auth_provider.dart';
import 'package:here/providers/post_provider.dart';
import 'package:here/providers/notification_provider.dart';
import 'package:here/providers/chat_provider.dart';
import 'package:here/providers/friends_provider.dart';
import 'package:here/providers/story_provider.dart';
import 'package:here/auth_checker.dart';

void main() async {
  // Ensure Flutter is ready for platform calls
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase before the app starts
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase Initialization Error: $e");
    // Even if Firebase fails, we let the app run so AuthChecker 
    // can handle the error/timeout gracefully.
  }

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
        ChangeNotifierProvider(create: (_) => FriendsProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Here',
        // High-contrast clean Black/White theme
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black,
            primary: Colors.black,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: Colors.white,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black,
            primary: Colors.white,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: Colors.black,
        ),
        themeMode: ThemeMode.system,
        // Points to your updated AuthChecker with the 5s timeout
        home: const AuthChecker(),
      ),
    );
  }
}