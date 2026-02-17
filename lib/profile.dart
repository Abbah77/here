import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/auth_provider.dart';
import 'package:here/providers/post_provider.dart';
// FIXED: Ensured this matches your file structure
import 'package:here/widget/post_widget.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isEditingBio = false;
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final postProvider = Provider.of<PostProvider>(context);
    
    if (user == null) {
      return Scaffold(
        // FIXED: background -> surface
        backgroundColor: colors.surface, 
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 64,
                color: colors.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No user data',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final userPosts = postProvider.getPostsByUser(user.id);

    return Scaffold(
      // FIXED: background -> surface
      backgroundColor: colors.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280,
              floating: false,
              pinned: true,
              backgroundColor: colors.surface,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors.primary.withOpacity(0.1),
                        // FIXED: background -> surface
                        colors.surface, 
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(height: kToolbarHeight + 20),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.primary,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(user.profileImage),
                          onBackgroundImageError: (_, __) => Icon(
                            Icons.person,
                            size: 50,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: colors.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.settings_outlined,
                    color: colors.onSurface,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Container(
                color: colors.surface,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      colors,
                      value: user.posts.toString(),
                      label: 'Posts',
                    ),
                    _buildStatItem(
                      colors,
                      value: _formatCount(user.followers),
                      label: 'Followers',
                    ),
                    _buildStatItem(
                      colors,
                      value: _formatCount(user.following),
                      label: 'Following',
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: colors.surface,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bio',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                        if (!_isEditingBio)
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: colors.primary,
                            ),
                            onPressed: () {
                              setState(() {
                                _isEditingBio = true;
                                _bioController.text = user.bio;
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_isEditingBio)
                      Column(
                        children: [
                          TextField(
                            controller: _bioController,
                            maxLines: 3,
                            maxLength: 150,
                            style: TextStyle(color: colors.onSurface),
                            decoration: InputDecoration(
                              hintText: 'Write something about yourself...',
                              hintStyle: TextStyle(
                                color: colors.onSurface.withOpacity(0.5),
                              ),
                              filled: true,
                              // FIXED: surfaceContainerHighest -> surfaceVariant
                              fillColor: colors.surfaceVariant,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditingBio = false;
                                  });
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: colors.onSurface),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () async {
                                  final success = await authProvider.updateProfile(
                                    bio: _bioController.text,
                                  );
                                  if (success && mounted) {
                                    setState(() {
                                      _isEditingBio = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Bio updated!'),
                                        backgroundColor: colors.primary,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: colors.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      Text(
                        user.bio.isEmpty ? 'No bio yet' : user.bio,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: user.bio.isEmpty
                              ? colors.onSurface.withOpacity(0.4)
                              : colors.onSurface.withOpacity(0.8),
                          fontStyle: user.bio.isEmpty ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: colors.primary,
                  indicatorWeight: 3,
                  labelColor: colors.primary,
                  unselectedLabelColor: colors.onSurface.withOpacity(0.6),
                  tabs: const [
                    Tab(text: 'Posts'),
                    Tab(text: 'Saved'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            if (userPosts.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.post_add_outlined,
                      size: 64,
                      color: colors.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No posts yet',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: userPosts.length,
                itemBuilder: (context, index) {
                  // FIXED: This will now work because of the import at top
                  return PostWidget(post: userPosts[index]);
                },
              ),
            if (postProvider.getBookmarkedPosts().isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border_outlined,
                      size: 64,
                      color: colors.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No saved posts',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: postProvider.getBookmarkedPosts().length,
                itemBuilder: (context, index) {
                  return PostWidget(post: postProvider.getBookmarkedPosts()[index]);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(ColorScheme colors, {required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: colors.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}