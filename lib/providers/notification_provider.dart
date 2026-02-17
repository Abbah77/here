import 'package:flutter/material.dart';

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
}

class NotificationProvider with ChangeNotifier {
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

  // Mock notifications data
  final List<Map<String, dynamic>> _mockNotificationData = [
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
    {
      'id': '2',
      'type': 'comment',
      'title': 'Tom Holland commented on your post',
      'message': 'This is awesome! 🔥',
      'userImage': 'https://randomuser.me/api/portraits/men/32.jpg',
      'userId': '3',
      'userName': 'Tom Holland',
      'postId': '1',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      'isRead': false,
    },
    {
      'id': '3',
      'type': 'follow',
      'title': 'Zendaya started following you',
      'message': 'Follow back?',
      'userImage': 'https://randomuser.me/api/portraits/women/33.jpg',
      'userId': '4',
      'userName': 'Zendaya',
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      'isRead': false,
    },
    {
      'id': '4',
      'type': 'friendRequest',
      'title': 'Friend Request',
      'message': 'Robert Downey Jr. sent you a friend request',
      'userImage': 'https://randomuser.me/api/portraits/men/45.jpg',
      'userId': '5',
      'userName': 'Robert Downey Jr.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      'isRead': false,
    },
    {
      'id': '5',
      'type': 'accepted',
      'title': 'Friend Request Accepted',
      'message': 'Chris Evans accepted your friend request',
      'userImage': 'https://randomuser.me/api/portraits/men/8.jpg',
      'userId': '6',
      'userName': 'Chris Evans',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'isRead': true,
    },
    {
      'id': '6',
      'type': 'mention',
      'title': 'Sarah mentioned you in a comment',
      'message': 'Hey @Allan, check this out!',
      'userImage': 'https://randomuser.me/api/portraits/women/4.jpg',
      'userId': '7',
      'userName': 'Sarah Williams',
      'postId': '3',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'isRead': true,
    },
    {
      'id': '7',
      'type': 'share',
      'title': 'Mike shared your post',
      'message': 'This is too good!',
      'userImage': 'https://randomuser.me/api/portraits/men/3.jpg',
      'userId': '8',
      'userName': 'Mike Johnson',
      'postId': '1',
      'timestamp': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      'isRead': true,
    },
  ];

  // Load notifications
  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _notifications = [];
    }
    
    _status = NotificationStatus.loading;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      _notifications = _mockNotificationData.map((data) {
        return NotificationItem(
          id: data['id'],
          type: _getNotificationType(data['type']),
          title: data['title'],
          message: data['message'],
          userImage: data['userImage'],
          userId: data['userId'],
          userName: data['userName'],
          postId: data['postId'],
          timestamp: DateTime.parse(data['timestamp']),
          isRead: data['isRead'] ?? false,
        );
      }).toList();
      
      // Sort by timestamp (newest first)
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      _status = NotificationStatus.loaded;
      notifyListeners();
      
    } catch (e) {
      _status = NotificationStatus.error;
      _errorMessage = 'Failed to load notifications';
      notifyListeners();
    }
  }

  // Mark as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  // Mark all as read
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    notifyListeners();
  }

  // Remove notification
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  // Clear all
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  NotificationType _getNotificationType(String type) {
    switch (type) {
      case 'like':
        return NotificationType.like;
      case 'comment':
        return NotificationType.comment;
      case 'follow':
        return NotificationType.follow;
      case 'mention':
        return NotificationType.mention;
      case 'friendRequest':
        return NotificationType.friendRequest;
      case 'accepted':
        return NotificationType.accepted;
      case 'share':
        return NotificationType.share;
      default:
        return NotificationType.system;
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
}