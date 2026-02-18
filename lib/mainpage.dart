import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/post_provider.dart';
import 'package:here/providers/story_provider.dart';
import 'package:here/widget/feed_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  /// Call this from MainNavigation when home is tapped
  Future<void> scrollToTopAndRefresh() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    // Animate scroll to top
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    // Refresh posts & stories in parallel
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final storyProvider = Provider.of<StoryProvider>(context, listen: false);

    await Future.wait([
      postProvider.loadPosts(refresh: true),
      storyProvider.loadStories(),
    ]);

    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Here'),
        centerTitle: true,
        leading: IconButton(
          icon: _isRefreshing
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: colors.onPrimary,
                    strokeWidth: 2.5,
                  ),
                )
              : const Icon(Icons.home),
          onPressed: scrollToTopAndRefresh,
        ),
      ),
      body: FeedWidget(
        scrollController: _scrollController,
        isRefreshing: _isRefreshing,
      ),
    );
  }
}