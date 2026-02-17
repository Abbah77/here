import 'package:flutter/material.dart';

enum FriendStatus { pending, accepted, blocked }
enum OnlineStatus { online, offline, away }

class Friend {
  final String id;
  final String name;
  final String username;
  final String profileImage;
  final OnlineStatus onlineStatus;
  final DateTime? lastActive;
  final int mutualFriends;
  final bool isCloseFriend;
  final bool isFavorite;
  final bool hasStory;
  final FriendStatus status;
  final List<String>? mutualFriendsList;
  final List<String>? mutualFriendsImages;

  Friend({
    required this.id,
    required this.name,
    required this.username,
    required this.profileImage,
    required this.onlineStatus,
    this.lastActive,
    required this.mutualFriends,
    required this.isCloseFriend,
    required this.isFavorite,
    required this.hasStory,
    required this.status,
    this.mutualFriendsList,
    this.mutualFriendsImages,
  });

  String get lastActiveText {
    if (onlineStatus == OnlineStatus.online) return 'Online';
    if (lastActive == null) return 'Offline';
    
    final now = DateTime.now();
    final difference = now.difference(lastActive!);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return lastActive!.toString().split(' ')[0];
    }
  }
}

class FriendRequest {
  final String id;
  final String name;
  final String username;
  final String profileImage;
  final int mutualFriends;
  final List<String> mutualFriendsList;
  final List<String> mutualFriendsImages;
  final DateTime timestamp;

  FriendRequest({
    required this.id,
    required this.name,
    required this.username,
    required this.profileImage,
    required this.mutualFriends,
    required this.mutualFriendsList,
    required this.mutualFriendsImages,
    required this.timestamp,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return '${(difference.inDays / 7).floor()} week${(difference.inDays / 7).floor() > 1 ? 's' : ''} ago';
    }
  }
}

class FriendSuggestion {
  final String id;
  final String name;
  final String username;
  final String profileImage;
  final int mutualFriends;
  final List<String> mutualFriendsList;
  final List<String> mutualFriendsImages;
  final String reason;
  final bool isVerified;

  FriendSuggestion({
    required this.id,
    required this.name,
    required this.username,
    required this.profileImage,
    required this.mutualFriends,
    required this.mutualFriendsList,
    required this.mutualFriendsImages,
    required this.reason,
    required this.isVerified,
  });
}

class FriendsProvider with ChangeNotifier {
  List<Friend> _friends = [];
  List<FriendRequest> _friendRequests = [];
  List<FriendSuggestion> _suggestions = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Friend> get friends => List.unmodifiable(_friends);
  List<FriendRequest> get friendRequests => List.unmodifiable(_friendRequests);
  List<FriendSuggestion> get suggestions => List.unmodifiable(_suggestions);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  int get pendingRequestsCount => _friendRequests.length;
  int get onlineFriendsCount => _friends.where((f) => f.onlineStatus == OnlineStatus.online).length;
  List<Friend> get closeFriends => _friends.where((f) => f.isCloseFriend).toList();
  List<Friend> get favoriteFriends => _friends.where((f) => f.isFavorite).toList();

  // Load all friends data
  Future<void> loadFriendsData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      _loadMockFriends();
      _loadMockFriendRequests();
      _loadMockSuggestions();
      
      _isLoading = false;
      notifyListeners();
      
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load friends data';
      notifyListeners();
    }
  }

  // Accept friend request
  void acceptFriendRequest(String requestId) {
    final request = _friendRequests.firstWhere((r) => r.id == requestId);
    _friendRequests.removeWhere((r) => r.id == requestId);
    
    // Add to friends list
    final newFriend = Friend(
      id: request.id,
      name: request.name,
      username: request.username,
      profileImage: request.profileImage,
      onlineStatus: OnlineStatus.offline,
      lastActive: DateTime.now(),
      mutualFriends: request.mutualFriends,
      isCloseFriend: false,
      isFavorite: false,
      hasStory: false,
      status: FriendStatus.accepted,
      mutualFriendsList: request.mutualFriendsList,
      mutualFriendsImages: request.mutualFriendsImages,
    );
    
    _friends.insert(0, newFriend);
    notifyListeners();
  }

  // Decline friend request
  void declineFriendRequest(String requestId) {
    _friendRequests.removeWhere((r) => r.id == requestId);
    notifyListeners();
  }

  // Send friend request
  void sendFriendRequest(String userId) {
    // In a real app, this would call an API
    // For mock, we'll just remove from suggestions
    _suggestions.removeWhere((s) => s.id == userId);
    notifyListeners();
  }

  // Remove suggestion
  void removeSuggestion(String userId) {
    _suggestions.removeWhere((s) => s.id == userId);
    notifyListeners();
  }

  // Toggle close friend
  void toggleCloseFriend(String friendId) {
    final index = _friends.indexWhere((f) => f.id == friendId);
    if (index != -1) {
      final friend = _friends[index];
      _friends[index] = Friend(
        id: friend.id,
        name: friend.name,
        username: friend.username,
        profileImage: friend.profileImage,
        onlineStatus: friend.onlineStatus,
        lastActive: friend.lastActive,
        mutualFriends: friend.mutualFriends,
        isCloseFriend: !friend.isCloseFriend,
        isFavorite: friend.isFavorite,
        hasStory: friend.hasStory,
        status: friend.status,
        mutualFriendsList: friend.mutualFriendsList,
        mutualFriendsImages: friend.mutualFriendsImages,
      );
      notifyListeners();
    }
  }

  // Toggle favorite
  void toggleFavorite(String friendId) {
    final index = _friends.indexWhere((f) => f.id == friendId);
    if (index != -1) {
      final friend = _friends[index];
      _friends[index] = Friend(
        id: friend.id,
        name: friend.name,
        username: friend.username,
        profileImage: friend.profileImage,
        onlineStatus: friend.onlineStatus,
        lastActive: friend.lastActive,
        mutualFriends: friend.mutualFriends,
        isCloseFriend: friend.isCloseFriend,
        isFavorite: !friend.isFavorite,
        hasStory: friend.hasStory,
        status: friend.status,
        mutualFriendsList: friend.mutualFriendsList,
        mutualFriendsImages: friend.mutualFriendsImages,
      );
      notifyListeners();
    }
  }

  // Search friends
  List<Friend> searchFriends(String query) {
    if (query.isEmpty) return _friends;
    return _friends.where((f) {
      return f.name.toLowerCase().contains(query.toLowerCase()) ||
             f.username.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Mock data loading
  void _loadMockFriends() {
    _friends = [
      Friend(
        id: '1',
        name: 'Emma Watson',
        username: '@emmawatson',
        profileImage: 'https://randomuser.me/api/portraits/women/44.jpg',
        onlineStatus: OnlineStatus.online,
        lastActive: DateTime.now(),
        mutualFriends: 15,
        isCloseFriend: true,
        isFavorite: true,
        hasStory: true,
        status: FriendStatus.accepted,
        mutualFriendsList: ['John', 'Sarah', 'Mike', 'Anna', 'David', 'Lisa', 'Tom', 'Rachel', 'Chris', 'Emma', 'James', 'Sophie', 'Robert', 'Jennifer', 'William'],
        mutualFriendsImages: [
          'https://randomuser.me/api/portraits/men/32.jpg',
          'https://randomuser.me/api/portraits/women/22.jpg',
          'https://randomuser.me/api/portraits/men/45.jpg',
        ],
      ),
      Friend(
        id: '2',
        name: 'Tom Holland',
        username: '@tomholland',
        profileImage: 'https://randomuser.me/api/portraits/men/32.jpg',
        onlineStatus: OnlineStatus.online,
        lastActive: DateTime.now(),
        mutualFriends: 8,
        isCloseFriend: true,
        isFavorite: true,
        hasStory: true,
        status: FriendStatus.accepted,
        mutualFriendsList: ['Zendaya', 'Jacob', 'Robert', 'Emma', 'Chris'],
        mutualFriendsImages: [
          'https://randomuser.me/api/portraits/women/33.jpg',
          'https://randomuser.me/api/portraits/men/22.jpg',
        ],
      ),
      Friend(
        id: '3',
        name: 'Zendaya',
        username: '@zendaya',
        profileImage: 'https://randomuser.me/api/portraits/women/33.jpg',
        onlineStatus: OnlineStatus.offline,
        lastActive: DateTime.now().subtract(const Duration(hours: 2)),
        mutualFriends: 12,
        isCloseFriend: false,
        isFavorite: true,
        hasStory: false,
        status: FriendStatus.accepted,
        mutualFriendsList: ['Tom', 'Jacob', 'Emma'],
        mutualFriendsImages: [
          'https://randomuser.me/api/portraits/men/32.jpg',
          'https://randomuser.me/api/portraits/women/44.jpg',
        ],
      ),
      Friend(
        id: '4',
        name: 'Robert Downey Jr.',
        username: '@robertdowney',
        profileImage: 'https://randomuser.me/api/portraits/men/45.jpg',
        onlineStatus: OnlineStatus.away,
        lastActive: DateTime.now().subtract(const Duration(minutes: 30)),
        mutualFriends: 23,
        isCloseFriend: false,
        isFavorite: false,
        hasStory: true,
        status: FriendStatus.accepted,
        mutualFriendsList: ['Chris', 'Scarlett', 'Mark', 'Jennifer', 'Paul', 'Tom'],
        mutualFriendsImages: [
          'https://randomuser.me/api/portraits/men/8.jpg',
          'https://randomuser.me/api/portraits/women/10.jpg',
          'https://randomuser.me/api/portraits/men/11.jpg',
        ],
      ),
      Friend(
        id: '5',
        name: 'Chris Evans',
        username: '@chrisevans',
        profileImage: 'https://randomuser.me/api/portraits/men/8.jpg',
        onlineStatus: OnlineStatus.offline,
        lastActive: DateTime.now().subtract(const Duration(days: 1)),
        mutualFriends: 42,
        isCloseFriend: false,
        isFavorite: false,
        hasStory: false,
        status: FriendStatus.accepted,
        mutualFriendsList: ['Robert', 'Scarlett', 'Mark', 'Jennifer'],
        mutualFriendsImages: [
          'https://randomuser.me/api/portraits/men/9.jpg',
          'https://randomuser.me/api/portraits/women/10.jpg',
          'https://randomuser.me/api/portraits/men/11.jpg',
        ],
      ),
    ];
  }

  void _loadMockFriendRequests() {
    _friendRequests = [
      FriendRequest(
        id: '6',
        name: 'Scarlett Johansson',
        username: '@scarlettj',
        profileImage: 'https://randomuser.me/api/portraits/women/10.jpg',
        mutualFriends: 18,
        mutualFriendsList: ['Chris', 'Robert', 'Tom', 'Emma', 'Zendaya'],
        mutualFriendsImages: [
          'https://randomuser.me/api/portraits/men/8.jpg',
          'https://randomuser.me/api/portraits/women/44.jpg',
          'https://randomuser.me/api/portraits/men/32.jpg',
        ],
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      FriendRequest(
        id: '7',
        name: 'Mark Ruffalo',
        username: '@markruffalo',
        profileImage: 'https://randomuser.me/api/portraits/men/9.jpg',
        mutualFriends: 6,
        mutualFriendsList: ['Robert', 'Chris'],
        mutualFriendsImages: [
          'https://randomuser.me/api/portraits/men/45.jpg',
          'https://randomuser.me/api/portraits/men/8.jpg',
        ],
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  void _loadMockSuggestions() {
    _suggestions = [
      FriendSuggestion(
        id: '8',
        name: 'Alex Turner',
        username: '@alexturner',
        profileImage: 'https://randomuser.me/api/portraits/men/6.jpg',
        mutualFriends: 18,
        mutualFriendsList: ['Emma', 'Tom', 'Zendaya', 'Chris'],
        mutualFriendsImages: [
          'https://randomuser.me/api/portraits/women/44.jpg',
          'https://randomuser.me/api/portraits/men/32.jpg',
          'https://randomuser.me/api/portraits/women/33.jpg',
        ],
        reason: 'Suggested for you',
        isVerified: true,
      ),
      FriendSuggestion(
        id: '9',
        name: 'Lisa Anderson',
        username: '@lisaanderson',
        profileImage: 'https://randomuser.me/api/portraits/women/7.jpg',
        mutualFriends: 6,
        mutualFriendsList: ['Emma', 'Tom'],
        mutualFriendsImages: [
          'https://randomuser.me/api/portraits/women/44.jpg',
          'https://randomuser.me/api/portraits/men/32.jpg',
        ],
        reason: 'Based on your interests',
        isVerified: false,
      ),
      FriendSuggestion(
        id: '10',
        name: 'Chris Hemsworth',
        username: '@chrishemsworth',
        profileImage: 'https://randomuser.me/api/portraits/men/11.jpg',
        mutualFriends: 42,
        mutualFriendsList: ['Chris Evans', 'Robert', 'Scarlett', 'Mark'],
        mutualFriendsImages: [
          'https://randomuser.me/api/portraits/men/8.jpg',
          'https://randomuser.me/api/portraits/women/10.jpg',
          'https://randomuser.me/api/portraits/men/9.jpg',
        ],
        reason: 'Popular in your network',
        isVerified: true,
      ),
    ];
  }
}