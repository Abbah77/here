import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/connections.dart';
import 'package:here/widget/post_widget.dart'; // Fixed: widget (singular)
import 'package:here/widget/story_widget.dart'; // Fixed: widget (singular)
import 'package:here/providers/post_provider.dart';
import 'package:here/providers/story_provider.dart'; 

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          // Show loading indicator only on initial load
          if (postProvider.isLoading && postProvider.posts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            );
          }

          // Show error state
          if (postProvider.hasError && postProvider.posts.isEmpty) {
            return _buildErrorState(context, postProvider);
          }

          // Show empty state
          if (!postProvider.hasPosts) {
            return _buildEmptyState(context);
          }

          // Main content with posts
          return RefreshIndicator(
            onRefresh: () async {
              // Refresh both posts and stories
              // Changed refreshPosts() to loadPosts(refresh: true)
              await Future.wait([
                postProvider.loadPosts(refresh: true),
                Provider.of<StoryProvider>(context, listen: false).loadStories(),
              ]);
            },
            color: Colors.orange,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: postProvider.posts.length + 1, // +1 for stories
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Stories at the top
                  return const Column(
                    children: [
                      SizedBox(height: 10),
                      StoryWidget(),
                      SizedBox(height: 5),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.0),
                        child: Divider(),
                      ),
                    ],
                  );
                }
                
                // Posts
                final post = postProvider.posts[index - 1];
                return Column(
                  children: [
                    PostWidget(post: post),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.0),
                      child: Divider(),
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Image.asset(
            'images/logo.png',
            height: 30,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 30,
                width: 30,
                color: Colors.orange,
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              );
            },
          ),
          const SizedBox(width: 10),
          Text(
            'Socio Network',
            style: GoogleFonts.lato(
              color: Colors.grey[700],
              fontSize: 16,
              letterSpacing: 1,
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
                builder: (context) => const Connections(),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.link,
              color: Colors.grey[700],
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, PostProvider postProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            postProvider.errorMessage ?? 'Failed to load posts',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // clearError was removed as loadPosts handles status updates
              postProvider.loadPosts(refresh: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.feed_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Posts Yet',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share something!',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Create post feature coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Create Post'),
          ),
        ],
      ),
    );
  }
}