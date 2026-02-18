import 'package:flutter/material.dart';
import '../models/story.dart';

enum StoryStatus { initial, loading, loaded, error }

class StoryProvider with ChangeNotifier {
  List<Story> _stories = [];
  StoryStatus _status = StoryStatus.initial;
  String? _errorMessage;

  // Getters
  List<Story> get stories => List.unmodifiable(_stories);
  StoryStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == StoryStatus.loading;
  bool get hasError => _status == StoryStatus.error;
  bool get hasStories => _stories.isNotEmpty;

  // Load mock stories
  Future<void> loadStories() async {
    _setStatus(StoryStatus.loading);

    try {
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      _stories = _mockStoryData.map((data) => _mapToStory(data)).toList();

      // Sort newest first
      _stories.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      _setStatus(StoryStatus.loaded);
    } catch (_) {
      _setStatus(StoryStatus.error, errorMessage: 'Failed to load stories');
    }
  }

  // Group stories by user
  List<MapEntry<String, List<Story>>> getStoriesGroupedByUser() {
    final Map<String, List<Story>> grouped = {};

    for (var story in _stories) {
      grouped.putIfAbsent(story.userId, () => []).add(story);
    }

    // Sort each user's stories and by latest story
    grouped.forEach((key, value) => value.sort((a, b) => b.timestamp.compareTo(a.timestamp)));
    final entries = grouped.entries.toList();
    entries.sort((a, b) => b.value.first.timestamp.compareTo(a.value.first.timestamp));
    return entries;
  }

  // Stories by user
  List<Story> getStoriesByUser(String userId) =>
      _stories.where((s) => s.userId == userId).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  // Check if user has unviewed stories
  bool hasUnviewedStories(String userId) =>
      _stories.any((s) => s.userId == userId && !s.isViewed);

  // Mark all stories of a user as viewed
  void markUserStoriesAsViewed(String userId) {
    bool updated = false;

    _stories = _stories.map((story) {
      if (story.userId == userId && !story.isViewed) {
        updated = true;
        return story.copyWith(isViewed: true);
      }
      return story;
    }).toList();

    if (updated) notifyListeners();
  }

  // Mark single story as viewed
  void markStoryAsViewed(String storyId) {
    final index = _stories.indexWhere((s) => s.id == storyId);
    if (index != -1 && !_stories[index].isViewed) {
      _stories[index] = _stories[index].copyWith(isViewed: true);
      notifyListeners();
    }
  }

  // Add a new story
  Future<bool> addStory({
    required String mediaUrl,
    required StoryMediaType mediaType,
    String? caption,
    String? color,
  }) async {
    try {
      final newStory = Story(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: '1', // current user
        userName: 'Allan Paterson',
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
    } catch (_) {
      _errorMessage = 'Failed to add story';
      return false;
    }
  }

  // Helper: map mock data to Story
  Story _mapToStory(Map<String, dynamic> data) => Story(
        id: data['id'],
        userId: data['userId'],
        userName: data['userName'],
        userImage: data['userImage'],
        mediaUrl: data['mediaUrl'],
        mediaType: _getMediaType(data['mediaType']),
        caption: data['caption'],
        color: data['color'],
        timestamp: DateTime.parse(data['timestamp']),
        isViewed: data['isViewed'] ?? false,
        isMyStory: data['isMyStory'] ?? false,
      );

  StoryMediaType _getMediaType(String type) {
    switch (type) {
      case 'video':
        return StoryMediaType.video;
      case 'text':
        return StoryMediaType.text;
      default:
        return StoryMediaType.image;
    }
  }

  void _setStatus(StoryStatus status, {String? errorMessage}) {
    _status = status;
    if (errorMessage != null) _errorMessage = errorMessage;
    notifyListeners();
  }

  // Mock story data
  final List<Map<String, dynamic>> _mockStoryData = [
    {
      'id': '1',
      'userId': '1',
      'userName': 'Allan Paterson',
      'userImage':
          'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
      'mediaUrl': 'https://images.pexels.com/photos/2387873/pexels-photo-2387873.jpeg',
      'mediaType': 'image',
      'caption': 'Beautiful sunset! 🌅',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
      'isViewed': false,
      'isMyStory': true,
    },
    {
      'id': '2',
      'userId': '2',
      'userName': 'Emma Watson',
      'userImage': 'https://randomuser.me/api/portraits/women/44.jpg',
      'mediaUrl': 'https://images.pexels.com/photos/4264555/pexels-photo-4264555.jpeg',
      'mediaType': 'image',
      'caption': 'Coffee time! ☕️',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      'isViewed': false,
      'isMyStory': false,
    },
    {
      'id': '3',
      'userId': '3',
      'userName': 'Tom Holland',
      'userImage': 'https://randomuser.me/api/portraits/men/32.jpg',
      'mediaUrl': '',
      'mediaType': 'text',
      'caption': 'Having a great day! 🎬',
      'color': '#FF6B6B',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      'isViewed': true,
      'isMyStory': false,
    },
  ];
}