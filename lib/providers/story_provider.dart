import 'package:flutter/material.dart';
import 'package:here/models/story.dart';

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

  // --- BUSINESS LOGIC ---

  /// Rule: Returns stories grouped by user, ensuring 'Your Story' is always index 0.
  List<MapEntry<String, List<Story>>> getStoriesGroupedByUser() {
    final Map<String, List<Story>> grouped = {};

    for (var story in _stories) {
      grouped.putIfAbsent(story.userId, () => []).add(story);
    }

    // Sort individual user story stacks by time (newest first)
    for (var list in grouped.values) {
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    final entries = grouped.entries.toList();

    // Rule: Sort groups to prioritize current user, then by latest activity
    entries.sort((a, b) {
      final aFirst = a.value.first;
      final bFirst = b.value.first;
      
      if (aFirst.isMyStory) return -1;
      if (bFirst.isMyStory) return 1;
      
      return bFirst.timestamp.compareTo(aFirst.timestamp);
    });

    return entries;
  }

  Future<void> loadStories() async {
    if (_status == StoryStatus.loading) return;

    _status = StoryStatus.loading;
    notifyListeners();

    try {
      // Rule: Simulating network delay for a smooth 'Blur-Refresh' effect
      await Future.delayed(const Duration(milliseconds: 1200));

      // Using the refactored Model's factory for consistency
      _stories = _mockStoryData.map((data) => Story.fromJson(data)).toList();
      
      _status = StoryStatus.loaded;
    } catch (e) {
      _status = StoryStatus.error;
      _errorMessage = 'Failed to sync stories';
    } finally {
      notifyListeners();
    }
  }

  /// Rule: Used by the Story Viewer to display a single user's sequence
  List<Story> getStoriesByUser(String userId) {
    return _stories.where((story) => story.userId == userId).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp)); // Viewer plays oldest to newest
  }

  /// Rule: Triggers the Ring UI update (Color Gradient removal)
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

  bool hasUnviewedStories(String userId) {
    return _stories.any((story) => story.userId == userId && !story.isViewed);
  }

  // --- MOCK DATA ---
  // Ready to be replaced by a 'Firebase/Supabase' stream later
  final List<Map<String, dynamic>> _mockStoryData = [
    {
      'id': '101',
      'userId': 'current_user',
      'userName': 'Allan Paterson',
      'userImage': 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
      'mediaUrl': 'https://images.pexels.com/photos/2387873/pexels-photo-2387873.jpeg',
      'mediaType': 'image',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
      'isViewed': false,
      'isMyStory': true,
    },
    {
      'id': '102',
      'userId': 'friend_1',
      'userName': 'Emma Watson',
      'userImage': 'https://randomuser.me/api/portraits/women/44.jpg',
      'mediaUrl': 'https://images.pexels.com/photos/4264555/pexels-photo-4264555.jpeg',
      'mediaType': 'image',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      'isViewed': false,
      'isMyStory': false,
    },
    {
      'id': '103',
      'userId': 'friend_2',
      'userName': 'Tom Holland',
      'userImage': 'https://randomuser.me/api/portraits/men/32.jpg',
      'mediaUrl': '',
      'mediaType': 'text',
      'caption': 'Working on something big! 🎬',
      'color': '0xFFFF6B6B',
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      'isViewed': true,
      'isMyStory': false,
    },
    {
      'id': '104',
      'userId': 'friend_3',
      'userName': 'Zendaya',
      'userImage': 'https://randomuser.me/api/portraits/women/33.jpg',
      'mediaUrl': 'https://images.pexels.com/photos/34950/pexels-photo.jpg',
      'mediaType': 'image',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      'isViewed': false,
      'isMyStory': false,
    },
  ];
}
