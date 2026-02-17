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
    final colors = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, colors),
          const SizedBox(height: 12),
          _buildContent(context, colors),
          if (showActions) ...[
            const SizedBox(height: 16),
            _buildActions(context, colors),
          ],
          Divider(
            height: 32, 
            thickness: 0.5, 
            indent: 20, 
            endIndent: 20,
            color: colors.outline,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        children: [
          _buildUserAvatar(colors),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.userName,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16, 
                    color: colors.onSurface,
                  ),
                ),
                Text(
                  post.timeAgo,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, 
                    color: colors.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          if (post.type == PostType.connection || post.type == PostType.checkIn)
            Icon(
              Icons.hub_outlined, 
              color: colors.primary, 
              size: 22,
            ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.primary.withOpacity(0.2), 
          width: 2,
        ),
      ),
      child: CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(post.userProfileImage),
        onBackgroundImageError: (_, __) => Icon(
          Icons.person, 
          color: colors.onSurface,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colors) {
    return switch (post.type) {
      PostType.text => _buildTextContent(colors),
      PostType.image => _buildImageContent(colors),
      PostType.multiImage => _buildMultiImageContent(colors),
      PostType.video => _buildVideoContent(colors),
      PostType.link => _buildLinkContent(colors),
      PostType.checkIn => _buildCheckInContent(context, colors),
      PostType.connection => _buildConnectionContent(colors),
    };
  }

  Widget _buildTextContent(ColorScheme colors) {
    if (post.content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        post.content,
        style: GoogleFonts.lato(
          color: colors.onSurface.withOpacity(0.8), 
          fontSize: 15, 
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildImageContent(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextContent(colors),
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

  Widget _buildMultiImageContent(ColorScheme colors) {
    final images = post.imageUrls ?? [];
    if (images.isEmpty) return _buildTextContent(colors);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextContent(colors),
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

  Widget _buildVideoContent(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextContent(colors),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  post.imageUrl ?? '',
                  height: 220, 
                  width: double.infinity, 
                  fit: BoxFit.cover,
                ),
              ),
              CircleAvatar(
                backgroundColor: colors.onSurface.withOpacity(0.6),
                radius: 30,
                child: Icon(
                  Icons.play_arrow, 
                  color: colors.surface, 
                  size: 40,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinkContent(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextContent(colors),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              children: [
                if (post.imageUrl != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      post.imageUrl!,
                      height: 140, 
                      width: double.infinity, 
                      fit: BoxFit.cover,
                    ),
                  ),
                ListTile(
                  title: Text(
                    post.metadata?['title'] ?? 'Link Preview',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    post.metadata?['link'] ?? '',
                    style: TextStyle(
                      color: colors.primary, 
                      fontSize: 12,
                    ),
                  ),
                  trailing: Icon(
                    Icons.open_in_new, 
                    size: 18,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInContent(BuildContext context, ColorScheme colors) {
    final location = post.metadata?['location'] as LatLng?;
    return Column(
      children: [
        _buildTextContent(colors),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
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
                      : Container(
                          color: colors.surfaceContainerHighest,
                        ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Center(
                  child: Text(
                    'Join Meetup',
                    style: TextStyle(
                      color: colors.onPrimary, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionContent(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        color: colors.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(post.metadata?['contactImage'] ?? ''),
                onBackgroundImageError: (_, __) => Icon(
                  Icons.person,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.metadata?['contactName'] ?? 'Contact',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 16,
                        color: colors.onSurface,
                      ),
                    ),
                    Text(
                      post.metadata?['contactTitle'] ?? '',
                      style: TextStyle(
                        color: colors.onSurface.withOpacity(0.6), 
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.person_add_alt_1, 
                color: colors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, ColorScheme colors) {
    return Consumer<PostProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _ActionButton(
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                label: '${post.likes}',
                color: post.isLiked ? colors.primary : colors.onSurface.withOpacity(0.6),
                onTap: () => provider.toggleLike(post.id),
              ),
              const SizedBox(width: 24),
              _ActionButton(
                icon: Icons.chat_bubble_outline,
                label: '${post.comments}',
                color: colors.onSurface.withOpacity(0.6),
                onTap: () {
                  // TODO: Navigate to comments
                },
              ),
              const Spacer(),
              Icon(
                Icons.share_outlined, 
                color: colors.onSurface.withOpacity(0.6), 
                size: 20,
              ),
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
    final colors = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: colors.onSurface.withOpacity(0.7), 
              fontWeight: FontWeight.bold, 
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}