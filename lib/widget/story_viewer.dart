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
    final colors = Theme.of(context).colorScheme;
    final story = _userStories[_currentIndex];
    
    return Scaffold(
      backgroundColor: colors.background,
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
                return _buildStoryContent(currentStory, colors);
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
                                  backgroundColor: colors.onSurface.withOpacity(0.3),
                                  valueColor: AlwaysStoppedAnimation<Color>(colors.onSurface),
                                );
                              },
                            )
                          : Container(
                              color: index < _currentIndex
                                  ? colors.onSurface
                                  : colors.onSurface.withOpacity(0.3),
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
                    backgroundColor: colors.surfaceContainerHighest,
                    onBackgroundImageError: (_, __) => Icon(
                      Icons.person,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.userName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                        Text(
                          _getTimeAgo(story.timestamp),
                          style: TextStyle(
                            color: colors.onSurface.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: colors.onSurface,
                    ),
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

  Widget _buildStoryContent(Story story, ColorScheme colors) {
    switch (story.mediaType) {
      case StoryMediaType.image:
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Image.network(
            story.mediaUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: colors.surfaceContainerHighest,
                child: Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 64,
                    color: colors.onSurface.withOpacity(0.5),
                  ),
                ),
              );
            },
          ),
        );
        
      case StoryMediaType.video:
        return Container(
          color: colors.surfaceContainerHighest,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_filled,
                  size: 64,
                  color: colors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  story.caption ?? 'Video Story',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
        
      case StoryMediaType.text:
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: story.color != null
              ? Color(int.parse(story.color!.replaceAll('#', '0xFF')))
              : colors.primary,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                story.caption ?? '',
                style: TextStyle(
                  color: colors.onPrimary,
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