// providers/post_provider.dart
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/post_type.dart'; // Nickname "as pt" removed
import 'package:latlong2/latlong.dart';

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
  static final List<Post> _mockPosts = [
    Post(
      id: '1',
      userId: '1',
      userName: 'Sound Byte',
      userProfileImage: 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
      content: 'Sound Byte is now connected to Dina and 8 others.',
      imageUrl: 'https://images.pexels.com/photos/4207548/pexels-photo-4207548.jpeg',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 124,
      comments: 23,
      shares: 8,
      isLiked: false,
      isBookmarked: false,
      type: PostType.connection, // Removed pt.
      metadata: {
        'connectedWith': 'Dina',
        'othersCount': 8,
        'contactName': 'Dina Foster',
        'contactTitle': 'Technology Consultant at Dropbox',
        'contactPhone': '+91 - 9560419114',
        'contactEmail': 'phinstudio@gmail.com',
        'contactImage': 'https://www.readersdigest.ca/wp-content/uploads/2017/08/being-a-good-person.jpg',
      },
    ),
    
    Post(
      id: '2',
      userId: '2',
      userName: 'Sound Byte',
      userProfileImage: 'https://storage.googleapis.com/multibhashi-website/website-media/2017/12/person.jpg',
      content: '',
      imageUrls: [
        'https://images.pexels.com/photos/4264555/pexels-photo-4264555.jpeg',
        'https://images.pexels.com/photos/1779487/pexels-photo-1779487.jpeg',
        'https://images.pexels.com/photos/59992/crocus-flower-spring-purple-59992.jpeg',
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      likes: 89,
      comments: 12,
      shares: 3,
      isLiked: true,
      isBookmarked: false,
      type: PostType.multiImage, // Removed pt.
    ),
    
    Post(
      id: '3',
      userId: '3',
      userName: 'Sound Byte',
      userProfileImage: 'https://i.insider.com/5c9a115d8e436a63e42c2883?width=600&format=jpeg&auto=webp',
      content: 'Sound Byte has checked in with Dina and 8 others.',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      likes: 67,
      comments: 8,
      shares: 2,
      isLiked: false,
      isBookmarked: true,
      type: PostType.checkIn, // Removed pt.
      metadata: {
        'location': const LatLng(45.5231, -122.6765),
        'locationName': 'Portland, OR',
        'attendees': 5,
        'attendeeNames': ['Alan Mathew', 'Sarah', 'Mike'],
        'attendeeImages': [
          'https://i.insider.com/5c9a115d8e436a63e42c2883',
          'https://play-images-prod-cms.tech.tvnz.co.nz/api/v1/web/image/content/dam/images/entertainment/shows/p/person-of-interest/personofinterest_coverimg.png',
        ],
      },
    ),
    
    Post(
      id: '4',
      userId: '4',
      userName: 'Sound Byte',
      userProfileImage: 'https://ggsc.s3.amazonaws.com/images/made/images/uploads/Six_Ways_to_Speak_Up_Against_Bad_Behavior_350_235_s_c1.jpg',
      content: 'Here\'s Part 3 Of HTML Mini Series. Hope You all will enjoy',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      likes: 45,
      comments: 6,
      shares: 1,
      isLiked: false,
      isBookmarked: false,
      type: PostType.link, // Removed pt.
      metadata: {
        'title': 'HTML 5 Tip - Part 3',
        'category': 'Advice',
        'date': 'Oct 6 - 7:21',
        'link': 'https://example.com/html-tip-3',
      },
    ),
    
    Post(
      id: '5',
      userId: '5',
      userName: 'Sound Byte',
      userProfileImage: 'https://bloximages.newyork1.vip.townnews.com/roanoke.com/content/tncms/assets/v3/editorial/d/da/ddac1f83-ffae-5e84-a8e5-e71f8ff18119/5f3176da21b5c.image.jpg?crop=650%2C650%2C175%2C0&resize=1200%2C1200&order=crop%2Cresize',
      content: 'Was great meeting up with Anna Ferguson and Dave Bishop at the breakfast talk!',
      imageUrl: 'https://images.pexels.com/photos/2387873/pexels-photo-2387873.jpeg',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      likes: 156,
      comments: 18,
      shares: 5,
      isLiked: false,
      isBookmarked: false,
      type: PostType.image, // Removed pt.
    ),
    
    Post(
      id: '6',
      userId: '6',
      userName: 'Sound Byte',
      userProfileImage: 'https://www.westernunion.com/content/dam/wu/jm/responsive/send-money-in-person-from-jamaica-resp.png',
      content: 'Watch My New Video released on Nov 12th 2020. Do Subscribe & Like.',
      imageUrl: 'https://images.pexels.com/photos/34950/pexels-photo.jpg',
      createdAt: DateTime.now().subtract(const Duration(hours: 7)),
      likes: 234,
      comments: 45,
      shares: 12,
      isLiked: true,
      isBookmarked: true,
      type: PostType.video, // Removed pt.
      metadata: {
        'videoUrl': 'https://example.com/video.mp4',
        'duration': '5:30',
      },
    ),
  ];

  // Load posts
  Future<void> loadPosts({bool refresh = false}) async {
    if (refresh) {
      _posts = [];
    }
    _updateStatus(PostStatus.loading);
    try {
      await Future.delayed(const Duration(seconds: 1));
      _posts = List.from(_mockPosts);
      _updateStatus(PostStatus.loaded);
    } catch (e) {
      _updateStatus(
        PostStatus.error,
        errorMessage: _getFriendlyErrorMessage(e),
      );
    }
  }

  // Create new post
  Future<bool> createPost({
    required String content,
    String? imageUrl,
    List<String>? imageUrls,
    required PostType type, // Removed pt.
    Map<String, dynamic>? metadata,
    String? userId,
    String? userName,
    String? userProfileImage,
  }) async {
    if (content.isEmpty && type == PostType.text) { // Removed pt.
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
        userName: userName ?? 'Sound Byte',
        userProfileImage: userProfileImage ?? 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
        content: content,
        imageUrl: imageUrl,
        imageUrls: imageUrls,
        createdAt: DateTime.now(),
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

  // Toggle like
  bool toggleLike(String postId) {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) return false;
    
    final post = _posts[postIndex];
    final newLikeState = !post.isLiked;
    
    final updatedPost = post.copyWith(
      isLiked: newLikeState,
      likes: newLikeState ? post.likes + 1 : post.likes - 1,
    );
    
    _posts[postIndex] = updatedPost;
    notifyListeners();
    return true;
  }

  // Toggle bookmark
  bool toggleBookmark(String postId) {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) return false;
    
    final post = _posts[postIndex];
    final updatedPost = post.copyWith(
      isBookmarked: !post.isBookmarked,
    );
    
    _posts[postIndex] = updatedPost;
    notifyListeners();
    return true;
  }

  // Helper methods
  List<Post> getPostsByUser(String userId) => _posts.where((post) => post.userId == userId).toList();
  List<Post> getPostsByType(PostType type) => _posts.where((post) => post.type == type).toList(); // Removed pt.
  List<Post> getBookmarkedPosts() => _posts.where((post) => post.isBookmarked).toList();

  void _updateStatus(PostStatus status, {String? errorMessage}) {
    _status = status;
    if (errorMessage != null) _errorMessage = errorMessage;
    notifyListeners();
  }

  String _getFriendlyErrorMessage(Object error) {
    return 'Failed to load posts. Please try again.';
  }
}
