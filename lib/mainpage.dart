import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/post_provider.dart';
import 'package:here/widget/feed_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final ScrollController _feedScrollController = ScrollController();
  bool _isRefreshing = false;

  /// Called from MainNavigation when Home is tapped again
  Future<void> scrollToTopAndRefresh() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    // Animate scroll to top
    if (_feedScrollController.hasClients) {
      await _feedScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    // Refresh posts
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    await postProvider.loadPosts(refresh: true);

    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return FeedWidget(
      scrollController: _feedScrollController,
      isRefreshing: _isRefreshing,
    );
  }
}