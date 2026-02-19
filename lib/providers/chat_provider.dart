import 'package:flutter/material.dart';

enum MessageStatus { sending, sent, delivered, read, error }
enum MessageType { text, image, video, file, audio }
enum ChatType { individual, group }

class ChatUser {
  final String id;
  final String name;
  final String avatar;
  final bool isOnline;
  final DateTime? lastSeen;
  final bool isTyping;

  ChatUser({
    required this.id,
    required this.name,
    required this.avatar,
    required this.isOnline,
    this.lastSeen,
    this.isTyping = false,
  });
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final String? imageUrl;
  final bool isMe;
  // NEW: Fields for Quoted/Reply Messages
  final String? replyToId;
  final String? replyToContent;
  final String? replyToUser;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.content,
    required this.type,
    required this.status,
    required this.timestamp,
    this.imageUrl,
    required this.isMe,
    this.replyToId,
    this.replyToContent,
    this.replyToUser,
  });

  Message copyWith({MessageStatus? status, String? content}) {
    return Message(
      id: id,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      content: content ?? this.content,
      type: type,
      status: status ?? this.status,
      timestamp: timestamp,
      imageUrl: imageUrl,
      isMe: isMe,
      replyToId: replyToId,
      replyToContent: replyToContent,
      replyToUser: replyToUser,
    );
  }
}

class Chat {
  final String id;
  final ChatType type;
  final String name;
  final String avatar;
  final List<ChatUser> participants;
  final Message lastMessage;
  final int unreadCount;
  final bool isPinned;
  final bool isMuted;
  final bool isTyping;
  final DateTime lastMessageTime;

  Chat({
    required this.id,
    required this.type,
    required this.name,
    required this.avatar,
    required this.participants,
    required this.lastMessage,
    required this.unreadCount,
    this.isPinned = false,
    this.isMuted = false,
    this.isTyping = false,
    required this.lastMessageTime,
  });

  Chat copyWith({
    Message? lastMessage,
    int? unreadCount,
    bool? isTyping,
    bool? isPinned,
    bool? isMuted,
    DateTime? lastMessageTime,
  }) {
    return Chat(
      id: id,
      type: type,
      name: name,
      avatar: avatar,
      participants: participants,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
      isTyping: isTyping ?? this.isTyping,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
    );
  }
}

class ChatProvider with ChangeNotifier {
  List<Chat> _chats = [];
  final Map<String, List<Message>> _messages = {};
  bool _isLoading = false;
  String? _error;

  List<Chat> get chats => _chats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // NEW: State for the message currently being replied to
  Message? _replyingTo;
  Message? get replyingTo => _replyingTo;

  void setReplyMessage(Message? message) {
    _replyingTo = message;
    notifyListeners();
  }

  Future<void> loadChats() async {
    if (_chats.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 1));
      _chats = _generateMockChats();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<List<Message>> loadMessages(String chatId) async {
    if (_messages.containsKey(chatId)) return _messages[chatId]!;
    final mockMessages = _generateMockMessages(chatId);
    _messages[chatId] = mockMessages;
    return mockMessages;
  }

  Future<void> sendMessage({
    required String chatId, 
    required String content,
  }) async {
    final newMessage = Message(
      id: DateTime.now().toString(),
      chatId: chatId,
      senderId: 'me',
      senderName: 'You',
      senderAvatar: 'https://i.pravatar.cc/150?u=me',
      content: content,
      type: MessageType.text,
      status: MessageStatus.sending,
      timestamp: DateTime.now(),
      isMe: true,
      // NEW: Attach reply metadata if it exists
      replyToId: _replyingTo?.id,
      replyToContent: _replyingTo?.content,
      replyToUser: _replyingTo?.senderName,
    );

    // Add to local state
    if (_messages.containsKey(chatId)) {
      _messages[chatId]!.insert(0, newMessage);
    } else {
      _messages[chatId] = [newMessage];
    }

    // Update list preview
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(
        lastMessage: newMessage,
        lastMessageTime: DateTime.now(),
      );
      final chat = _chats.removeAt(index);
      _chats.insert(0, chat);
    }

    // Clear reply state after sending
    _replyingTo = null;
    notifyListeners();

    // Mock server delivery
    await Future.delayed(const Duration(milliseconds: 500));
    _updateStatus(chatId, newMessage.id, MessageStatus.sent);
  }

  void _updateStatus(String chatId, String id, MessageStatus status) {
    final mIndex = _messages[chatId]?.indexWhere((m) => m.id == id) ?? -1;
    if (mIndex != -1) {
      _messages[chatId]![mIndex] = _messages[chatId]![mIndex].copyWith(status: status);
      notifyListeners();
    }
  }

  void markAsRead(String chatId) {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1 && _chats[index].unreadCount > 0) {
      _chats[index] = _chats[index].copyWith(unreadCount: 0);
      notifyListeners();
    }
  }

  // --- MOCK DATA ---
  List<Chat> _generateMockChats() {
    return [
      Chat(
        id: 'c1',
        type: ChatType.individual,
        name: 'Emma Watson',
        avatar: 'https://i.pravatar.cc/150?u=emma',
        participants: [ChatUser(id: 'u2', name: 'Emma', avatar: '', isOnline: true)],
        unreadCount: 2,
        isPinned: true,
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        lastMessage: Message(
          id: 'm1', chatId: 'c1', senderId: 'u2', senderName: 'Emma',
          senderAvatar: '', content: 'Did you see the new design?', 
          type: MessageType.text, status: MessageStatus.read, 
          timestamp: DateTime.now(), isMe: false
        ),
      ),
    ];
  }

  List<Message> _generateMockMessages(String chatId) {
    return [
      Message(
        id: 'pm1', chatId: chatId, senderId: 'u2', senderName: 'Emma',
        senderAvatar: '', content: 'Let me know what you think!', 
        type: MessageType.text, status: MessageStatus.read, 
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)), isMe: false
      ),
    ];
  }
}
