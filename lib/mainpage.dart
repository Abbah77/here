import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';
import '../providers/post_provider.dart';
import '../widget/feed_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    // Load stories and posts once on page load
    Future.microtask(() {
      Provider.of<StoryProvider>(context, listen: false).loadStories();
      Provider.of<PostProvider>(context, listen: false).loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 1,
      ),
      body: const SafeArea(
        child: FeedWidget(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Create Post Page
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}