import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/auth_provider.dart';
// Note: Ensure this provider exists or comment out if not used yet
// import 'package:here/providers/friends_provider.dart'; 
import 'package:here/widget/friend_request_card.dart';
import 'package:here/widget/friend_tile.dart';
import 'package:here/widget/suggestion_card.dart';
import 'package:here/profile.dart';

enum FriendsTab { all, online, requests, suggestions }

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> with TickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  FriendsTab _selectedTab = FriendsTab.all;

  // Mock data preserved from your snippet
  final List<Map<String, dynamic>> _friendRequests = [
    {
      'id': '1',
      'name': 'Emma Watson',
      'username': '@emmawatson',
      'image': 'https://randomuser.me/api/portraits/women/44.jpg',
      'mutualFriends': 12,
      'mutualFriendsList': ['John', 'Sarah'],
      'mutualImages': ['https://randomuser.me/api/portraits/men/32.jpg'],
      'timeAgo': '2 min ago',
    },
  ];

  final List<Map<String, dynamic>> _friends = [
    {
      'id': '1',
      'name': 'John Doe',
      'username': '@johndoe',
      'image': 'https://randomuser.me/api/portraits/men/1.jpg',
      'isOnline': true,
      'lastActive': 'Online',
      'isCloseFriend': true,
      'hasStory': true,
    },
  ];

  final List<Map<String, dynamic>> _suggestions = [
    {
      'id': '1',
      'name': 'Alex Turner',
      'username': '@alexturner',
      'image': 'https://randomuser.me/api/portraits/men/6.jpg',
      'reason': 'Suggested for you',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _selectedTab = FriendsTab.values[_tabController.index];
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredFriends() {
    if (_searchQuery.isEmpty) return _friends;
    return _friends.where((friend) {
      return friend['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
             friend['username'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filteredFriends = _getFilteredFriends();
    final onlineFriends = _friends.where((f) => f['isOnline'] == true).toList();

    return Scaffold(
      backgroundColor: colors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: colors.surface,
            title: _isSearching ? _buildSearchField(colors) : _buildTitleRow(colors),
          ),
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: colors.primary,
                labelColor: colors.primary,
                unselectedLabelColor: colors.onSurface.withOpacity(0.6),
                tabs: [
                  Tab(text: 'All (${_friends.length})'),
                  Tab(text: 'Online (${onlineFriends.length})'),
                  Tab(text: 'Requests (${_friendRequests.length})'),
                  const Tab(text: 'Suggestions'),
                ],
              ),
            ),
            pinned: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: _buildTabContent(colors, filteredFriends, onlineFriends),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(ColorScheme colors, List<Map<String, dynamic>> filteredFriends, List<Map<String, dynamic>> onlineFriends) {
    switch (_selectedTab) {
      case FriendsTab.all:
        return Column(
          children: [
            if (_friends.any((f) => f['isCloseFriend'] == true)) _buildCloseFriendsSection(colors),
            if (filteredFriends.isEmpty) _buildEmptyState(colors, 'No friends found') 
            else ...filteredFriends.map((friend) => FriendTile(friend: friend)).toList(),
          ],
        );

      case FriendsTab.online:
        if (onlineFriends.isEmpty) return _buildEmptyState(colors, 'No friends online');
        // FIXED: Added <Widget> type to map to resolve List<dynamic> error
        return Column(
          children: onlineFriends.map<Widget>((friend) => FriendTile(friend: friend)).toList(),
        );

      case FriendsTab.requests:
        if (_friendRequests.isEmpty) return _buildEmptyState(colors, 'No requests');
        // FIXED: Removed named arguments 'colors' and 'onDecline' if they aren't in your FriendRequestCard constructor
        return Column(
          children: _friendRequests.map<Widget>((request) => FriendRequestCard(request: request)).toList(),
        );

      case FriendsTab.suggestions:
        if (_suggestions.isEmpty) return _buildEmptyState(colors, 'No suggestions');
        // FIXED: Removed 'colors' argument to match SuggestionCard constructor
        return Column(
          children: _suggestions.map<Widget>((suggestion) => SuggestionCard(suggestion: suggestion)).toList(),
        );
    }
  }

  // Helper UI methods
  Widget _buildSearchField(ColorScheme colors) {
    return TextField(
      controller: _searchController,
      autofocus: true,
      onChanged: (v) => setState(() => _searchQuery = v),
      decoration: InputDecoration(
        hintText: 'Search...',
        suffixIcon: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _isSearching = false)),
      ),
    );
  }

  Widget _buildTitleRow(ColorScheme colors) {
    return Row(
      children: [
        Text('Friends', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        const Spacer(),
        IconButton(icon: const Icon(Icons.search), onPressed: () => setState(() => _isSearching = true)),
      ],
    );
  }

  Widget _buildCloseFriendsSection(ColorScheme colors) {
     final closeFriends = _friends.where((f) => f['isCloseFriend'] == true).toList();
     return Column(
       children: [
         const Text('Close Friends'),
         SizedBox(
           height: 80,
           child: ListView(
             scrollDirection: Axis.horizontal,
             children: closeFriends.map((f) => CircleAvatar(backgroundImage: NetworkImage(f['image']))).toList(),
           ),
         ),
       ],
     );
  }

  Widget _buildEmptyState(ColorScheme colors, String message, {IconData? icon}) {
    return Center(child: Text(message));
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);
  @override double get minExtent => _tabBar.preferredSize.height;
  @override double get maxExtent => _tabBar.preferredSize.height;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Theme.of(context).colorScheme.surface, child: _tabBar);
  }
  @override bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
