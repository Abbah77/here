enum StoryMediaType { image, video, text }

class Story {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String mediaUrl; 
  final StoryMediaType mediaType;
  final String? caption;
  final String? color; 
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

  // Rule: Logic to decide if we show the + button or the story ring
  // If it's my story and I haven't uploaded anything "new" (unviewed), 
  // the UI will show the + icon routing.
  bool get shouldShowAddButton => isMyStory && !isViewed;

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

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      userImage: json['userImage']?.toString() ?? '',
      mediaUrl: json['mediaUrl']?.toString() ?? '',
      mediaType: _parseMediaType(json['mediaType']),
      caption: json['caption'],
      color: json['color'],
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      isViewed: json['isViewed'] ?? false,
      isMyStory: json['isMyStory'] ?? false,
    );
  }

  static StoryMediaType _parseMediaType(dynamic type) {
    final typeString = type.toString().toLowerCase();
    if (typeString.contains('video')) return StoryMediaType.video;
    if (typeString.contains('text')) return StoryMediaType.text;
    return StoryMediaType.image;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType.name, // Simplified enum string
      'caption': caption,
      'color': color,
      'timestamp': timestamp.toIso8601String(),
      'isViewed': isViewed,
      'isMyStory': isMyStory,
    };
  }
}
