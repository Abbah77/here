import 'package:flutter/material.dart';

class FriendRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final ColorScheme colors;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onViewProfile;

  const FriendRequestCard({
    super.key,
    required this.request,
    required this.colors,
    required this.onAccept,
    required this.onDecline,
    required this.onViewProfile,
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
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(request['image']),
            ),
            title: Text(
              request['name'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            subtitle: Text(
              request['username'],
              style: TextStyle(
                color: colors.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            trailing: Text(
              request['timeAgo'],
              style: TextStyle(
                color: colors.onSurface.withOpacity(0.4),
                fontSize: 12,
              ),
            ),
            onTap: onViewProfile,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                // Mutual friends preview
                if (request['mutualFriends'] > 0)
                  Expanded(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          height: 24,
                          child: Stack(
                            children: List.generate(
                              request['mutualImages'].take(3).length,
                              (index) => Positioned(
                                left: index * 15.0,
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundImage: NetworkImage(request['mutualImages'][index]),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${request['mutualFriends']} mutual',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                // Action buttons
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.surfaceContainerHighest,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close, color: colors.onSurface),
                    onPressed: onDecline,
                    iconSize: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.check, color: Colors.white),
                    onPressed: onAccept,
                    iconSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}