import 'package:flutter/material.dart';

enum MessageStatus { sending, sent, delivered, read, error }
enum MessageType { text, image, video, file, audio }
enum ChatType { individual, group }

class ChatUser {
  final String id;
  final String name;
  final String avatar;
  final bool isOnline;
  final bool isTyping;

  ChatUser({required this.id, required this.name, required this.avatar, this.isOnline = false, this.isTyping = false});
}

class Message {
  final String id, chatId, senderId, senderName, senderAvatar, content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final bool isMe;
  final String? replyToContent, replyToUser;

  Message({
    required this.id, required this.chatId, required this.senderId, required this.senderName,
    required this.senderAvatar, required this.content, required this.type, required this.status,
    required this.timestamp, required this.isMe, this.replyToContent, this.replyToUser,
  });

  Message copyWith({MessageStatus? status}) => Message(
    id: id, chatId: chatId, senderId: senderId, senderName: senderName, senderAvatar: senderAvatar,
    content: content, type: type, status: status ?? this.status, timestamp: timestamp, isMe: isMe,
    replyToContent: replyToContent, replyToUser: replyToUser,
  );
}

class Chat {
  final String id, name, avatar;
  final ChatType type;
  final List<ChatUser> participants;
  final Message lastMessage;
  final int unreadCount;
  final bool isPinned, isTyping;
  final DateTime lastMessageTime;

  Chat({
    required this.id, required this.type, required this.name, required this.avatar,
    required this.participants, required this.lastMessage, required this.unreadCount,
    this.isPinned = false, this.isTyping = false, required this.lastMessageTime,
  });

  Chat copyWith({Message? lastMessage, int? unreadCount, bool? isTyping}) => Chat(
    id: id, type: type, name: name, avatar: avatar, participants: participants,
    lastMessage: lastMessage ?? this.lastMessage, unreadCount: unreadCount ?? this.unreadCount,
    isPinned: isPinned, isTyping: isTyping ?? this.isTyping, lastMessageTime: DateTime.now(),
  );
}

class ChatProvider with ChangeNotifier {
  List<Chat> _chats = [];
  final Map<String, List<Message>> _messages = {};
  bool _isLoading = false;
  Message? _replyingTo;

  List<Chat> get chats => _chats;
  bool get isLoading => _isLoading;
  Message? get replyingTo => _replyingTo;
  
  // FIX: Added the missing getter for the UI
  List<Chat> get pinnedChats => _chats.where((c) => c.isPinned).toList();

  // FIX: Added the missing search method for the UI
  List<Chat> searchChats(String query) {
    if (query.isEmpty) return _chats;
    return _chats.where((c) => c.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  void setReplyMessage(Message? message) {
    _replyingTo = message;
    notifyListeners();
  }

  Future<void> loadChats() async {
    if (_chats.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _chats = _genMocks();
    _isLoading = false;
    notifyListeners();
  }

  Future<List<Message>> loadMessages(String chatId) async {
    return _messages[chatId] ??= [
      Message(
        id: 'm1', chatId: chatId, senderId: 'u2', senderName: 'Emma', senderAvatar: '',
        content: 'Check the latest build!', type: MessageType.text, status: MessageStatus.read,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)), isMe: false
      )
    ];
  }

  Future<void> sendMessage({required String chatId, required String content}) async {
    final msg = Message(
      id: DateTime.now().toString(), chatId: chatId, senderId: 'me', senderName: 'You',
      senderAvatar: '', content: content, type: MessageType.text, status: MessageStatus.sending,
      timestamp: DateTime.now(), isMe: true, replyToContent: _replyingTo?.content, replyToUser: _replyingTo?.senderName,
    );
    _messages[chatId]?.insert(0, msg);
    final idx = _chats.indexWhere((c) => c.id == chatId);
    if (idx != -1) {
      _chats[idx] = _chats[idx].copyWith(lastMessage: msg, unreadCount: 0);
      final c = _chats.removeAt(idx);
      _chats.insert(0, c);
    }
    _replyingTo = null;
    notifyListeners();
  }

  void markAsRead(String chatId) {
    final idx = _chats.indexWhere((c) => c.id == chatId);
    if (idx != -1) { _chats[idx] = _chats[idx].copyWith(unreadCount: 0); notifyListeners(); }
  }

  List<Chat> _genMocks() => [
    Chat(
      id: 'c1', type: ChatType.individual, name: 'Emma Watson', avatar: 'https://i.pravatar.cc/150?u=emma',
      participants: [ChatUser(id: 'u2', name: 'Emma', avatar: '', isOnline: true)],
      unreadCount: 2, isPinned: true, lastMessageTime: DateTime.now(),
      lastMessage: Message(id: 'l1', chatId: 'c1', senderId: 'u2', senderName: 'Emma', senderAvatar: '', content: 'Build looks good!', type: MessageType.text, status: MessageStatus.read, timestamp: DateTime.now(), isMe: false),
    )
  ];
}
