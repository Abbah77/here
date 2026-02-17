import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/event.dart';
import 'package:here/providers/event_provider.dart';
import 'package:here/models/event.dart';

class Meetup extends StatefulWidget {
  const Meetup({super.key});

  @override
  State<Meetup> createState() => _MeetupState();
}

class _MeetupState extends State<Meetup> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load events once on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildCustomTabBar(),
          Expanded(
            child: Consumer<EventProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && !provider.hasEvents) {
                  return const Center(child: CircularProgressIndicator(color: Colors.orange));
                }
                if (provider.hasError && !provider.hasEvents) {
                  return _ErrorState(provider: provider);
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _EventList(status: EventStatus.upcoming),
                    _EventList(status: EventStatus.ongoing),
                    _EventList(status: EventStatus.past),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      title: Text('Explore Meetups', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 20)),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.orange),
          onPressed: () => _showComingSoon(context),
        ),
      ],
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      height: 45,
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(25)),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(25)),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Ongoing'), Tab(text: 'Past')],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feature coming soon!'), behavior: SnackBarBehavior.floating),
    );
  }
}

class _EventList extends StatelessWidget {
  final EventStatus status;
  const _EventList({required this.status});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        final events = provider.groupedEvents[status] ?? [];
        if (events.isEmpty) {
          return Center(child: Text('No ${status.name} events found', style: const TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: events.length,
          itemBuilder: (context, index) => EventCard(event: events[index]),
        );
      },
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // FIXED: Changed withValues to withOpacity
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventPage(event: event))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageHeader(event),
              _buildEventDetails(context, event),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageHeader(Event event) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Image.network(
          event.eventImage ?? event.organizerImage,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: event.statusColor, borderRadius: BorderRadius.circular(12)),
            child: Text(event.statusText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
        Positioned(
          bottom: -25,
          left: 20,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: CircleAvatar(radius: 28, backgroundImage: NetworkImage(event.organizerImage)),
          ),
        ),
      ],
    );
  }

  Widget _buildEventDetails(BuildContext context, Event event) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 35, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event.formattedDate.toUpperCase(), 
              style: GoogleFonts.plusJakartaSans(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(event.title, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Expanded(child: Text(event.location, style: TextStyle(color: Colors.grey[600], fontSize: 13))),
            ],
          ),
          const SizedBox(height: 16),
          _AttendeeRow(event: event),
          const SizedBox(height: 20),
          _AttendButton(event: event),
        ],
      ),
    );
  }
}

class _AttendeeRow extends StatelessWidget {
  final Event event;
  const _AttendeeRow({required this.event});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          height: 25,
          child: Stack(
            children: List.generate(
              event.attendeeImages.length.clamp(0, 3),
              (i) => Positioned(
                left: i * 14.0,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(radius: 10, backgroundImage: NetworkImage(event.attendeeImages[i])),
                ),
              ),
            ),
          ),
        ),
        Text('+${event.attendees} joining', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _AttendButton extends StatelessWidget {
  final Event event;
  const _AttendButton({required this.event});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: () => context.read<EventProvider>().toggleAttendance(event.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: event.isAttending ? Colors.grey[200] : Colors.orange,
          foregroundColor: event.isAttending ? Colors.black87 : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(event.isAttending ? 'Attending' : 'Join Meetup', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final EventProvider provider;
  const _ErrorState({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Failed to sync events'),
          TextButton(onPressed: () => provider.loadEvents(), child: const Text('Retry')),
        ],
      ),
    );
  }
}
