import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/notification.dart'; 
// FIXED: Changed 'widgets' to 'widget' to match your actual folder name
import 'package:here/widget/post_widget.dart'; 
import 'package:here/widget/story_widget.dart'; 
import 'package:here/providers/post_provider.dart';
import 'package:here/providers/story_provider.dart'; 

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Scaffold(
      // FIXED: background -> surface (compatibility fix)
      backgroundColor: colors.surface,
      appBar: _buildAppBar(context, colors),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          if (postProvider.isLoading && postProvider.posts.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              ),
            );
          }

          if (postProvider.hasError && postProvider.posts.isEmpty) {
            return _buildErrorState(context, colors, postProvider);
          }

          if (!postProvider.hasPosts) {
            return _buildEmptyState(context, colors);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                postProvider.loadPosts(refresh: true),
                Provider.of<StoryProvider>(context, listen: false).loadStories(),
              ]);
            },
            color: colors.primary,
            backgroundColor: colors.surface,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: postProvider.posts.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    children: [
                      const SizedBox(height: 10),
                      const StoryWidget(),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Divider(color: colors.outline),
                      ),
                    ],
                  );
                }
                
                final post = postProvider.posts[index - 1];
                return Column(
                  children: [
                    PostWidget(post: post),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Divider(color: colors.outline),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ColorScheme colors) {
    return AppBar(
      backgroundColor: colors.surface,
      elevation: 0,
      title: Row(
        children: [
          // Using a placeholder icon since images/logo.png often causes build errors if missing from pubspec
          Icon(Icons.bubble_chart, color: colors.primary, size: 30),
          const SizedBox(width: 10),
          Text(
            'Here',
            style: GoogleFonts.plusJakartaSans( // Changed to match your project font
              color: colors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                // FIXED: Constructor name must match the class in notification.dart
                builder: (context) => const NotificationPage(), 
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // FIXED: surfaceContainerHighest -> surfaceVariant for compatibility
              color: colors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: colors.onSurface,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, ColorScheme colors, PostProvider postProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: colors.error),
          const SizedBox(height: 16),
          Text('Failed to load posts', style: TextStyle(color: colors.onSurface)),
          TextButton(
            onPressed: () => postProvider.loadPosts(refresh: true),
            child: const Text('Retry'),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colors) {
    return const Center(child: Text('No Posts Yet'));
  }
}