// lib/providers/chat_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

enum MessageStatus { sending, sent, delivered, read, error }
enum MessageType { text, image, video, file, audio }
enum ChatType { individual, group }

class ChatUser {
  final String id, name, avatar;
  final bool isOnline, isTyping;
  ChatUser({required this.id, required this.name, required this.avatar, this.isOnline = false, this.isTyping = false});
  
  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
    id: json['id'],
    name: json['name'],
    avatar: json['avatar'] ?? '',
    isOnline: json['isOnline'] ?? false,
    isTyping: json['isTyping'] ?? false,
  );
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

  Message copyWith({String? content, MessageStatus? status}) => Message(
    id: id, chatId: chatId, senderId: senderId, senderName: senderName,
    senderAvatar: senderAvatar, content: content ?? this.content, type: type,
    status: status ?? this.status, timestamp: timestamp, isMe: isMe,
    replyToContent: replyToContent, replyToUser: replyToUser,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'chatId': chatId,
    'senderId': senderId,
    'senderName': senderName,
    'content': content,
    'type': type.index,
    'timestamp': timestamp.toIso8601String(),
    'isMe': isMe,
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    chatId: json['chatId'],
    senderId: json['senderId'],
    senderName: json['senderName'],
    senderAvatar: json['senderAvatar'] ?? '',
    content: json['content'],
    type: MessageType.values[json['type']],
    status: MessageStatus.values[json['status'] ?? 3], // Default to read
    timestamp: DateTime.parse(json['timestamp']),
    isMe: json['isMe'],
    replyToContent: json['replyToContent'],
    replyToUser: json['replyToUser'],
  );
}

class Chat {
  final String id, name, avatar;
  final ChatType type;
  final List<ChatUser> participants;
  final Message lastMessage;
  final int unreadCount;
  final bool isPinned;

  Chat({
    required this.id, required this.name, required this.avatar, required this.type,
    required this.participants, required this.lastMessage, this.unreadCount = 0, this.isPinned = false,
  });

  Chat copyWith({Message? lastMessage, int? unreadCount}) => Chat(
    id: id, name: name, avatar: avatar, type: type, participants: participants,
    lastMessage: lastMessage ?? this.lastMessage, unreadCount: unreadCount ?? this.unreadCount, isPinned: isPinned,
  );

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
    id: json['id'],
    name: json['name'],
    avatar: json['avatar'] ?? '',
    type: ChatType.values[json['type']],
    participants: (json['participants'] as List).map((p) => ChatUser.fromJson(p)).toList(),
    lastMessage: Message.fromJson(json['lastMessage']),
    unreadCount: json['unreadCount'] ?? 0,
    isPinned: json['isPinned'] ?? false,
  );
}

class ChatProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<Chat> _chats = [];
  final Map<String, List<Message>> _messages = {};
  bool _isLoading = false;
  bool _isAILoading = false;
  Message? _replyingTo;

  List<Chat> get chats => _chats;
  bool get isLoading => _isLoading;
  bool get isAILoading => _isAILoading;
  Message? get replyingTo => _replyingTo;

  static const String _aiChatId = 'ai_assistant';

  // --- AI INTEGRATION ---
  Future<void> sendAIMessage(String content) async {
    _isAILoading = true;
    notifyListeners();

    final userMsg = Message(
      id: DateTime.now().toIso8601String(), 
      chatId: _aiChatId, 
      senderId: 'user', 
      senderName: 'You',
      senderAvatar: '', 
      content: content, 
      type: MessageType.text, 
      status: MessageStatus.sent,
      timestamp: DateTime.now(), 
      isMe: true,
    );

    _messages[_aiChatId] ??= [];
    _messages[_aiChatId]!.insert(0, userMsg);
    notifyListeners();

    try {
      final response = await _api.post('ai/chat', {
        'message': content,
        'history': _messages[_aiChatId]!.map((e) => e.toJson()).toList(),
      });

      final aiText = response['response'] ?? "";

      final aiMsg = Message(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}', 
        chatId: _aiChatId, 
        senderId: 'assistant',
        senderName: 'Here AI', 
        senderAvatar: 'assets/images/logo.png', 
        content: '', 
        type: MessageType.text, 
        status: MessageStatus.read, 
        timestamp: DateTime.now(), 
        isMe: false,
      );
      _messages[_aiChatId]!.insert(0, aiMsg);
      _isAILoading = false;

      // Typewriter Effect
      for (int i = 0; i < aiText.length; i++) {
        _messages[_aiChatId]![0] = _messages[_aiChatId]![0].copyWith(
          content: _messages[_aiChatId]![0].content + aiText[i]
        );
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 5));
      }
      
      _saveAIHistory();
    } catch (e) {
      _isAILoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveAIHistory() async {
    try {
      await _api.post('ai/history', {
        'messages': _messages[_aiChatId]?.map((e) => e.toJson()).toList() ?? []
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> loadAIHistory() async {
    try {
      final response = await _api.get('ai/history');
      if (response['messages'] != null) {
        _messages[_aiChatId] = (response['messages'] as List)
            .map((m) => Message.fromJson(m))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // --- STANDARD CHAT LOGIC ---
  Future<void> loadChats() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _api.get('chats');
      _chats = (response['chats'] as List).map((c) => Chat.fromJson(c)).toList();
    } catch (e) {
      // Fallback to mock data if API fails
      _chats = _genMocks();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Message>> loadMessages(String chatId) async {
    try {
      final response = await _api.get('chats/$chatId/messages');
      _messages[chatId] = (response['messages'] as List)
          .map((m) => Message.fromJson(m))
          .toList();
      return _messages[chatId]!;
    } catch (e) {
      return _messages[chatId] ?? [];
    }
  }

  Future<void> sendMessage({required String chatId, required String content}) async {
    final msg = Message(
      id: DateTime.now().toString(), 
      chatId: chatId, 
      senderId: 'me', 
      senderName: 'You',
      senderAvatar: '', 
      content: content, 
      type: MessageType.text, 
      status: MessageStatus.sending,
      timestamp: DateTime.now(), 
      isMe: true, 
      replyToContent: _replyingTo?.content, 
      replyToUser: _replyingTo?.senderName,
    );
    
    _messages[chatId] ??= [];
    _messages[chatId]!.insert(0, msg);
    
    final idx = _chats.indexWhere((c) => c.id == chatId);
    if (idx != -1) {
      _chats[idx] = _chats[idx].copyWith(lastMessage: msg, unreadCount: 0);
      final c = _chats.removeAt(idx);
      _chats.insert(0, c);
    }
    _replyingTo = null;
    notifyListeners();

    // Send to backend
    try {
      await _api.post('chats/$chatId/messages', {
        'content': content,
        'replyToId': _replyingTo?.id,
      });
    } catch (e) {
      // Handle error - mark message as failed
    }
  }

  void setReplyMessage(Message? message) {
    _replyingTo = message;
    notifyListeners();
  }

  void markAsRead(String chatId) {
    final idx = _chats.indexWhere((c) => c.id == chatId);
    if (idx != -1) { 
      _chats[idx] = _chats[idx].copyWith(unreadCount: 0); 
      _api.post('chats/$chatId/read', {});
      notifyListeners(); 
    }
  }

  List<Chat> searchChats(String query) {
    if (query.isEmpty) return _chats;
    return _chats.where((c) => c.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  List<Chat> _genMocks() => [
    Chat(
      id: 'c1', type: ChatType.individual, name: 'Emma Watson', avatar: 'https://i.pravatar.cc/150?u=emma',
      isPinned: true, participants: [ChatUser(id: 'u2', name: 'Emma', avatar: '')],
      lastMessage: Message(id: 'm1', chatId: 'c1', senderId: 'u2', senderName: 'Emma', senderAvatar: '', content: 'Did you see the new design?', type: MessageType.text, status: MessageStatus.read, timestamp: DateTime.now(), isMe: false),
    ),
  ];
}