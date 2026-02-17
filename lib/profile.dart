import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:provider/provider.dart';
import 'package:here/profiledetails.dart';
import 'package:here/providers/auth_provider.dart';
import 'package:here/models/connection.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const _ProfileAppBar(),
      body: FadeTransition(
        opacity: _fade,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const _BioSection(),
              const SizedBox(height: 10),
              const _ConnectionsSection(),
              const SizedBox(height: 20),
              const _SoundBytesSection(),
              const SizedBox(height: 20),
              const _ActivityTimeline(),
              const SizedBox(height: 30),
              _buildNavigateButton(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigateButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const ProfileDetails())
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 45),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child: Text(
          'My Profile Details', 
          style: GoogleFonts.averageSans(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ProfileAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final userName = context.select<AuthProvider, String?>(
      (auth) => auth.currentUser?.name
    ) ?? 'User';

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Text(
        userName, 
        style: GoogleFonts.lato(
          color: Colors.grey[700], 
          fontSize: 15, 
          letterSpacing: 1,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.logout_rounded, color: Colors.grey[700], size: 20),
          onPressed: () => _confirmLogout(context),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), 
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
    if (result == true) await auth.signOut();
  }
}

class _BioSection extends StatelessWidget {
  const _BioSection();

  @override
  Widget build(BuildContext context) {
    final bio = context.select<AuthProvider, String?>(
      (auth) => auth.currentUser?.bio
    );
    
    return Padding(
      padding: const EdgeInsets.all(22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_giftcard, color: Colors.blue[600], size: 20),
              const SizedBox(width: 12),
              Text(
                'Bio', 
                style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bio ?? 'Innovation lead and digital transformation expert. Technical advisor for frontend development.',
            style: GoogleFonts.lato(color: Colors.grey[700], fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _ConnectionsSection extends StatelessWidget {
  const _ConnectionsSection();

  @override
  Widget build(BuildContext context) {
    // FIX: Added the required 'role' parameter to satisfy the Connection model
    final List<Connection> mockConnections = [
      const Connection(
        id: '1', 
        name: 'Amy Patterson', 
        role: 'Software Engineer', 
        imageUrl: 'https://i.pravatar.cc/150?u=amy', 
        isMutual: true,
      ),
      const Connection(
        id: '2', 
        name: 'Buttle Benzos', 
        role: 'Product Manager', 
        imageUrl: 'https://i.pravatar.cc/150?u=buttle', 
        isMutual: true,
      ),
      const Connection(
        id: '3', 
        name: 'Sarah Johnson', 
        role: 'UX Designer', 
        imageUrl: 'https://i.pravatar.cc/150?u=sarah', 
        isMutual: true,
      ),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Connections', 
                style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '${mockConnections.length} mutual', 
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 110,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            scrollDirection: Axis.horizontal,
            itemCount: mockConnections.length,
            separatorBuilder: (_, __) => const SizedBox(width: 15),
            itemBuilder: (context, index) {
              final conn = mockConnections[index];
              return Column(
                children: [
                  CircleAvatar(radius: 35, backgroundImage: NetworkImage(conn.imageUrl)),
                  const SizedBox(height: 8),
                  Text(conn.name.split(' ')[0], style: const TextStyle(fontSize: 12)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SoundBytesSection extends StatelessWidget {
  const _SoundBytesSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mic_none_rounded, color: Colors.orange[400]),
              const SizedBox(width: 10),
              Text(
                'Sound Bytes', 
                style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _SoundByteCard(title: 'Tips For Bloggers Pro', category: 'Advice', date: 'Oct 6'),
          const SizedBox(height: 12),
          const _SoundByteCard(title: 'New Video For Editors', category: 'Pro Tip', date: 'Oct 8'),
        ],
      ),
    );
  }
}

class _SoundByteCard extends StatelessWidget {
  final String title, category, date;
  const _SoundByteCard({required this.title, required this.category, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category, 
                        style: const TextStyle(color: Colors.orange, fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(date, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const CircleAvatar(
            backgroundColor: Colors.orange,
            child: Icon(Icons.play_arrow, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ActivityTimeline extends StatelessWidget {
  const _ActivityTimeline();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Text(
            'My Activity', 
            style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            children: const [
              _TimelineNode(isFirst: true, color: Colors.orange),
              _TimelineNode(color: Colors.pinkAccent),
              _TimelineNode(isLast: true, color: Colors.purple),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineNode extends StatelessWidget {
  final bool isFirst, isLast;
  final Color color;
  const _TimelineNode({this.isFirst = false, this.isLast = false, required this.color});

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      axis: TimelineAxis.horizontal,
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(width: 20, color: color),
      beforeLineStyle: LineStyle(color: color, thickness: 2),
      endChild: Container(
        margin: const EdgeInsets.only(left: 10, right: 20),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          image: const DecorationImage(
            image: NetworkImage('https://i.pravatar.cc/100'), 
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}