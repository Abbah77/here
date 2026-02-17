import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/post_type.dart';
// Line 4: Unused import 'package:latlong2/latlong.dart' removed.

enum PostStatus { initial, loading, loaded, error, creating }

class PostProvider with ChangeNotifier {
  // Private variables
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
  bool get hasPosts => _posts.isNotEmpty;

  // Mock posts data
  final List<Map<String, dynamic>> _mockPostData = [
    {
      'id': '1',
      'userId': '1',
      'userName': 'Allan Paterson',
      'userProfileImage': 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
      'content': 'Just finished building the new profile page! 🚀',
      'type': 'text',
      'likes': 124,
      'comments': 23,
      'shares': 8,
      'createdAt': '2024-01-15T10:30:00Z',
    },
    {
      'id': '2',
      'userId': '1',
      'userName': 'Allan Paterson',
      'userProfileImage': 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
      'content': 'Beautiful sunset today! 🌅',
      'imageUrl': 'https://images.pexels.com/photos/2387873/pexels-photo-2387873.jpeg',
      'type': 'image',
      'likes': 89,
      'comments': 12,
      'shares': 3,
      'createdAt': '2024-01-14T18:45:00Z',
    },
    {
      'id': '3',
      'userId': '2',
      'userName': 'Emma Watson',
      'userProfileImage': 'https://randomuser.me/api/portraits/women/44.jpg',
      'content': 'Working on some new designs!',
      'imageUrls': [
        'https://images.pexels.com/photos/4264555/pexels-photo-4264555.jpeg',
        'https://images.pexels.com/photos/1779487/pexels-photo-1779487.jpeg',
        'https://images.pexels.com/photos/59992/crocus-flower-spring-purple-59992.jpeg',
      ],
      'type': 'multiImage',
      'likes': 156,
      'comments': 18,
      'shares': 5,
      'createdAt': '2024-01-14T14:20:00Z',
    },
    {
      'id': '4',
      'userId': '3',
      'userName': 'Tom Holland',
      'userProfileImage': 'https://randomuser.me/api/portraits/men/32.jpg',
      'content': 'Check out my new video! 🎬',
      'imageUrl': 'https://images.pexels.com/photos/34950/pexels-photo.jpg',
      'type': 'video',
      'likes': 234,
      'comments': 45,
      'shares': 12,
      'createdAt': '2024-01-13T09:15:00Z',
      'metadata': {'duration': '5:30'},
    },
    {
      'id': '5',
      'userId': '2',
      'userName': 'Emma Watson',
      'userProfileImage': 'https://randomuser.me/api/portraits/women/44.jpg',
      'content': 'Great article on Flutter development',
      'imageUrl': 'https://images.pexels.com/photos/4207548/pexels-photo-4207548.jpeg',
      'type': 'link',
      'likes': 45,
      'comments': 6,
      'shares': 1,
      'createdAt': '2024-01-12T16:40:00Z',
      'metadata': {
        'title': 'Flutter 3.16: What\'s New',
        'link': 'https://flutter.dev/blog',
      },
    },
    {
      'id': '6',
      'userId': '1',
      'userName': 'Allan Paterson',
      'userProfileImage': 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
      'content': 'Checking in at the coffee shop ☕️',
      'type': 'checkIn',
      'likes': 67,
      'comments': 8,
      'shares': 2,
      'createdAt': '2024-01-11T11:30:00Z',
      'metadata': {
        'locationName': 'Starbucks Downtown',
        'latitude': 37.7749,
        'longitude': -122.4194,
      },
    },
    {
      'id': '7',
      'userId': '3',
      'userName': 'Tom Holland',
      'userProfileImage': 'https://randomuser.me/api/portraits/men/32.jpg',
      'content': 'Now connected with Zendaya!',
      'type': 'connection',
      'likes': 324,
      'comments': 56,
      'shares': 23,
      'createdAt': '2024-01-10T20:15:00Z',
      'metadata': {
        'contactName': 'Zendaya',
        'contactTitle': 'Actor',
        'contactImage': 'https://randomuser.me/api/portraits/women/33.jpg',
        'mutualFriends': 15,
      },
    },
  ];

  // Load posts
  Future<void> loadPosts({bool refresh = false}) async {
    if (refresh) {
      _posts = [];
    }
    _updateStatus(PostStatus.loading);
    
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      _posts = _mockPostData.map((data) => _createPostFromMap(data)).toList();
      
      _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      _updateStatus(PostStatus.loaded);
    } catch (e) {
      _updateStatus(
        PostStatus.error,
        errorMessage: 'Failed to load posts. Please try again.',
      );
    }
  }

  // Create new post
  Future<bool> createPost({
    required String content,
    String? imageUrl,
    List<String>? imageUrls,
    required PostType type,
    Map<String, dynamic>? metadata,
    String? userId,
    String? userName,
    String? userProfileImage,
  }) async {
    if (content.isEmpty && type == PostType.text) {
      _updateStatus(
        PostStatus.error,
        errorMessage: 'Post content cannot be empty',
      );
      return false;
    }

    _updateStatus(PostStatus.creating);

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final newPost = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId ?? '1',
        userName: userName ?? 'Allan Paterson',
        userProfileImage: userProfileImage ?? 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
        content: content,
        imageUrl: imageUrl,
        imageUrls: imageUrls,
        createdAt: DateTime.now(), // FIXED: Now passing DateTime object
        likes: 0,
        comments: 0,
        shares: 0,
        isLiked: false,
        isBookmarked: false,
        type: type,
        metadata: metadata,
      );
      
      _posts.insert(0, newPost);
      _updateStatus(PostStatus.loaded);
      
      return true;
      
    } catch (e) {
      _updateStatus(
        PostStatus.error,
        errorMessage: 'Failed to create post',
      );
      return false;
    }
  }

  // Toggle like, Toggle bookmark, Add comment, Share post logic remains same...
  void toggleLike(String postId) {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) return;
    final post = _posts[postIndex];
    final newLikeState = !post.isLiked;
    _posts[postIndex] = post.copyWith(
      isLiked: newLikeState,
      likes: newLikeState ? post.likes + 1 : post.likes - 1,
    );
    notifyListeners();
  }

  void toggleBookmark(String postId) {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) return;
    _posts[postIndex] = _posts[postIndex].copyWith(isBookmarked: !_posts[postIndex].isBookmarked);
    notifyListeners();
  }

  void addComment(String postId, String comment) {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) return;
    _posts[postIndex] = _posts[postIndex].copyWith(comments: _posts[postIndex].comments + 1);
    notifyListeners();
  }

  void sharePost(String postId) {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) return;
    _posts[postIndex] = _posts[postIndex].copyWith(shares: _posts[postIndex].shares + 1);
    notifyListeners();
  }

  List<Post> getPostsByUser(String userId) => _posts.where((post) => post.userId == userId).toList();
  List<Post> getPostsByType(PostType type) => _posts.where((post) => post.type == type).toList();
  List<Post> getBookmarkedPosts() => _posts.where((post) => post.isBookmarked).toList();

  // Helper to create Post from map
  Post _createPostFromMap(Map<String, dynamic> data) {
    return Post(
      id: data['id'],
      userId: data['userId'],
      userName: data['userName'],
      userProfileImage: data['userProfileImage'],
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      imageUrls: data['imageUrls']?.cast<String>(),
      // FIXED: Line 192 - Parsing String from mock data to DateTime
      createdAt: DateTime.parse(data['createdAt']), 
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      shares: data['shares'] ?? 0,
      isLiked: data['isLiked'] ?? false,
      isBookmarked: data['isBookmarked'] ?? false,
      type: _getPostTypeFromString(data['type']),
      metadata: data['metadata'],
    );
  }

  PostType _getPostTypeFromString(String? type) {
    switch (type) {
      case 'image': return PostType.image;
      case 'multiImage': return PostType.multiImage;
      case 'video': return PostType.video;
      case 'link': return PostType.link;
      case 'checkIn': return PostType.checkIn;
      case 'connection': return PostType.connection;
      default: return PostType.text;
    }
  }

  void _updateStatus(PostStatus status, {String? errorMessage}) {
    _status = status;
    if (errorMessage != null) _errorMessage = errorMessage;
    notifyListeners();
  }
}
