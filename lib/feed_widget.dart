import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../widget/post_widget.dart';

class FeedWidget extends StatelessWidget {
  const FeedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        if (postProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!postProvider.hasPosts) {
          return const Center(child: Text('No posts yet.'));
        }

        return ListView.builder(
          itemCount: postProvider.posts.length,
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          itemBuilder: (context, index) {
            final post = postProvider.posts[index];
            return PostWidget(post: post);
          },
        );
      },
    );
  }
}