// providers/status_full.dart
import 'package:flutter/material.dart';
import 'widget/repository.dart';

class StatusFull extends StatelessWidget {
  const StatusFull({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<WhatsappStory>>(
        future: Repository.getWhatsappStories(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return CustomStoryViewDelegate(
              stories: snapshot.data!,
            );
          }

          if (snapshot.hasError) {
             return const Center(child: Text("Error loading stories"));
          }

          return const Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          );
        },
      ),
    );
  }
}

class CustomStoryViewDelegate extends StatefulWidget {
  final List<WhatsappStory> stories;

  const CustomStoryViewDelegate({super.key, required this.stories});

  @override
  _CustomStoryViewDelegateState createState() => _CustomStoryViewDelegateState();
}

class _CustomStoryViewDelegateState extends State<CustomStoryViewDelegate> {
  int currentStoryIndex = 0;
  String when = "";

  @override
  void initState() {
    super.initState();
    when = widget.stories[0].when;
  }

  Widget _buildProfileView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(
              "https://post.healthline.com/wp-content/uploads/2019/02/How-to-Become-a-Better-Person-in-12-Steps_1200x628-facebook.jpg"),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Matt Redman",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                when,
                style: const TextStyle(color: Colors.white38),
              )
            ],
          ),
        )
      ],
    );
  }

  void _nextStory() {
    if (currentStoryIndex < widget.stories.length - 1) {
      setState(() {
        currentStoryIndex++;
        when = widget.stories[currentStoryIndex].when;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _previousStory() {
    if (currentStoryIndex > 0) {
      setState(() {
        currentStoryIndex--;
        when = widget.stories[currentStoryIndex].when;
      });
    }
  }

  Widget _buildStoryContent() {
    final story = widget.stories[currentStoryIndex];
    
    switch (story.mediaType) {
      case MediaType.image:
        return SizedBox.expand(
          child: Image.network(
            story.media,
            fit: BoxFit.cover,
          ),
        );
      case MediaType.video:
        return Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Video: ${story.caption}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      case MediaType.text:
        return Container(
          color: Color(int.parse(story.color.replaceAll('#', '0xFF'))),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                story.caption,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          GestureDetector(
            onTapDown: (details) {
              final screenWidth = MediaQuery.of(context).size.width;
              if (details.globalPosition.dx < screenWidth / 2) {
                _previousStory();
              } else {
                _nextStory();
              }
            },
            child: SizedBox.expand(
              child: _buildStoryContent(),
            ),
          ),
          // Top bar (Profile info)
          Container(
            padding: const EdgeInsets.only(top: 48, left: 16, right: 16),
            child: _buildProfileView(),
          ),
          // Progress indicators
          Positioned(
            top: 40,
            left: 8,
            right: 8,
            child: Row(
              children: List.generate(widget.stories.length, (index) {
                return Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      // FIXED: Used a valid color instance for withValues
                      color: index <= currentStoryIndex 
                          ? Colors.white 
                          : Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
