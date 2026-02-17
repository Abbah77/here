enum StoryMediaType { image, video, text }

class Story {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String mediaUrl;  // Image or video URL
  final StoryMediaType mediaType;
  final String? caption;
  final String? color;  // For text stories background color
  final DateTime timestamp;
  final bool isViewed;
  final bool isMyStory;

  const Story({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.mediaUrl,
    required this.mediaType,
    this.caption,
    this.color,
    required this.timestamp,
    this.isViewed = false,
    this.isMyStory = false,
  });

  // Copy with method for updating view status
  Story copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userImage,
    String? mediaUrl,
    StoryMediaType? mediaType,
    String? caption,
    String? color,
    DateTime? timestamp,
    bool? isViewed,
    bool? isMyStory,
  }) {
    return Story(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      caption: caption ?? this.caption,
      color: color ?? this.color,
      timestamp: timestamp ?? this.timestamp,
      isViewed: isViewed ?? this.isViewed,
      isMyStory: isMyStory ?? this.isMyStory,
    );
  }

  // JSON serialization
  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      userImage: json['userImage'] as String? ?? '',
      mediaUrl: json['mediaUrl'] as String? ?? '',
      mediaType: StoryMediaType.values.firstWhere(
        (e) => e.toString() == 'StoryMediaType.${json['mediaType']}',
        orElse: () => StoryMediaType.image,
      ),
      caption: json['caption'] as String?,
      color: json['color'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      isViewed: json['isViewed'] as bool? ?? false,
      isMyStory: json['isMyStory'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType.toString().split('.').last,
      'caption': caption,
      'color': color,
      'timestamp': timestamp.toIso8601String(),
      'isViewed': isViewed,
      'isMyStory': isMyStory,
    };
  }
}