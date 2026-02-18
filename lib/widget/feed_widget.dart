import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/post_provider.dart';
import 'package:here/widget/post_widget.dart';
import 'package:here/widget/story_widget.dart';

class FeedWidget extends StatelessWidget {
  final ScrollController scrollController;
  final bool isRefreshing;

  const FeedWidget({
    super.key,
    required this.scrollController,
    required this.isRefreshing,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: context.read<PostProvider>().posts.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // Story section with its own Consumer — only rebuilds when stories change
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: StoryWidget(),
          );
        }

        return Consumer<PostProvider>(
          builder: (context, postProvider, _) {
            final post = postProvider.posts[index - 1];
            return PostWidget(post: post);
          },
        );
      },
    );
  }
}