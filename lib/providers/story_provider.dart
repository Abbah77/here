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

  // Mock stories data
  final List<Map<String, dynamic>> _mockStoryData = [
    {
      'id': '1',
      'userId': '1',
      'userName': 'Allan Paterson',
      'userImage': 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
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
      'userId': '2',
      'userName': 'Emma Watson',
      'userImage': 'https://randomuser.me/api/portraits/women/44.jpg',
      'mediaUrl': 'https://images.pexels.com/photos/1779487/pexels-photo-1779487.jpeg',
      'mediaType': 'image',
      'caption': 'New dress! 👗',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2, minutes: 5)).toIso8601String(),
      'isViewed': false,
      'isMyStory': false,
    },
    {
      'id': '4',
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
    {
      'id': '5',
      'userId': '4',
      'userName': 'Zendaya',
      'userImage': 'https://randomuser.me/api/portraits/women/33.jpg',
      'mediaUrl': 'https://images.pexels.com/photos/34950/pexels-photo.jpg',
      'mediaType': 'image',
      'caption': 'Movie night! 🍿',
      'timestamp': DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
      'isViewed': true,
      'isMyStory': false,
    },
    {
      'id': '6',
      'userId': '5',
      'userName': 'Chris Evans',
      'userImage': 'https://randomuser.me/api/portraits/men/8.jpg',
      'mediaUrl': '',
      'mediaType': 'text',
      'caption': 'New project coming soon! 🔥',
      'color': '#4ECDC4',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'isViewed': true,
      'isMyStory': false,
    },
  ];

  // Load stories
  Future<void> loadStories() async {
    _status = StoryStatus.loading;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      _stories = _mockStoryData.map((data) {
        return Story(
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
      }).toList();
      
      // Sort by timestamp (newest first)
      _stories.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      _status = StoryStatus.loaded;
      notifyListeners();
      
    } catch (e) {
      _status = StoryStatus.error;
      _errorMessage = 'Failed to load stories';
      notifyListeners();
    }
  }

  // Get stories grouped by user
  List<MapEntry<String, List<Story>>> getStoriesGroupedByUser() {
    final Map<String, List<Story>> grouped = {};
    
    for (var story in _stories) {
      if (!grouped.containsKey(story.userId)) {
        grouped[story.userId] = [];
      }
      grouped[story.userId]!.add(story);
    }
    
    // Sort each user's stories by timestamp
    grouped.forEach((key, value) {
      value.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
    
    // Convert to list and sort by most recent story
    final entries = grouped.entries.toList();
    entries.sort((a, b) {
      final aLatest = a.value.first.timestamp;
      final bLatest = b.value.first.timestamp;
      return bLatest.compareTo(aLatest);
    });
    
    return entries;
  }

  // Get stories for a specific user
  List<Story> getStoriesByUser(String userId) {
    return _stories
        .where((story) => story.userId == userId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Check if user has unviewed stories
  bool hasUnviewedStories(String userId) {
    return _stories.any((story) => story.userId == userId && !story.isViewed);
  }

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
    
    if (updated) {
      notifyListeners();
    }
  }

  // Mark a single story as viewed
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
    // In a real app, you'd upload to server first
    try {
      final newStory = Story(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: '1', // Current user ID
        userName: 'Allan Paterson', // Current user name
        userImage: 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg', // Current user image
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
      return false;
    }
  }

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
}