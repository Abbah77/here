import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';

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
          _buildHeader(colors),
          const SizedBox(height: 12),
          _buildContent(colors),
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

  Widget _buildHeader(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(post.userProfileImage),
            onBackgroundImageError: (_, __) => Icon(Icons.person, color: colors.onSurface),
          ),
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
        ],
      ),
    );
  }

  Widget _buildContent(ColorScheme colors) {
    if (post.content.isEmpty && (post.imageUrl == null && post.imageUrls == null)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              post.content,
              style: GoogleFonts.lato(color: colors.onSurface.withOpacity(0.8), fontSize: 15, height: 1.5),
            ),
          ),
        if (post.imageUrl != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(post.imageUrl!, fit: BoxFit.cover),
            ),
          ),
        if (post.imageUrls != null && post.imageUrls!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            child: _buildMultiImage(post.imageUrls!, colors),
          ),
      ],
    );
  }

  Widget _buildMultiImage(List<String> images, ColorScheme colors) {
    if (images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 280,
      child: Row(
        children: [
          Expanded(flex: 3, child: _buildRoundedImage(images[0], isLeft: true)),
          if (images.length > 1) ...[
            const SizedBox(width: 4),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(child: _buildRoundedImage(images[1], isTopRight: true)),
                  const SizedBox(height: 4),
                  Expanded(
                    child: images.length > 2 ? _buildRoundedImage(images[2], isBottomRight: true) : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoundedImage(String url, {bool isLeft = false, bool isTopRight = false, bool isBottomRight = false}) {
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
                onTap: () {},
              ),
              const Spacer(),
              Icon(Icons.share_outlined, color: colors.onSurface.withOpacity(0.6), size: 20),
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
          Text(label, style: TextStyle(color: colors.onSurface.withOpacity(0.7), fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}