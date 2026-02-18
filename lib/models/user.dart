enum UserStatus { online, offline, away, busy }

class User {
  final String id;
  final String name;
  final String email;
  final String profileImage;
  final String bio;
  final int followers;
  final int following;
  final int posts;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? lastActive;
  final UserStatus status;
  final String? phoneNumber;
  final String? website;
  final String? location;
  final List<String> interests;
  final Map<String, dynamic> socialLinks;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.bio,
    required this.followers,
    required this.following,
    required this.posts,
    this.isVerified = false,
    this.createdAt,
    this.lastActive,
    this.status = UserStatus.offline,
    this.phoneNumber,
    this.website,
    this.location,
    this.interests = const [],
    this.socialLinks = const {},
  });

  // Rule: High-performance copyWith for smooth state updates
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImage,
    String? bio,
    int? followers,
    int? following,
    int? posts,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? lastActive,
    UserStatus? status,
    String? phoneNumber,
    String? website,
    String? location,
    List<String>? interests,
    Map<String, dynamic>? socialLinks,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      posts: posts ?? this.posts,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      location: location ?? this.location,
      interests: interests ?? this.interests,
      socialLinks: socialLinks ?? this.socialLinks,
    );
  }

  // Rule: Safe JSON parsing with modern Enum support
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profileImage: json['profileImage']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      posts: json['posts'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      lastActive: json['lastActive'] != null ? DateTime.tryParse(json['lastActive']) : null,
      status: _parseStatus(json['status']),
      phoneNumber: json['phoneNumber'],
      website: json['website'],
      location: json['location'],
      interests: json['interests'] != null ? List<String>.from(json['interests']) : [],
      socialLinks: json['socialLinks'] ?? {},
    );
  }

  static UserStatus _parseStatus(dynamic status) {
    final s = status.toString().toLowerCase();
    return UserStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => UserStatus.offline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'bio': bio,
      'followers': followers,
      'following': following,
      'posts': posts,
      'isVerified': isVerified,
      'createdAt': createdAt?.toIso8601String(),
      'lastActive': lastActive?.toIso8601String(),
      'status': status.name,
      'phoneNumber': phoneNumber,
      'website': website,
      'location': location,
      'interests': interests,
      'socialLinks': socialLinks,
    };
  }

  // --- PREMIUM HELPERS ---

  // Concise Number Formatter (e.g., 1.2K, 5M)
  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  String get formattedFollowers => _formatCount(followers);
  String get formattedFollowing => _formatCount(following);
  String get formattedPosts => _formatCount(posts);

  // Short-hand Activity Text (matches Post timeAgo style)
  String get lastActiveText {
    if (status == UserStatus.online) return 'Online';
    if (lastActive == null) return 'Offline';
    
    final diff = DateTime.now().difference(lastActive!);
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()}w';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || name.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is User && id == other.id;

  @override
  int get hashCode => id.hashCode;

  static const User empty = User(
    id: '', name: '', email: '', profileImage: '', bio: '', followers: 0, following: 0, posts: 0,
  );
}