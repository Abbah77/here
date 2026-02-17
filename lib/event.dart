import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/event_provider.dart';
import 'package:here/models/event.dart';

class EventPage extends StatefulWidget {
  final Event event;
  const EventPage({super.key, required this.event});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventCoord = widget.event.coordinates ?? const LatLng(45.5231, -122.6765);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Map Layer
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: eventCoord, // FIXED: center -> initialCenter
                initialZoom: 14.0,         // FIXED: zoom -> initialZoom
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: eventCoord,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.orange, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Back Button
          Positioned(
            top: 50,
            left: 18,
            child: _CircleIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // 3. Details Bottom Sheet
          SlideTransition(
            position: _slideAnimation,
            child: DraggableScrollableSheet(
              initialChildSize: 0.55,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return _EventDetailsSheet(
                  event: widget.event,
                  scrollController: scrollController,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EventDetailsSheet extends StatelessWidget {
  final Event event;
  final ScrollController scrollController;

  const _EventDetailsSheet({required this.event, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        children: [
          Center(child: _DragHandle()),
          const SizedBox(height: 16),
          Text(event.title, style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _OrganizerTile(event: event),
          const Divider(height: 48),
          _InfoRow(icon: Icons.calendar_today, title: 'Date & Time', subtitle: event.formattedDate),
          const SizedBox(height: 20),
          _InfoRow(icon: Icons.location_on, title: 'Location', subtitle: event.location),
          const SizedBox(height: 20),
          _InfoRow(icon: Icons.people, title: 'Attendees', subtitle: '${event.attendees} attending'),
          const SizedBox(height: 32),
          Text('About', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(event.description, style: TextStyle(color: Colors.grey[700], height: 1.6)),
          const SizedBox(height: 40),
          _ActionButtonsRow(event: event),
        ],
      ),
    );
  }
}

// --- Sub-widgets for clarity ---

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)], // FIXED: withOpacity
      ),
      child: IconButton(onPressed: onPressed, icon: Icon(icon, size: 20)),
    );
  }
}

class _OrganizerTile extends StatelessWidget {
  final Event event;
  const _OrganizerTile({required this.event});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 24, backgroundImage: NetworkImage(event.organizerImage)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Organized by', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text(event.organizer, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ],
    );
  }
}

class _ActionButtonsRow extends StatelessWidget {
  final Event event;
  const _ActionButtonsRow({required this.event});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Share',
            icon: Icons.share_outlined,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Consumer<EventProvider>(
            builder: (context, provider, _) => _ActionButton(
              label: event.isAttending ? 'Attending' : 'Join Event',
              icon: event.isAttending ? Icons.check_circle : Icons.add_circle_outline,
              backgroundColor: Colors.orange,
              textColor: Colors.white,
              onTap: () => provider.toggleAttendance(event.id),
            ),
          ),
        ),
      ],
    );
  }
}

// Internal reusable components
class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)));
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _InfoRow({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: Colors.orange, size: 20)),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor, textColor;

  const _ActionButton({required this.label, required this.icon, required this.onTap, this.backgroundColor, this.textColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.grey[100],
        foregroundColor: textColor ?? Colors.black87,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
