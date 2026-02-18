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
    required this.type,
    this.imageUrl,
    this.imageUrls,
    this.metadata,
  });

  // Rule: Cleaned copyWith for state management efficiency
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
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  // Rule: Simplified JSON parsing for real-time data sync
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      userProfileImage: json['userProfileImage']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      imageUrls: json['imageUrls'] != null ? List<String>.from(json['imageUrls']) : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() 
          : DateTime.now(),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      type: _parsePostType(json['type']),
      metadata: json['metadata'],
    );
  }

  static PostType _parsePostType(dynamic type) {
    final t = type.toString().toLowerCase();
    if (t.contains('multi')) return PostType.multiImage;
    if (t.contains('video')) return PostType.video;
    if (t.contains('image')) return PostType.image;
    return PostType.text;
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
      'type': type.name,
      'metadata': metadata,
    };
  }

  // Rule: Luxury short-hand time format (2h, 1d, etc.)
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()}w';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Post && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
