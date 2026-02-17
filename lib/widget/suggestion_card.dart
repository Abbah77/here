import 'package:flutter/material.dart';

class SuggestionCard extends StatelessWidget {
  final Map<String, dynamic> suggestion;
  final ColorScheme colors;
  final VoidCallback onAddFriend;
  final VoidCallback onRemove;

  const SuggestionCard({
    super.key,
    required this.suggestion,
    required this.colors,
    required this.onAddFriend,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Profile image with verification badge
            Stack(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(suggestion['image']),
                ),
                if (suggestion['isVerified'])
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    suggestion['username'],
                    style: TextStyle(
                      color: colors.onSurface.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Mutual friends preview
                  Row(
                    children: [
                      SizedBox(
                        width: 50,
                        height: 20,
                        child: Stack(
                          children: List.generate(
                            suggestion['mutualImages'].take(3).length,
                            (index) => Positioned(
                              left: index * 12.0,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundImage: NetworkImage(suggestion['mutualImages'][index]),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${suggestion['mutualFriends']} mutual',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    suggestion['reason'],
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Action buttons
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.surfaceContainerHighest,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close, color: colors.onSurface, size: 18),
                    onPressed: onRemove,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.person_add, color: Colors.white, size: 18),
                    onPressed: onAddFriend,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}