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
  final Map<String, dynamic>? metadata;
  final bool isMe;

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
    this.metadata,
    required this.isMe,
  });
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
  final DateTime? lastMessageTime;

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
    this.lastMessageTime,
  });
}

class ChatProvider with ChangeNotifier {
  List<Chat> _chats = [];
  Map<String, List<Message>> _messages = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Chat> get chats => List.unmodifiable(_chats);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get unreadCount => _chats.fold(0, (sum, chat) => sum + chat.unreadCount);
  List<Chat> get pinnedChats => _chats.where((c) => c.isPinned).toList();
  List<Chat> get unreadChats => _chats.where((c) => c.unreadCount > 0).toList();

  // Load all chats
  Future<void> loadChats() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      _loadMockChats();
      
      _isLoading = false;
      notifyListeners();
      
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load chats';
      notifyListeners();
    }
  }

  // Load messages for a specific chat
  Future<List<Message>> loadMessages(String chatId) async {
    if (_messages.containsKey(chatId)) {
      return _messages[chatId]!;
    }

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final messages = _loadMockMessages(chatId);
      _messages[chatId] = messages;
      return messages;
      
    } catch (e) {
      _errorMessage = 'Failed to load messages';
      return [];
    }
  }

  // Send message
  Future<Message> sendMessage({
    required String chatId,
    required String content,
    MessageType type = MessageType.text,
    String? imageUrl,
  }) async {
    final currentUser = _getCurrentUser(); // In real app, get from AuthProvider
    
    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: chatId,
      senderId: currentUser.id,
      senderName: currentUser.name,
      senderAvatar: currentUser.avatar,
      content: content,
      type: type,
      status: MessageStatus.sending,
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
      isMe: true,
    );

    // Add to messages list
    if (!_messages.containsKey(chatId)) {
      _messages[chatId] = [];
    }
    _messages[chatId]!.insert(0, newMessage);
    
    // Update last message in chat list
    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex != -1) {
      _chats[chatIndex] = Chat(
        id: _chats[chatIndex].id,
        type: _chats[chatIndex].type,
        name: _chats[chatIndex].name,
        avatar: _chats[chatIndex].avatar,
        participants: _chats[chatIndex].participants,
        lastMessage: newMessage,
        unreadCount: 0,
        isPinned: _chats[chatIndex].isPinned,
        isMuted: _chats[chatIndex].isMuted,
        isTyping: false,
        lastMessageTime: DateTime.now(),
      );
    }
    
    notifyListeners();

    // Simulate message being sent
    Future.delayed(const Duration(seconds: 1), () {
      final messageIndex = _messages[chatId]!.indexWhere((m) => m.id == newMessage.id);
      if (messageIndex != -1) {
        _messages[chatId]![messageIndex] = Message(
          id: newMessage.id,
          chatId: newMessage.chatId,
          senderId: newMessage.senderId,
          senderName: newMessage.senderName,
          senderAvatar: newMessage.senderAvatar,
          content: newMessage.content,
          type: newMessage.type,
          status: MessageStatus.sent,
          timestamp: newMessage.timestamp,
          imageUrl: newMessage.imageUrl,
          isMe: true,
        );
        notifyListeners();
      }
    });

    return newMessage;
  }

  // Set typing status
  void setTyping(String chatId, bool isTyping) {
    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex != -1) {
      _chats[chatIndex] = Chat(
        id: _chats[chatIndex].id,
        type: _chats[chatIndex].type,
        name: _chats[chatIndex].name,
        avatar: _chats[chatIndex].avatar,
        participants: _chats[chatIndex].participants,
        lastMessage: _chats[chatIndex].lastMessage,
        unreadCount: _chats[chatIndex].unreadCount,
        isPinned: _chats[chatIndex].isPinned,
        isMuted: _chats[chatIndex].isMuted,
        isTyping: isTyping,
        lastMessageTime: _chats[chatIndex].lastMessageTime,
      );
      notifyListeners();
    }
  }

  // Mark chat as read
  void markAsRead(String chatId) {
    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex != -1 && _chats[chatIndex].unreadCount > 0) {
      _chats[chatIndex] = Chat(
        id: _chats[chatIndex].id,
        type: _chats[chatIndex].type,
        name: _chats[chatIndex].name,
        avatar: _chats[chatIndex].avatar,
        participants: _chats[chatIndex].participants,
        lastMessage: _chats[chatIndex].lastMessage,
        unreadCount: 0,
        isPinned: _chats[chatIndex].isPinned,
        isMuted: _chats[chatIndex].isMuted,
        isTyping: _chats[chatIndex].isTyping,
        lastMessageTime: _chats[chatIndex].lastMessageTime,
      );
      notifyListeners();
    }
  }

  // Toggle pin
  void togglePin(String chatId) {
    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex != -1) {
      _chats[chatIndex] = Chat(
        id: _chats[chatIndex].id,
        type: _chats[chatIndex].type,
        name: _chats[chatIndex].name,
        avatar: _chats[chatIndex].avatar,
        participants: _chats[chatIndex].participants,
        lastMessage: _chats[chatIndex].lastMessage,
        unreadCount: _chats[chatIndex].unreadCount,
        isPinned: !_chats[chatIndex].isPinned,
        isMuted: _chats[chatIndex].isMuted,
        isTyping: _chats[chatIndex].isTyping,
        lastMessageTime: _chats[chatIndex].lastMessageTime,
      );
      notifyListeners();
    }
  }

  // Toggle mute
  void toggleMute(String chatId) {
    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex != -1) {
      _chats[chatIndex] = Chat(
        id: _chats[chatIndex].id,
        type: _chats[chatIndex].type,
        name: _chats[chatIndex].name,
        avatar: _chats[chatIndex].avatar,
        participants: _chats[chatIndex].participants,
        lastMessage: _chats[chatIndex].lastMessage,
        unreadCount: _chats[chatIndex].unreadCount,
        isPinned: _chats[chatIndex].isPinned,
        isMuted: !_chats[chatIndex].isMuted,
        isTyping: _chats[chatIndex].isTyping,
        lastMessageTime: _chats[chatIndex].lastMessageTime,
      );
      notifyListeners();
    }
  }

  // Search chats
  List<Chat> searchChats(String query) {
    if (query.isEmpty) return _chats;
    return _chats.where((chat) {
      return chat.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Mock data loading
  void _loadMockChats() {
    final now = DateTime.now();
    
    _chats = [
      Chat(
        id: '1',
        type: ChatType.individual,
        name: 'Emma Watson',
        avatar: 'https://randomuser.me/api/portraits/women/44.jpg',
        participants: [
          ChatUser(
            id: '2',
            name: 'Emma Watson',
            avatar: 'https://randomuser.me/api/portraits/women/44.jpg',
            isOnline: true,
          ),
        ],
        lastMessage: Message(
          id: 'm1',
          chatId: '1',
          senderId: '2',
          senderName: 'Emma Watson',
          senderAvatar: 'https://randomuser.me/api/portraits/women/44.jpg',
          content: 'Hey! Are we still meeting tomorrow?',
          type: MessageType.text,
          status: MessageStatus.read,
          timestamp: now.subtract(const Duration(minutes: 5)),
          isMe: false,
        ),
        unreadCount: 3,
        isPinned: true,
        isMuted: false,
        isTyping: false,
        lastMessageTime: now.subtract(const Duration(minutes: 5)),
      ),
      Chat(
        id: '2',
        type: ChatType.group,
        name: 'Design Team',
        avatar: 'https://randomuser.me/api/portraits/men/32.jpg',
        participants: [
          ChatUser(
            id: '3',
            name: 'Tom Holland',
            avatar: 'https://randomuser.me/api/portraits/men/32.jpg',
            isOnline: true,
          ),
          ChatUser(
            id: '4',
            name: 'Zendaya',
            avatar: 'https://randomuser.me/api/portraits/women/33.jpg',
            isOnline: false,
          ),
        ],
        lastMessage: Message(
          id: 'm2',
          chatId: '2',
          senderId: '3',
          senderName: 'Tom Holland',
          senderAvatar: 'https://randomuser.me/api/portraits/men/32.jpg',
          content: 'Mike: I\'ve updated the mockups',
          type: MessageType.text,
          status: MessageStatus.delivered,
          timestamp: now.subtract(const Duration(hours: 1)),
          isMe: false,
        ),
        unreadCount: 0,
        isPinned: true,
        isMuted: false,
        isTyping: true,
        lastMessageTime: now.subtract(const Duration(hours: 1)),
      ),
      Chat(
        id: '3',
        type: ChatType.individual,
        name: 'Tom Holland',
        avatar: 'https://randomuser.me/api/portraits/men/32.jpg',
        participants: [
          ChatUser(
            id: '3',
            name: 'Tom Holland',
            avatar: 'https://randomuser.me/api/portraits/men/32.jpg',
            isOnline: true,
          ),
        ],
        lastMessage: Message(
          id: 'm3',
          chatId: '3',
          senderId: '1',
          senderName: 'You',
          senderAvatar: 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
          content: 'Thanks for the help! 🎬',
          type: MessageType.text,
          status: MessageStatus.read,
          timestamp: now.subtract(const Duration(hours: 3)),
          isMe: true,
        ),
        unreadCount: 1,
        isPinned: false,
        isMuted: true,
        isTyping: false,
        lastMessageTime: now.subtract(const Duration(hours: 3)),
      ),
    ];
  }

  List<Message> _loadMockMessages(String chatId) {
    final now = DateTime.now();
    
    return [
      Message(
        id: 'm1',
        chatId: chatId,
        senderId: '2',
        senderName: 'Emma Watson',
        senderAvatar: 'https://randomuser.me/api/portraits/women/44.jpg',
        content: 'Hey! How are you?',
        type: MessageType.text,
        status: MessageStatus.read,
        timestamp: now.subtract(const Duration(minutes: 30)),
        isMe: false,
      ),
      Message(
        id: 'm2',
        chatId: chatId,
        senderId: '1',
        senderName: 'You',
        senderAvatar: 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
        content: 'I\'m good! Just working on the new features.',
        type: MessageType.text,
        status: MessageStatus.read,
        timestamp: now.subtract(const Duration(minutes: 28)),
        isMe: true,
      ),
      Message(
        id: 'm3',
        chatId: chatId,
        senderId: '2',
        senderName: 'Emma Watson',
        senderAvatar: 'https://randomuser.me/api/portraits/women/44.jpg',
        content: 'Sounds exciting! Can\'t wait to see them.',
        type: MessageType.text,
        status: MessageStatus.read,
        timestamp: now.subtract(const Duration(minutes: 27)),
        isMe: false,
      ),
      Message(
        id: 'm4',
        chatId: chatId,
        senderId: '1',
        senderName: 'You',
        senderAvatar: 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
        content: 'Check out this design!',
        type: MessageType.image,
        status: MessageStatus.read,
        timestamp: now.subtract(const Duration(minutes: 25)),
        imageUrl: 'https://via.placeholder.com/300',
        isMe: true,
      ),
    ];
  }

  ChatUser _getCurrentUser() {
    return ChatUser(
      id: '1',
      name: 'You',
      avatar: 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
      isOnline: true,
    );
  }
}