// lib/providers/notification_provider.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

enum NotificationStatus { initial, loading, loaded, error }

enum NotificationType {
  like,
  comment,
  follow,
  mention,
  friendRequest,
  accepted,
  share,
  system
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String userImage;
  final String userId;
  final String userName;
  final String? postId;
  final DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.userImage,
    required this.userId,
    required this.userName,
    this.postId,
    required this.timestamp,
    this.isRead = false,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
    id: json['id'],
    type: _getNotificationType(json['type']),
    title: json['title'],
    message: json['message'],
    userImage: json['userImage'] ?? '',
    userId: json['userId'],
    userName: json['userName'],
    postId: json['postId'],
    timestamp: DateTime.parse(json['timestamp']),
    isRead: json['isRead'] ?? false,
  );

  static NotificationType _getNotificationType(String type) {
    switch (type) {
      case 'like': return NotificationType.like;
      case 'comment': return NotificationType.comment;
      case 'follow': return NotificationType.follow;
      case 'mention': return NotificationType.mention;
      case 'friendRequest': return NotificationType.friendRequest;
      case 'accepted': return NotificationType.accepted;
      case 'share': return NotificationType.share;
      default: return NotificationType.system;
    }
  }
}

class NotificationProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<NotificationItem> _notifications = [];
  NotificationStatus _status = NotificationStatus.initial;
  String? _errorMessage;

  // Getters
  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  NotificationStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == NotificationStatus.loading;
  bool get hasError => _status == NotificationStatus.error;
  bool get hasNotifications => _notifications.isNotEmpty;

  int get unreadCount {
    return _notifications.where((n) => !n.isRead).length;
  }

  Map<String, List<NotificationItem>> get groupedNotifications {
    final grouped = <String, List<NotificationItem>>{};
    
    for (var notification in _notifications) {
      final date = _getDateKey(notification.timestamp);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(notification);
    }
    
    return grouped;
  }

  // Load notifications
  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _notifications = [];
    }
    
    _status = NotificationStatus.loading;
    notifyListeners();

    try {
      final response = await _api.get('notifications');
      
      _notifications = (response['notifications'] as List)
          .map((n) => NotificationItem.fromJson(n))
          .toList();
      
      _status = NotificationStatus.loaded;
      notifyListeners();
    } catch (e) {
      _status = NotificationStatus.error;
      _errorMessage = 'Failed to load notifications';
      
      // Fallback to mock data
      _loadMockNotifications();
      notifyListeners();
    }
  }

  // Mark as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
      
      try {
        await _api.post('notifications/$notificationId/read', {});
      } catch (e) {
        // Handle error silently
      }
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    notifyListeners();
    
    try {
      await _api.post('notifications/read-all', {});
    } catch (e) {
      // Handle error silently
    }
  }

  // Remove notification
  Future<void> removeNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
    
    try {
      await _api.delete('notifications/$notificationId');
    } catch (e) {
      // Handle error silently
    }
  }

  // Clear all
  Future<void> clearAll() async {
    _notifications.clear();
    notifyListeners();
    
    try {
      await _api.delete('notifications/all');
    } catch (e) {
      // Handle error silently
    }
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _loadMockNotifications() {
    final mockData = [
      {
        'id': '1',
        'type': 'like',
        'title': 'Emma Watson liked your post',
        'message': 'Great photo! 📸',
        'userImage': 'https://randomuser.me/api/portraits/women/44.jpg',
        'userId': '2',
        'userName': 'Emma Watson',
        'postId': '2',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
        'isRead': false,
      },
    ];
    
    _notifications = mockData.map((n) => NotificationItem.fromJson(n)).toList();
  }
}