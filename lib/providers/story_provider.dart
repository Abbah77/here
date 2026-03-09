// lib/providers/story_provider.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/story.dart';

enum StoryStatus { initial, loading, loaded, error }

class StoryProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  
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
      final response = await _api.post('stories', {
        'mediaUrl': mediaUrl,
        'mediaType': mediaType.index,
        'caption': caption,
        'color': color,
      });

      final newStory = Story.fromJson(response['story']);
      _stories.insert(0, newStory);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteStory(String idOrUserId) async {
    final storyToDelete = _stories.firstWhere(
      (s) => s.id == idOrUserId || s.userId == idOrUserId,
      orElse: () => throw Exception('Story not found'),
    );
    
    _stories.removeWhere((s) => s.id == idOrUserId || s.userId == idOrUserId);
    notifyListeners();

    try {
      await _api.delete('stories/${storyToDelete.id}');
    } catch (e) {
      // Handle error silently
    }
  }

  // --- UI HELPERS ---
  List<MapEntry<String, List<Story>>> getStoriesGroupedByUser() {
    final Map<String, List<Story>> grouped = {};
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

  Future<void> markUserStoriesAsViewed(String userId) async {
    bool updated = false;
    _stories = _stories.map((s) {
      if (s.userId == userId && !s.isViewed) {
        updated = true;
        return s.copyWith(isViewed: true);
      }
      return s;
    }).toList();
    
    if (updated) {
      notifyListeners();
      try {
        await _api.post('stories/$userId/view', {});
      } catch (e) {
        // Handle error silently
      }
    }
  }

  Future<void> loadStories() async {
    if (_status == StoryStatus.loading) return;
    _status = StoryStatus.loading;
    notifyListeners();
    
    try {
      final response = await _api.get('stories');
      _stories = (response['stories'] as List).map((s) => Story.fromJson(s)).toList();
      _status = StoryStatus.loaded;
    } catch (e) {
      _status = StoryStatus.error;
      
      // Fallback to mock data
      _stories = _mockStoryData.map((data) => Story.fromJson(data)).toList();
      _status = StoryStatus.loaded;
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
      'mediaType': 0, // image
      'caption': '',
      'color': '',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
      'isViewed': false,
      'isMyStory': true,
    },
  ];
}