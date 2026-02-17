import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/auth_provider.dart';
import 'package:here/providers/post_provider.dart';
import 'package:here/providers/notification_provider.dart';
import 'package:here/providers/chat_provider.dart';
import 'package:here/splash_page.dart';
import 'package:here/providers/friends_provider.dart';
import 'package:here/providers/story_provider.dart';


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
  ChangeNotifierProvider(create: (_) => FriendsProvider()), // Add this
  ChangeNotifierProvider(create: (_) => ChatProvider()),    // Add this
  ChangeNotifierProvider(create: (_) => StoryProvider()),   // Add this
],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Here',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black,
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black,
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const SplashPage(), // Always starts here
      ),
    );
  }
}