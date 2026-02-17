import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/notification_provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _fade = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: const NotificationAppBar(),
      body: FadeTransition(
        opacity: _fade,
        child: Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.notifications.isEmpty) {
              return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange));
            }

            if (provider.status == NotificationStatus.error && provider.notifications.isEmpty) {
              return _ErrorView(provider: provider);
            }

            if (provider.notifications.isEmpty) return const NotificationEmptyState();

            final grouped = provider.groupedNotifications;

            return RefreshIndicator(
              onRefresh: () => provider.loadNotifications(refresh: true),
              edgeOffset: 20,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: grouped.length,
                itemBuilder: (context, index) {
                  final date = grouped.keys.elementAt(index);
                  final items = grouped[date]!;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DateHeader(date: date),
                      ...items.map((item) => _DismissibleTile(item: item, provider: provider)),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DismissibleTile extends StatelessWidget {
  final NotificationItem item;
  final NotificationProvider provider;

  const _DismissibleTile({required this.item, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.redAccent,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => provider.removeNotification(item.id),
      child: NotificationTile(
        item: item,
        onTap: () => provider.markAsRead(item.id),
      ),
    );
  }
}

class NotificationAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NotificationAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final int unread = context.select<NotificationProvider, int>((p) => p.unreadCount);

    return AppBar(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      centerTitle: false,
      title: Text('Activity', 
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          fontSize: 22,
        )),
      actions: [
        if (unread > 0)
          TextButton(
            onPressed: () => context.read<NotificationProvider>().markAllAsRead(),
            child: const Text('Mark all read', style: TextStyle(color: Colors.orange)),
          ),
        PopupMenuButton(
          icon: const Icon(Icons.more_horiz),
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () => context.read<NotificationProvider>().clearAll(),
              child: const Text('Clear all'),
            ),
          ],
        ),
      ],
    );
  }
}

// --- HELPER WIDGETS START HERE ---

class NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const NotificationTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.transparent : Colors.orange.withValues(alpha: 0.04),
          border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(item.userImage),
              onBackgroundImageError: (_, __) => const Icon(Icons.person),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.plusJakartaSans(color: Colors.black, fontSize: 14),
                      children: [
                        TextSpan(text: item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: ' '),
                        TextSpan(text: item.message, style: const TextStyle(color: Colors.black87)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(item.timeAgo, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            if (!item.isRead)
              const CircleAvatar(radius: 4, backgroundColor: Colors.orange),
          ],
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(date.toUpperCase(), 
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11, 
          letterSpacing: 1.2, 
          fontWeight: FontWeight.bold, 
          color: Colors.grey[500]
        )),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final NotificationProvider provider;
  const _ErrorView({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(provider.errorMessage ?? 'Something went wrong'),
          TextButton(onPressed: () => provider.loadNotifications(), child: const Text('Retry')),
        ],
      ),
    );
  }
}

class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('All caught up!', style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}
