import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/story_provider.dart';
import 'package:here/models/story.dart';

class StoryViewer extends StatefulWidget {
  final String userId;
  final int initialStoryIndex;

  const StoryViewer({
    super.key,
    required this.userId,
    this.initialStoryIndex = 0,
  });

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> with TickerProviderStateMixin {
  late PageController _pageController;
  late List<Story> _userStories;
  int _currentIndex = 0;
  late AnimationController _progressController;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialStoryIndex);
    _currentIndex = widget.initialStoryIndex;
    
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();
    
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final storyProvider = Provider.of<StoryProvider>(context);
    _userStories = storyProvider.getStoriesByUser(widget.userId);
  }

  void _nextStory() {
    if (_currentIndex < _userStories.length - 1) {
      setState(() {
        _currentIndex++;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _progressController.reset();
        _progressController.forward();
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _progressController.reset();
        _progressController.forward();
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = _userStories[_currentIndex];
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 2) {
            _previousStory();
          } else {
            _nextStory();
          }
        },
        child: Stack(
          children: [
            // Story content
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _userStories.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _progressController.reset();
                  _progressController.forward();
                });
              },
              itemBuilder: (context, index) {
                final currentStory = _userStories[index];
                return _buildStoryContent(currentStory);
              },
            ),
            
            // Progress bars
            Positioned(
              top: 48,
              left: 16,
              right: 16,
              child: Row(
                children: List.generate(_userStories.length, (index) {
                  return Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: index == _currentIndex
                          ? AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, child) {
                                return LinearProgressIndicator(
                                  value: _progressController.value,
                                  // FIXED: Changed withValues to withOpacity
                                  backgroundColor: Colors.white.withOpacity(0.3),
                                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                                );
                              },
                            )
                          : Container(
                              // FIXED: Changed withValues to withOpacity
                              color: index < _currentIndex
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.3),
                            ),
                    ),
                  );
                }),
              ),
            ),
            
            // User info
            Positioned(
              top: 68,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(story.userImage),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _getTimeAgo(story.timestamp),
                          style: TextStyle(
                            // FIXED: Changed withValues to withOpacity
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryContent(Story story) {
    switch (story.mediaType) {
      case StoryMediaType.image:
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Image.network(
            story.mediaUrl,
            fit: BoxFit.cover,
          ),
        );
        
      case StoryMediaType.video:
        return Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_circle_filled,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  story.caption ?? 'Video Story',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        );
        
      case StoryMediaType.text:
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Color(
            int.parse(story.color?.replaceAll('#', '0xFF') ?? '0xFF6B6B'),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                story.caption ?? '',
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

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
