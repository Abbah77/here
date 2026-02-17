import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/story_provider.dart';
import 'package:here/widget/story_viewer.dart'; 

class StoryWidget extends StatelessWidget {
  const StoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StoryProvider>(
      builder: (context, storyProvider, child) {
        if (storyProvider.isLoading) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final groupedStories = storyProvider.getStoriesGroupedByUser();
        
        return Container(
          height: 120,
          color: Colors.white,
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
              children: [
                Container(
                  height: 71,
                  width: 71,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasUnviewed
                          ? Colors.yellow[600] ?? Colors.yellow
                          : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(userImage),
                      radius: 30,
                    ),
                  ),
                ),
                if (isMyStory)
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Material(
                      color: Colors.orange,
                      elevation: 10,
                      shape: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Icon(
                          Icons.add,
                          size: 18,
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
                color: Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.normal,
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
