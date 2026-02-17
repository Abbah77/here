import 'post_type.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String userProfileImage;
  final String content;
  final String? imageUrl;
  final List<String>? imageUrls;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final bool isBookmarked;
  final PostType type;
  final Map<String, dynamic>? metadata;

  const Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userProfileImage,
    required this.content,
    required this.createdAt,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.isLiked,
    required this.isBookmarked,
    required this.type,
    this.imageUrl,
    this.imageUrls,
    this.metadata,
  });

  /// Creates a copy of this Post with the given fields replaced by the new values.
  Post copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userProfileImage,
    String? content,
    String? imageUrl,
    List<String>? imageUrls,
    DateTime? createdAt,
    int? likes,
    int? comments,
    int? shares,
    bool? isLiked,
    bool? isBookmarked,
    PostType? type,
    Map<String, dynamic>? metadata,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      userProfileImage: json['userProfileImage'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      imageUrls: json['imageUrls'] != null 
          ? List<String>.from(json['imageUrls'] as List)
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      shares: json['shares'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      type: PostType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PostType.image,
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userProfileImage': userProfileImage,
      'content': content,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'isLiked': isLiked,
      'isBookmarked': isBookmarked,
      'type': type.name,
      'metadata': metadata,
    };
  }

  // Helpers
  bool get hasImage => imageUrl?.isNotEmpty ?? false;
  bool get hasMultipleImages => imageUrls?.isNotEmpty ?? false;
  
  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 365) return '${(difference.inDays / 365).floor()}y';
    if (difference.inDays > 30) return '${(difference.inDays / 30).floor()}mo';
    if (difference.inDays > 7) return '${(difference.inDays / 7).floor()}w';
    if (difference.inDays > 0) return '${difference.inDays}d';
    if (difference.inHours > 0) return '${difference.inHours}h';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m';
    return 'now';
  }

  /// A template for a new/empty post
  static Post get empty => Post(
    id: '',
    userId: '',
    userName: '',
    userProfileImage: '',
    content: '',
    createdAt: DateTime.now(),
    likes: 0,
    comments: 0,
    shares: 0,
    isLiked: false,
    isBookmarked: false,
    type: PostType.text,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Post && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}