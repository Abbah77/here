import 'package:flutter/material.dart';

class FriendTile extends StatelessWidget {
  final Map<String, dynamic> friend;
  final ColorScheme colors;
  final VoidCallback onTap;
  final VoidCallback onMessage;
  final bool showOnlineStatus;

  const FriendTile({
    super.key,
    required this.friend,
    required this.colors,
    required this.onTap,
    required this.onMessage,
    this.showOnlineStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(friend['image']),
            ),
            if (showOnlineStatus && friend['isOnline'])
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
            if (friend['hasStory'])
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Text(
              friend['name'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            if (friend['isFavorite'])
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.star,
                  color: colors.primary,
                  size: 16,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              friend['username'],
              style: TextStyle(
                color: colors.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            if (friend['mutualFriends'] > 0)
              Text(
                '${friend['mutualFriends']} mutual friends',
                style: TextStyle(
                  color: colors.onSurface.withOpacity(0.4),
                  fontSize: 11,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (friend['isOnline'])
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Online',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Text(
                friend['lastActive'],
                style: TextStyle(
                  color: colors.onSurface.withOpacity(0.4),
                  fontSize: 11,
                ),
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.message_outlined, color: colors.primary),
              onPressed: onMessage,
              iconSize: 20,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}