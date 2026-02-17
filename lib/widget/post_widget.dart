import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/models/post.dart';
import 'package:here/models/post_type.dart';
import 'package:here/providers/post_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PostWidget extends StatelessWidget {
  final Post post;
  final bool showActions;

  const PostWidget({
    super.key,
    required this.post,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          _buildContent(context),
          if (showActions) ...[
            const SizedBox(height: 16),
            _buildActions(context),
          ],
          const Divider(height: 32, thickness: 0.5, indent: 20, endIndent: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        children: [
          _buildUserAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.userName,
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800])),
                Text(post.timeAgo,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[500])),
              ],
            ),
          ),
          if (post.type == PostType.connection || post.type == PostType.checkIn)
            const Icon(Icons.hub_outlined, color: Colors.orange, size: 22),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2), width: 2),
      ),
      child: CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(post.userProfileImage),
        onBackgroundImageError: (_, __) => const Icon(Icons.person),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // Exhaustive switch: No default case needed if all PostTypes are handled
    return switch (post.type) {
      PostType.text => _buildTextContent(),
      PostType.image => _buildImageContent(),
      PostType.multiImage => _buildMultiImageContent(),
      PostType.video => _buildVideoContent(),
      PostType.link => _buildLinkContent(),
      PostType.checkIn => _buildCheckInContent(context),
      PostType.connection => _buildConnectionContent(),
    };
  }

  Widget _buildTextContent() {
    if (post.content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        post.content,
        style: GoogleFonts.lato(color: Colors.grey[700], fontSize: 15, height: 1.5),
      ),
    );
  }

  Widget _buildImageContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextContent(),
        if (post.hasImage) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                post.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 250,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMultiImageContent() {
    final images = post.imageUrls ?? [];
    if (images.isEmpty) return _buildTextContent();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextContent(),
        const SizedBox(height: 12),
        Container(
          height: 280,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildRoundedImage(images[0], isLeft: true),
              ),
              if (images.length > 1) ...[
                const SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(child: _buildRoundedImage(images[1], isTopRight: true)),
                      const SizedBox(height: 4),
                      Expanded(
                        child: images.length > 2
                            ? _buildRoundedImage(images[2], isBottomRight: true)
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoundedImage(String url,
      {bool isLeft = false, bool isTopRight = false, bool isBottomRight = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(isLeft ? 16 : 0),
        bottomLeft: Radius.circular(isLeft ? 16 : 0),
        topRight: Radius.circular(isTopRight ? 16 : 0),
        bottomRight: Radius.circular(isBottomRight ? 16 : 0),
      ),
      child: Image.network(url, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
    );
  }

  Widget _buildVideoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextContent(),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(post.imageUrl ?? '',
                    height: 220, width: double.infinity, fit: BoxFit.cover),
              ),
              CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.4),
                radius: 30,
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinkContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextContent(),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                if (post.imageUrl != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(post.imageUrl!,
                        height: 140, width: double.infinity, fit: BoxFit.cover),
                  ),
                ListTile(
                  title: Text(post.metadata?['title'] ?? 'Link Preview',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(post.metadata?['link'] ?? '',
                      style: const TextStyle(color: Colors.blue, fontSize: 12)),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInContent(BuildContext context) {
    final location = post.metadata?['location'] as LatLng?;
    return Column(
      children: [
        _buildTextContent(),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: location != null
                      ? FlutterMap(
                          options: MapOptions(initialCenter: location, initialZoom: 14),
                          children: [
                            TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                          ],
                        )
                      : Container(color: Colors.grey[200]),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: const Center(
                  child: Text('Join Meetup',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(post.metadata?['contactImage'] ?? '')),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.metadata?['contactName'] ?? 'Contact',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(post.metadata?['contactTitle'] ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.person_add_alt_1, color: Colors.orange),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _ActionButton(
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                label: '${post.likes}',
                color: post.isLiked ? Colors.orange : Colors.grey,
                onTap: () => provider.toggleLike(post.id),
              ),
              const SizedBox(width: 24),
              _ActionButton(
                icon: Icons.chat_bubble_outline,
                label: '${post.comments}',
                color: Colors.grey,
                onTap: () {},
              ),
              const Spacer(),
              const Icon(Icons.share_outlined, color: Colors.grey, size: 20),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
