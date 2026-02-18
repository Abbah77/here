import 'package:flutter/material.dart';
import 'package:here/models/story.dart';

enum StoryStatus { initial, loading, loaded, error }

class StoryProvider with ChangeNotifier {
  List<Story> _stories = [];
  StoryStatus _status = StoryStatus.initial;
  String? _errorMessage;

  List<Story> get stories => List.unmodifiable(_stories);
  StoryStatus get status => _status;
  bool get isLoading => _status == StoryStatus.loading;

  // --- STORY MANAGEMENT ---

  Future<bool> addStory({
    required String mediaUrl,
    required StoryMediaType mediaType,
    required String caption,
    required String color,
  }) async {
    try {
      final newStory = Story(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user',
        userName: 'Allan Paterson', 
        userImage: 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        caption: caption,
        color: color,
        timestamp: DateTime.now(),
        isViewed: true, 
        isMyStory: true,
      );

      _stories.insert(0, newStory);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void deleteStory(String idOrUserId) {
    _stories.removeWhere((s) => s.id == idOrUserId || s.userId == idOrUserId);
    notifyListeners();
  }

  // --- UI HELPERS ---

  List<MapEntry<String, List<Story>>> getStoriesGroupedByUser() {
    final Map<String, List<Story>> grouped = {};
    // Only group friends here; 'current_user' is handled manually in the UI
    final friendsStories = _stories.where((s) => s.userId != 'current_user');

    for (var story in friendsStories) {
      grouped.putIfAbsent(story.userId, () => []).add(story);
    }

    for (var list in grouped.values) {
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    return grouped.entries.toList()
      ..sort((a, b) => b.value.first.timestamp.compareTo(a.value.first.timestamp));
  }

  List<Story> getStoriesByUser(String userId) {
    return _stories.where((s) => s.userId == userId).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  bool hasUnviewedStories(String userId) {
    return _stories.any((s) => s.userId == userId && !s.isViewed);
  }

  void markUserStoriesAsViewed(String userId) {
    bool updated = false;
    _stories = _stories.map((s) {
      if (s.userId == userId && !s.isViewed) {
        updated = true;
        return s.copyWith(isViewed: true);
      }
      return s;
    }).toList();
    if (updated) notifyListeners();
  }

  Future<void> loadStories() async {
    if (_status == StoryStatus.loading) return;
    _status = StoryStatus.loading;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 1200));
      _stories = _mockStoryData.map((data) => Story.fromJson(data)).toList();
      _status = StoryStatus.loaded;
    } catch (e) {
      _status = StoryStatus.error;
    } finally {
      notifyListeners();
    }
  }

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
  ];
}
