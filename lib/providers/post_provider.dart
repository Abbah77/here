// lib/providers/post_provider.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/post.dart';
import '../models/post_type.dart';

enum PostStatus { initial, loading, loaded, error, creating }

class PostProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<Post> _posts = [];
  PostStatus _status = PostStatus.initial;
  String? _errorMessage;

  // Getters
  List<Post> get posts => List.unmodifiable(_posts);
  PostStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == PostStatus.loading;
  bool get isCreating => _status == PostStatus.creating;
  bool get hasError => _status == PostStatus.error;

  // --- CORE LOGIC ---
  Future<void> loadPosts({bool refresh = false}) async {
    if (_status == PostStatus.loading) return;

    if (refresh) _posts = [];
    _status = PostStatus.loading;
    notifyListeners();

    try {
      final response = await _api.get('posts');
      
      _posts = (response['posts'] as List).map((p) => Post.fromJson(p)).toList();
      _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      _status = PostStatus.loaded;
    } catch (e) {
      _status = PostStatus.error;
      _errorMessage = 'Could not sync the feed. Please try again.';
      
      // Fallback to mock data
      _posts = _mockPostData.map((data) => Post.fromJson(data)).toList();
    } finally {
      notifyListeners();
    }
  }

  Future<void> toggleLike(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    final isCurrentlyLiked = post.isLiked;
    
    // Optimistic Update
    _posts[index] = post.copyWith(
      isLiked: !isCurrentlyLiked,
      likes: isCurrentlyLiked ? post.likes - 1 : post.likes + 1,
    );
    
    notifyListeners();
    
    // API call
    try {
      if (isCurrentlyLiked) {
        await _api.delete('posts/$postId/like');
      } else {
        await _api.post('posts/$postId/like', {});
      }
    } catch (e) {
      // Revert on error
      _posts[index] = post.copyWith(
        isLiked: isCurrentlyLiked,
        likes: post.likes,
      );
      notifyListeners();
    }
  }

  Future<bool> createPost({
    required String content,
    String? imageUrl,
    List<String>? imageUrls,
    required PostType type,
    Map<String, dynamic>? metadata,
  }) async {
    _status = PostStatus.creating;
    notifyListeners();

    try {
      final response = await _api.post('posts', {
        'content': content,
        'imageUrl': imageUrl,
        'imageUrls': imageUrls,
        'type': type.index,
        'metadata': metadata,
      });

      final newPost = Post.fromJson(response['post']);
      _posts.insert(0, newPost);
      _status = PostStatus.loaded;
      return true;
    } catch (e) {
      _status = PostStatus.error;
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> incrementCommentCount(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(comments: _posts[index].comments + 1);
      notifyListeners();
    }
  }

  Future<void> deletePost(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    _posts.removeAt(index);
    notifyListeners();

    try {
      await _api.delete('posts/$postId');
    } catch (e) {
      // Revert on error
      _posts.insert(index, post);
      notifyListeners();
    }
  }

  // --- MOCK DATA (Fallback) ---
  final List<Map<String, dynamic>> _mockPostData = [
    {
      'id': '1',
      'userId': 'current_user',
      'userName': 'Allan Paterson',
      'userProfileImage': 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
      'content': 'Just finished building the new social engine! 🚀',
      'type': 0, // text
      'likes': 124,
      'comments': 23,
      'shares': 8,
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
  ];
}