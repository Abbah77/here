import 'package:flutter/material.dart';

enum NotificationType {
  like,
  comment,
  follow,
  mention,
  message,
  event,
  call,
}

enum NotificationStatus { initial, loading, loaded, error }

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String userImage;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;
  final Map<String, dynamic>? metadata;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.userImage,
    required this.timestamp,
    required this.isRead,
    required this.type,
    this.metadata,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    String? userImage,
    DateTime? timestamp,
    bool? isRead,
    NotificationType? type,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      userImage: userImage ?? this.userImage,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
           timestamp.month == now.month &&
           timestamp.day == now.day;
  }

  bool get isYesterday {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return timestamp.year == yesterday.year &&
           timestamp.month == yesterday.month &&
           timestamp.day == yesterday.day;
  }
}

class NotificationProvider with ChangeNotifier {
  List<NotificationItem> _notifications = [];
  NotificationStatus _status = NotificationStatus.initial;
  String? _errorMessage;

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  NotificationStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == NotificationStatus.loading;

  // FIX: Changed from bool to int to satisfy UI Selector
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Map<String, List<NotificationItem>> get groupedNotifications {
    final Map<String, List<NotificationItem>> grouped = {};
    for (var notification in _notifications) {
      String key = notification.isToday ? 'Today' : 
                   notification.isYesterday ? 'Yesterday' : 
                   '${notification.timestamp.day}/${notification.timestamp.month}/${notification.timestamp.year}';
      grouped.putIfAbsent(key, () => []).add(notification);
    }
    return grouped;
  }

  // API & ACTIONS
  
  Future<void> loadNotifications({bool refresh = false}) async {
    _updateStatus(NotificationStatus.loading);
    try {
      await Future.delayed(const Duration(seconds: 1));
      _initializeMockNotifications();
      _updateStatus(NotificationStatus.loaded);
    } catch (e) {
      _updateStatus(NotificationStatus.error, errorMessage: 'Failed to load notifications');
    }
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  // FIX: Added missing method for NotificationAppBar
  void markAllAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  // FIX: Added missing method for _DismissibleTile
  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  // FIX: Added missing method for PopupMenuButton
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  void _updateStatus(NotificationStatus status, {String? errorMessage}) {
    _status = status;
    _errorMessage = errorMessage;
    notifyListeners();
  }

  void _initializeMockNotifications() {
    final now = DateTime.now();
    _notifications = [
      NotificationItem(
        id: '1',
        title: 'Crata Maruti',
        message: 'You have missed a call',
        userImage: 'https://i.pravatar.cc/150?u=1',
        timestamp: now.subtract(const Duration(minutes: 15)),
        isRead: false,
        type: NotificationType.call,
      ),
      NotificationItem(
        id: '2',
        title: 'Amaz Benzon',
        message: 'Has sent you a message',
        userImage: 'https://i.pravatar.cc/150?u=2',
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: false,
        type: NotificationType.message,
      ),
    ];
  }
}
