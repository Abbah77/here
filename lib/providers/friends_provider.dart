// lib/providers/friends_provider.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

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

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
    id: json['id'],
    name: json['name'],
    username: json['username'],
    profileImage: json['profileImage'] ?? '',
    onlineStatus: OnlineStatus.values[json['onlineStatus'] ?? 1],
    lastActive: json['lastActive'] != null ? DateTime.parse(json['lastActive']) : null,
    mutualFriends: json['mutualFriends'] ?? 0,
    isCloseFriend: json['isCloseFriend'] ?? false,
    isFavorite: json['isFavorite'] ?? false,
    hasStory: json['hasStory'] ?? false,
    status: FriendStatus.values[json['status'] ?? 1],
    mutualFriendsList: json['mutualFriendsList']?.cast<String>(),
    mutualFriendsImages: json['mutualFriendsImages']?.cast<String>(),
  );
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

  factory FriendRequest.fromJson(Map<String, dynamic> json) => FriendRequest(
    id: json['id'],
    name: json['name'],
    username: json['username'],
    profileImage: json['profileImage'] ?? '',
    mutualFriends: json['mutualFriends'] ?? 0,
    mutualFriendsList: List<String>.from(json['mutualFriendsList'] ?? []),
    mutualFriendsImages: List<String>.from(json['mutualFriendsImages'] ?? []),
    timestamp: DateTime.parse(json['timestamp']),
  );
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

  factory FriendSuggestion.fromJson(Map<String, dynamic> json) => FriendSuggestion(
    id: json['id'],
    name: json['name'],
    username: json['username'],
    profileImage: json['profileImage'] ?? '',
    mutualFriends: json['mutualFriends'] ?? 0,
    mutualFriendsList: List<String>.from(json['mutualFriendsList'] ?? []),
    mutualFriendsImages: List<String>.from(json['mutualFriendsImages'] ?? []),
    reason: json['reason'] ?? 'Suggested for you',
    isVerified: json['isVerified'] ?? false,
  );
}

class FriendsProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  
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
      final response = await _api.get('friends/all');
      
      _friends = (response['friends'] as List).map((f) => Friend.fromJson(f)).toList();
      _friendRequests = (response['requests'] as List).map((r) => FriendRequest.fromJson(r)).toList();
      _suggestions = (response['suggestions'] as List).map((s) => FriendSuggestion.fromJson(s)).toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load friends data';
      
      // Fallback to mock data
      _loadMockFriends();
      _loadMockFriendRequests();
      _loadMockSuggestions();
      
      notifyListeners();
    }
  }

  // Accept friend request
  Future<void> acceptFriendRequest(String requestId) async {
    try {
      await _api.post('friends/accept/$requestId', {});
      
      final request = _friendRequests.firstWhere((r) => r.id == requestId);
      _friendRequests.removeWhere((r) => r.id == requestId);
      
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
    } catch (e) {
      _errorMessage = 'Failed to accept request';
      notifyListeners();
    }
  }

  // Decline friend request
  Future<void> declineFriendRequest(String requestId) async {
    try {
      await _api.post('friends/decline/$requestId', {});
      _friendRequests.removeWhere((r) => r.id == requestId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to decline request';
      notifyListeners();
    }
  }

  // Send friend request
  Future<void> sendFriendRequest(String userId) async {
    try {
      await _api.post('friends/request/$userId', {});
      _suggestions.removeWhere((s) => s.id == userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to send request';
      notifyListeners();
    }
  }

  // Remove suggestion
  void removeSuggestion(String userId) {
    _suggestions.removeWhere((s) => s.id == userId);
    notifyListeners();
  }

  // Toggle close friend
  Future<void> toggleCloseFriend(String friendId) async {
    final index = _friends.indexWhere((f) => f.id == friendId);
    if (index != -1) {
      final friend = _friends[index];
      final newValue = !friend.isCloseFriend;
      
      try {
        await _api.patch('friends/$friendId', {'isCloseFriend': newValue});
        
        _friends[index] = Friend(
          id: friend.id,
          name: friend.name,
          username: friend.username,
          profileImage: friend.profileImage,
          onlineStatus: friend.onlineStatus,
          lastActive: friend.lastActive,
          mutualFriends: friend.mutualFriends,
          isCloseFriend: newValue,
          isFavorite: friend.isFavorite,
          hasStory: friend.hasStory,
          status: friend.status,
          mutualFriendsList: friend.mutualFriendsList,
          mutualFriendsImages: friend.mutualFriendsImages,
        );
        notifyListeners();
      } catch (e) {
        _errorMessage = 'Failed to update friend';
        notifyListeners();
      }
    }
  }

  // Toggle favorite
  Future<void> toggleFavorite(String friendId) async {
    final index = _friends.indexWhere((f) => f.id == friendId);
    if (index != -1) {
      final friend = _friends[index];
      final newValue = !friend.isFavorite;
      
      try {
        await _api.patch('friends/$friendId', {'isFavorite': newValue});
        
        _friends[index] = Friend(
          id: friend.id,
          name: friend.name,
          username: friend.username,
          profileImage: friend.profileImage,
          onlineStatus: friend.onlineStatus,
          lastActive: friend.lastActive,
          mutualFriends: friend.mutualFriends,
          isCloseFriend: friend.isCloseFriend,
          isFavorite: newValue,
          hasStory: friend.hasStory,
          status: friend.status,
          mutualFriendsList: friend.mutualFriendsList,
          mutualFriendsImages: friend.mutualFriendsImages,
        );
        notifyListeners();
      } catch (e) {
        _errorMessage = 'Failed to update friend';
        notifyListeners();
      }
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

  // Mock data loading (fallback)
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
        mutualFriendsList: ['John', 'Sarah', 'Mike'],
        mutualFriendsImages: [
          'https://randomuser.me/api/portraits/men/32.jpg',
          'https://randomuser.me/api/portraits/women/22.jpg',
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
        mutualFriendsList: ['Chris', 'Robert'],
        mutualFriendsImages: [
          'https://randomuser.me/api/portraits/men/8.jpg',
        ],
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
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
        mutualFriendsList: ['Emma', 'Tom'],
        mutualFriendsImages: [
          'https://randomuser.me/api/portraits/women/44.jpg',
        ],
        reason: 'Suggested for you',
        isVerified: true,
      ),
    ];
  }
}