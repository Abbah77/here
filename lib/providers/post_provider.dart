import 'package:flutter/material.dart';
import 'package:here/models/post.dart';
import 'package:here/models/post_type.dart';

enum PostStatus { initial, loading, loaded, error, creating }

class PostProvider with ChangeNotifier {
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
      // Simulate network latency for a premium feel
      await Future.delayed(const Duration(milliseconds: 1500));
      
      _posts = _mockPostData.map((data) => Post.fromJson(data)).toList();
      
      // Sort by latest first
      _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      _status = PostStatus.loaded;
    } catch (e) {
      _status = PostStatus.error;
      _errorMessage = 'Could not sync the feed. Please try again.';
    } finally {
      notifyListeners();
    }
  }

  void toggleLike(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    final isCurrentlyLiked = post.isLiked;
    
    // Rule: Optimistic Update for "Instant" UI response
    _posts[index] = post.copyWith(
      isLiked: !isCurrentlyLiked,
      likes: isCurrentlyLiked ? post.likes - 1 : post.likes + 1,
    );
    
    notifyListeners();
    
    // Note: In a real backend, you would fire the API call here 
    // and revert if the server fails.
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
      await Future.delayed(const Duration(seconds: 1));

      final newPost = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user',
        userName: 'Allan Paterson',
        userProfileImage: 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
        content: content,
        imageUrl: imageUrl,
        imageUrls: imageUrls,
        createdAt: DateTime.now(),
        likes: 0,
        comments: 0,
        shares: 0,
        isLiked: false,
        type: type,
        metadata: metadata,
      );

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

  void incrementCommentCount(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(comments: _posts[index].comments + 1);
      notifyListeners();
    }
  }

  // --- MOCK DATA ---
  final List<Map<String, dynamic>> _mockPostData = [
    {
      'id': '1',
      'userId': 'current_user',
      'userName': 'Allan Paterson',
      'userProfileImage': 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
      'content': 'Just finished building the new social engine! 🚀',
      'type': 'text',
      'likes': 124,
      'comments': 23,
      'shares': 8,
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
    {
      'id': '2',
      'userId': 'friend_1',
      'userName': 'Emma Watson',
      'userProfileImage': 'https://randomuser.me/api/portraits/women/44.jpg',
      'content': 'Working on some new designs for the community.',
      'imageUrls': [
        'https://images.pexels.com/photos/4264555/pexels-photo-4264555.jpeg',
        'https://images.pexels.com/photos/1779487/pexels-photo-1779487.jpeg',
      ],
      'type': 'multiImage',
      'likes': 156,
      'comments': 18,
      'shares': 5,
      'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
    },
    {
      'id': '3',
      'userId': 'friend_2',
      'userName': 'Tom Holland',
      'userProfileImage': 'https://randomuser.me/api/portraits/men/32.jpg',
      'content': 'Check out this view from set! 🎬',
      'imageUrl': 'https://images.pexels.com/photos/2387873/pexels-photo-2387873.jpeg',
      'type': 'image',
      'likes': 234,
      'comments': 45,
      'shares': 12,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
   {
      'id': '1',
      'userId': 'current_user',
      'userName': 'Allan Paterson',
      'userProfileImage': 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
      'content': 'Just finished building the new social engine! 🚀',
      'type': 'text',
      'likes': 124,
      'comments': 23,
      'shares': 8,
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
    {
      'id': '2',
      'userId': 'friend_1',
      'userName': 'Emma Watson',
      'userProfileImage': 'https://randomuser.me/api/portraits/women/44.jpg',
      'content': 'Working on some new designs for the community.',
      'imageUrls': [
        'https://images.pexels.com/photos/4264555/pexels-photo-4264555.jpeg',
        'https://images.pexels.com/photos/1779487/pexels-photo-1779487.jpeg',
      ],
      'type': 'multiImage',
      'likes': 156,
      'comments': 18,
      'shares': 5,
      'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
    },
    {
      'id': '3',
      'userId': 'friend_2',
      'userName': 'Tom Holland',
      'userProfileImage': 'https://randomuser.me/api/portraits/men/32.jpg',
      'content': 'Check out this view from set! 🎬',
      'imageUrl': 'https://images.pexels.com/photos/2387873/pexels-photo-2387873.jpeg',
      'type': 'image',
      'likes': 234,
      'comments': 45,
      'shares': 12,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
   {
      'id': '1',
      'userId': 'current_user',
      'userName': 'Allan Paterson',
      'userProfileImage': 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
      'content': 'Just finished building the new social engine! 🚀',
      'type': 'text',
      'likes': 124,
      'comments': 23,
      'shares': 8,
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
    {
      'id': '2',
      'userId': 'friend_1',
      'userName': 'Emma Watson',
      'userProfileImage': 'https://randomuser.me/api/portraits/women/44.jpg',
      'content': 'Working on some new designs for the community.',
      'imageUrls': [
        'https://images.pexels.com/photos/4264555/pexels-photo-4264555.jpeg',
        'https://images.pexels.com/photos/1779487/pexels-photo-1779487.jpeg',
      ],
      'type': 'multiImage',
      'likes': 156,
      'comments': 18,
      'shares': 5,
      'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
    },
    {
      'id': '3',
      'userId': 'friend_2',
      'userName': 'Tom Holland',
      'userProfileImage': 'https://randomuser.me/api/portraits/men/32.jpg',
      'content': 'Check out this view from set! 🎬',
      'imageUrl': 'https://images.pexels.com/photos/2387873/pexels-photo-2387873.jpeg',
      'type': 'image',
      'likes': 234,
      'comments': 45,
      'shares': 12,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
   {
      'id': '1',
      'userId': 'current_user',
      'userName': 'Allan Paterson',
      'userProfileImage': 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
      'content': 'Just finished building the new social engine! 🚀',
      'type': 'text',
      'likes': 124,
      'comments': 23,
      'shares': 8,
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
    {
      'id': '2',
      'userId': 'friend_1',
      'userName': 'Emma Watson',
      'userProfileImage': 'https://randomuser.me/api/portraits/women/44.jpg',
      'content': 'Working on some new designs for the community.',
      'imageUrls': [
        'https://images.pexels.com/photos/4264555/pexels-photo-4264555.jpeg',
        'https://images.pexels.com/photos/1779487/pexels-photo-1779487.jpeg',
      ],
      'type': 'multiImage',
      'likes': 156,
      'comments': 18,
      'shares': 5,
      'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
    },
    {
      'id': '3',
      'userId': 'friend_2',
      'userName': 'Tom Holland',
      'userProfileImage': 'https://randomuser.me/api/portraits/men/32.jpg',
      'content': 'Check out this view from set! 🎬',
      'imageUrl': 'https://images.pexels.com/photos/2387873/pexels-photo-2387873.jpeg',
      'type': 'image',
      'likes': 234,
      'comments': 45,
      'shares': 12,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
{
      'id': '1',
      'userId': 'current_user',
      'userName': 'Allan Paterson',
      'userProfileImage': 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
      'content': 'Just finished building the new social engine! 🚀',
      'type': 'text',
      'likes': 124,
      'comments': 23,
      'shares': 8,
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
    {
      'id': '2',
      'userId': 'friend_1',
      'userName': 'Emma Watson',
      'userProfileImage': 'https://randomuser.me/api/portraits/women/44.jpg',
      'content': 'Working on some new designs for the community.',
      'imageUrls': [
        'https://images.pexels.com/photos/4264555/pexels-photo-4264555.jpeg',
        'https://images.pexels.com/photos/1779487/pexels-photo-1779487.jpeg',
      ],
      'type': 'multiImage',
      'likes': 156,
      'comments': 18,
      'shares': 5,
      'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
    },
    {
      'id': '3',
      'userId': 'friend_2',
      'userName': 'Tom Holland',
      'userProfileImage': 'https://randomuser.me/api/portraits/men/32.jpg',
      'content': 'Check out this view from set! 🎬',
      'imageUrl': 'https://images.pexels.com/photos/2387873/pexels-photo-2387873.jpeg',
      'type': 'image',
      'likes': 234,
      'comments': 45,
      'shares': 12,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
{
      'id': '1',
      'userId': 'current_user',
      'userName': 'Allan Paterson',
      'userProfileImage': 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
      'content': 'Just finished building the new social engine! 🚀',
      'type': 'text',
      'likes': 124,
      'comments': 23,
      'shares': 8,
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
    {
      'id': '2',
      'userId': 'friend_1',
      'userName': 'Emma Watson',
      'userProfileImage': 'https://randomuser.me/api/portraits/women/44.jpg',
      'content': 'Working on some new designs for the community.',
      'imageUrls': [
        'https://images.pexels.com/photos/4264555/pexels-photo-4264555.jpeg',
        'https://images.pexels.com/photos/1779487/pexels-photo-1779487.jpeg',
      ],
      'type': 'multiImage',
      'likes': 156,
      'comments': 18,
      'shares': 5,
      'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
    },
    {
      'id': '3',
      'userId': 'friend_2',
      'userName': 'Tom Holland',
      'userProfileImage': 'https://randomuser.me/api/portraits/men/32.jpg',
      'content': 'Check out this view from set! 🎬',
      'imageUrl': 'https://images.pexels.com/photos/2387873/pexels-photo-2387873.jpeg',
      'type': 'image',
      'likes': 234,
      'comments': 45,
      'shares': 12,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
{
      'id': '1',
      'userId': 'current_user',
      'userName': 'Allan Paterson',
      'userProfileImage': 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
      'content': 'Just finished building the new social engine! 🚀',
      'type': 'text',
      'likes': 124,
      'comments': 23,
      'shares': 8,
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
    {
      'id': '2',
      'userId': 'friend_1',
      'userName': 'Emma Watson',
      'userProfileImage': 'https://randomuser.me/api/portraits/women/44.jpg',
      'content': 'Working on some new designs for the community.',
      'imageUrls': [
        'https://images.pexels.com/photos/4264555/pexels-photo-4264555.jpeg',
        'https://images.pexels.com/photos/1779487/pexels-photo-1779487.jpeg',
      ],
      'type': 'multiImage',
      'likes': 156,
      'comments': 18,
      'shares': 5,
      'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
    },
    {
      'id': '3',
      'userId': 'friend_2',
      'userName': 'Tom Holland',
      'userProfileImage': 'https://randomuser.me/api/portraits/men/32.jpg',
      'content': 'Check out this view from set! 🎬',
      'imageUrl': 'https://images.pexels.com/photos/2387873/pexels-photo-2387873.jpeg',
      'type': 'image',
      'likes': 234,
      'comments': 45,
      'shares': 12,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
{
      'id': '1',
      'userId': 'current_user',
      'userName': 'Allan Paterson',
      'userProfileImage': 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
      'content': 'Just finished building the new social engine! 🚀',
      'type': 'text',
      'likes': 124,
      'comments': 23,
      'shares': 8,
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
    {
      'id': '2',
      'userId': 'friend_1',
      'userName': 'Emma Watson',
      'userProfileImage': 'https://randomuser.me/api/portraits/women/44.jpg',
      'content': 'Working on some new designs for the community.',
      'imageUrls': [
        'https://images.pexels.com/photos/4264555/pexels-photo-4264555.jpeg',
        'https://images.pexels.com/photos/1779487/pexels-photo-1779487.jpeg',
      ],
      'type': 'multiImage',
      'likes': 156,
      'comments': 18,
      'shares': 5,
      'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
    },
    {
      'id': '3',
      'userId': 'friend_2',
      'userName': 'Tom Holland',
      'userProfileImage': 'https://randomuser.me/api/portraits/men/32.jpg',
      'content': 'Check out this view from set! 🎬',
      'imageUrl': 'https://images.pexels.com/photos/2387873/pexels-photo-2387873.jpeg',
      'type': 'image',
      'likes': 234,
      'comments': 45,
      'shares': 12,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
{
      'id': '1',
      'userId': 'current_user',
      'userName': 'Allan Paterson',
      'userProfileImage': 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
      'content': 'Just finished building the new social engine! 🚀',
      'type': 'text',
      'likes': 124,
      'comments': 23,
      'shares': 8,
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
    {
      'id': '2',
      'userId': 'friend_1',
      'userName': 'Emma Watson',
      'userProfileImage': 'https://randomuser.me/api/portraits/women/44.jpg',
      'content': 'Working on some new designs for the community.',
      'imageUrls': [
        'https://images.pexels.com/photos/4264555/pexels-photo-4264555.jpeg',
        'https://images.pexels.com/photos/1779487/pexels-photo-1779487.jpeg',
      ],
      'type': 'multiImage',
      'likes': 156,
      'comments': 18,
      'shares': 5,
      'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
    },
    {
      'id': '3',
      'userId': 'friend_2',
      'userName': 'Tom Holland',
      'userProfileImage': 'https://randomuser.me/api/portraits/men/32.jpg',
      'content': 'Check out this view from set! 🎬',
      'imageUrl': 'https://images.pexels.com/photos/2387873/pexels-photo-2387873.jpeg',
      'type': 'image',
      'likes': 234,
      'comments': 45,
      'shares': 12,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
{
      'id': '1',
      'userId': 'current_user',
      'userName': 'Allan Paterson',
      'userProfileImage': 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
      'content': 'Just finished building the new social engine! 🚀',
      'type': 'text',
      'likes': 124,
      'comments': 23,
      'shares': 8,
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
    {
      'id': '2',
      'userId': 'friend_1',
      'userName': 'Emma Watson',
      'userProfileImage': 'https://randomuser.me/api/portraits/women/44.jpg',
      'content': 'Working on some new designs for the community.',
      'imageUrls': [
        'https://images.pexels.com/photos/4264555/pexels-photo-4264555.jpeg',
        'https://images.pexels.com/photos/1779487/pexels-photo-1779487.jpeg',
      ],
      'type': 'multiImage',
      'likes': 156,
      'comments': 18,
      'shares': 5,
      'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
    },
    {
      'id': '3',
      'userId': 'friend_2',
      'userName': 'Tom Holland',
      'userProfileImage': 'https://randomuser.me/api/portraits/men/32.jpg',
      'content': 'Check out this view from set! 🎬',
      'imageUrl': 'https://images.pexels.com/photos/2387873/pexels-photo-2387873.jpeg',
      'type': 'image',
      'likes': 234,
      'comments': 45,
      'shares': 12,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
  ];
}