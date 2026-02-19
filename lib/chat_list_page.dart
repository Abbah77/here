import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/chat_provider.dart';
import 'package:here/chat_detail_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ChatProvider>().loadChats());
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provider = context.watch<ChatProvider>();
    final displayChats = provider.searchChats(_searchQuery);

    return Scaffold(
      backgroundColor: colors.surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(colors),
          if (!_isSearching && provider.pinnedChats.isNotEmpty)
            SliverToBoxAdapter(child: _buildPinned(colors, provider.pinnedChats)),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: provider.isLoading 
              ? const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _buildTile(context, colors, displayChats[i]),
                    childCount: displayChats.length,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(ColorScheme colors) {
    return SliverAppBar(
      floating: true, pinned: true,
      title: _isSearching 
        ? TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration( // FIX: suffixIcon is now INSIDE InputDecoration
              hintText: 'Search...', 
              border: InputBorder.none,
              suffixIcon: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() { _isSearching = false; _searchQuery = ''; })),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          )
        : Text('Messages', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
      actions: [ if (!_isSearching) IconButton(icon: const Icon(Icons.search), onPressed: () => setState(() => _isSearching = true)) ],
    );
  }

  Widget _buildPinned(ColorScheme colors, List<Chat> pinned) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pinned.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(children: [CircleAvatar(radius: 28, backgroundImage: NetworkImage(pinned[i].avatar)), Text(pinned[i].name.split(' ')[0])]),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, ColorScheme colors, Chat chat) {
    return ListTile(
      leading: CircleAvatar(radius: 28, backgroundImage: NetworkImage(chat.avatar)),
      title: Text(chat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(chat.lastMessage.content, maxLines: 1),
      trailing: chat.unreadCount > 0 ? CircleAvatar(radius: 10, backgroundColor: colors.primary, child: Text('${chat.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 10))) : null,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailPage(chatId: chat.id, chatName: chat.name, chatAvatar: chat.avatar, isGroup: chat.type == ChatType.group))),
    );
  }
}
