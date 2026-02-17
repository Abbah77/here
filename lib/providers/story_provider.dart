import 'package:flutter/material.dart';
import '../models/story.dart';

enum StoryStatus { initial, loading, loaded, error }

class StoryProvider with ChangeNotifier {
  List<Story> _stories = [];
  StoryStatus _status = StoryStatus.initial;
  String? _errorMessage;

  List<Story> get stories => List.unmodifiable(_stories);
  StoryStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == StoryStatus.loading;
  bool get hasError => _status == StoryStatus.error;

  // Mock stories data
  static final List<Story> _mockStories = [
    Story(
      id: '1',
      userId: '1',
      userName: 'Sound Byte',
      userImage: 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
      mediaUrl: 'https://images.pexels.com/photos/4207548/pexels-photo-4207548.jpeg',
      mediaType: StoryMediaType.image,
      caption: 'Beautiful sunset!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isViewed: false,
      isMyStory: true,
    ),
    Story(
      id: '2',
      userId: '2',
      userName: 'Chris Pyne',
      userImage: 'https://thebodyisnotanapology.com/wp-content/uploads/2018/02/pexels-photo-459947.jpg',
      mediaUrl: 'https://images.pexels.com/photos/1779487/pexels-photo-1779487.jpeg',
      mediaType: StoryMediaType.image,
      caption: 'Morning coffee ☕',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isViewed: false,
    ),
    Story(
      id: '3',
      userId: '3',
      userName: 'Matt Redman',
      userImage: 'https://post.healthline.com/wp-content/uploads/2019/02/How-to-Become-a-Better-Person-in-12-Steps_1200x628-facebook.jpg',
      mediaUrl: 'https://images.pexels.com/photos/2387873/pexels-photo-2387873.jpeg',
      mediaType: StoryMediaType.image,
      caption: 'New project! 🚀',
      // FIXED: Added 'Duration' and parentheses here
      timestamp: DateTime.now().subtract(const Duration(hours: 3)), 
      isViewed: false,
    ),
    Story(
      id: '4',
      userId: '4',
      userName: 'Virat Kholi',
      userImage: 'https://resize.indiatvnews.com/en/resize/newbucket/1200_-/2019/11/virat-kohli-1574240907.jpg',
      mediaUrl: 'https://images.pexels.com/photos/34950/pexels-photo.jpg',
      mediaType: StoryMediaType.video,
      caption: 'Practice session 🏏',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isViewed: false,
    ),
    Story(
      id: '5',
      userId: '5',
      userName: 'Anna',
      userImage: 'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg',
      mediaUrl: '',
      mediaType: StoryMediaType.text,
      caption: 'Feeling grateful today 🙏',
      color: '#FF6B6B',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isViewed: false,
    ),
  ];

  // ... (rest of your methods remain the same)
  
  Future<void> loadStories() async {
    _updateStatus(StoryStatus.loading);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _stories = List.from(_mockStories);
      _updateStatus(StoryStatus.loaded);
    } catch (e) {
      _updateStatus(StoryStatus.error, errorMessage: 'Failed to load stories');
    }
  }

  void markStoryAsViewed(String storyId) {
    final index = _stories.indexWhere((s) => s.id == storyId);
    if (index != -1) {
      _stories[index] = _stories[index].copyWith(isViewed: true);
      notifyListeners();
    }
  }

  void markUserStoriesAsViewed(String userId) {
    for (int i = 0; i < _stories.length; i++) {
      if (_stories[i].userId == userId && !_stories[i].isViewed) {
        _stories[i] = _stories[i].copyWith(isViewed: true);
      }
    }
    notifyListeners();
  }

  List<Story> getStoriesByUser(String userId) {
    return _stories.where((s) => s.userId == userId).toList();
  }

  List<MapEntry<String, List<Story>>> getStoriesGroupedByUser() {
    final Map<String, List<Story>> grouped = {};
    for (var story in _stories) {
      grouped.putIfAbsent(story.userId, () => []).add(story);
    }
    return grouped.entries.toList();
  }

  bool hasUnviewedStories(String userId) {
    return _stories.any((s) => s.userId == userId && !s.isViewed);
  }

  Future<bool> addStory({
    required String mediaUrl,
    required StoryMediaType mediaType,
    String? caption,
    String? color,
  }) async {
    try {
      final newStory = Story(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: '1',
        userName: 'Sound Byte',
        userImage: 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        caption: caption,
        color: color,
        timestamp: DateTime.now(),
        isViewed: false,
        isMyStory: true,
      );
      
      _stories.insert(0, newStory);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add story';
      notifyListeners();
      return false;
    }
  }

  void _updateStatus(StoryStatus status, {String? errorMessage}) {
    _status = status;
    if (errorMessage != null) _errorMessage = errorMessage;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
