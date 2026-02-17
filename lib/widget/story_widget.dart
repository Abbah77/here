import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/story_provider.dart';
import 'package:here/widget/story_viewer.dart'; // Fixed: widgets (plural)

class StoryWidget extends StatelessWidget {
  const StoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Consumer<StoryProvider>(
      builder: (context, storyProvider, child) {
        if (storyProvider.isLoading) {
          return SizedBox(
            height: 120,
            child: Center(
              child: CircularProgressIndicator(
                color: colors.primary,
              ),
            ),
          );
        }

        final groupedStories = storyProvider.getStoriesGroupedByUser();
        
        return Container(
          height: 120,
          color: colors.surface, // Changed from Colors.white
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: groupedStories.length,
            itemBuilder: (context, index) {
              final entry = groupedStories[index];
              final userId = entry.key;
              final userStories = entry.value;
              final firstStory = userStories.first;
              final hasUnviewed = storyProvider.hasUnviewedStories(userId);
              
              return _buildStoryAvatar(
                context,
                colors: colors,
                userImage: firstStory.userImage,
                userName: firstStory.userName,
                isMyStory: firstStory.isMyStory,
                hasUnviewed: hasUnviewed,
                onTap: () {
                  storyProvider.markUserStoriesAsViewed(userId);
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoryViewer(
                        userId: userId,
                        initialStoryIndex: 0,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStoryAvatar(
    BuildContext context, {
    required ColorScheme colors,
    required String userImage,
    required String userName,
    required bool isMyStory,
    required bool hasUnviewed,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none, // Allow add button to overflow
              children: [
                // Story ring
                Container(
                  height: 71,
                  width: 71,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasUnviewed
                          ? colors.primary
                          : colors.outline,
                      width: hasUnviewed ? 3 : 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(userImage),
                      radius: 30,
                      onBackgroundImageError: (_, __) => Icon(
                        Icons.person,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ),
                
                // Add story button (for user's own story)
                if (isMyStory)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.surface,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              userName.split(' ').first,
              style: GoogleFonts.lato(
                color: colors.onSurface.withOpacity(0.8),
                fontSize: 12,
                fontWeight: hasUnviewed ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}