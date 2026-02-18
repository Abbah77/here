import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/post_provider.dart';
import 'package:here/providers/story_provider.dart';
import 'package:here/widget/feed_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  Future<void> scrollToTopAndRefresh() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }

    final postProvider =
        Provider.of<PostProvider>(context, listen: false);
    final storyProvider =
        Provider.of<StoryProvider>(context, listen: false);

    await Future.wait([
      postProvider.loadPosts(refresh: true),
      storyProvider.loadStories(),
    ]);

    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return FeedWidget(
      scrollController: _scrollController,
      isRefreshing: _isRefreshing,
    );
  }
}