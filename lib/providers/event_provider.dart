import 'package:flutter/material.dart';
import 'package:here/models/event.dart'; // Ensure this path is correct
import 'package:latlong2/latlong.dart';

/// Renamed to ProviderStatus to avoid conflict with EventStatus in models/event.dart
enum ProviderStatus { initial, loading, loaded, error }

class EventProvider with ChangeNotifier {
  List<Event> _events = [];
  ProviderStatus _status = ProviderStatus.initial;
  String? _errorMessage;
  String _searchQuery = '';
  
  // This now correctly refers to the EventStatus enum from your model
  EventStatus? _filterStatus;

  // Getters
  List<Event> get events => List.unmodifiable(_events);
  ProviderStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ProviderStatus.loading;
  bool get hasError => _status == ProviderStatus.error;
  bool get hasEvents => _events.isNotEmpty;

  // Filtered events based on search and status
  List<Event> get filteredEvents {
    return _events.where((event) {
      final matchesSearch = _searchQuery.isEmpty ||
          event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.organizer.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.location.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesStatus = _filterStatus == null || event.status == _filterStatus;
      
      return matchesSearch && matchesStatus;
    }).toList();
  }

  // Group events by status
  Map<EventStatus, List<Event>> get groupedEvents {
    final Map<EventStatus, List<Event>> grouped = {};
    for (var event in filteredEvents) {
      grouped.putIfAbsent(event.status, () => []).add(event);
    }
    return grouped;
  }

  // Load events
  Future<void> loadEvents() async {
    _updateStatus(ProviderStatus.loading);

    try {
      await Future.delayed(const Duration(seconds: 1));
      _events = List.from(_mockEvents);
      _updateStatus(ProviderStatus.loaded);
    } catch (e) {
      _updateStatus(
        ProviderStatus.error,
        errorMessage: 'Failed to load events: $e',
      );
    }
  }

  // Search
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Filter by event status (upcoming/past)
  void setFilter(EventStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterStatus = null;
    notifyListeners();
  }

  void toggleAttendance(String eventId) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final event = _events[index];
      final newAttending = !event.isAttending;
      
      _events[index] = event.copyWith(
        isAttending: newAttending,
        attendees: newAttending ? event.attendees + 1 : event.attendees - 1,
      );
      notifyListeners();
    }
  }

  Event? getEventById(String eventId) {
    try {
      return _events.firstWhere((e) => e.id == eventId);
    } catch (e) {
      return null;
    }
  }

  List<Event> getUpcomingEvents() {
    return _events.where((e) => e.status == EventStatus.upcoming).toList();
  }

  void _updateStatus(ProviderStatus status, {String? errorMessage}) {
    _status = status;
    if (errorMessage != null) {
      _errorMessage = errorMessage;
    }
    notifyListeners();
  }

  void clearError() {
    if (_status == ProviderStatus.error) {
      _updateStatus(ProviderStatus.loaded, errorMessage: null);
    }
  }

  // Mock data moved below for clarity
  static final List<Event> _mockEvents = [
    Event(
      id: '1',
      title: 'Atlassian Open 2019',
      organizer: 'Sabin',
      organizerImage: 'https://images.pexels.com/photos/3767673/pexels-photo-3767673.jpeg',
      eventImage: 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
      dateTime: DateTime.now().add(const Duration(days: 2, hours: 9)),
      location: 'Sydney, Australia',
      coordinates: const LatLng(-33.8688, 151.2093),
      description: 'Join us for the annual Atlassian Open conference.',
      attendees: 5,
      maxAttendees: 50,
      attendeeImages: [
        'https://i.insider.com/5c9a115d8e436a63e42c2883',
        'https://play-images-prod-cms.tech.tvnz.co.nz/api/v1/web/image/content/dam/images/entertainment/shows/p/person-of-interest/personofinterest_coverimg.png',
      ],
      attendeeNames: ['Alan Mathew', 'Sarah Chen'],
      status: EventStatus.upcoming,
      tags: ['#Tech', '#Conference'],
    ),
    Event(
      id: '2',
      title: 'Flutter I/O',
      organizer: 'Google',
      organizerImage: 'https://images.pexels.com/photos/3767673/pexels-photo-3767673.jpeg',
      eventImage: 'https://images.pexels.com/photos/1470165/pexels-photo-1470165.jpeg',
      dateTime: DateTime.now().add(const Duration(days: 5, hours: 14)),
      location: 'San Francisco, CA',
      coordinates: const LatLng(37.7749, -122.4194),
      description: 'Flutter I/O is the premier event for Flutter developers.',
      attendees: 5,
      maxAttendees: 100,
      attendeeImages: [
        'https://i.insider.com/5c9a115d8e436a63e42c2883',
        'https://play-images-prod-cms.tech.tvnz.co.nz/api/v1/web/image/content/dam/images/entertainment/shows/p/person-of-interest/personofinterest_coverimg.png',
      ],
      attendeeNames: ['Alan Mathew', 'Sarah Chen'],
      status: EventStatus.upcoming,
      tags: ['#Tech', '#Flutter'],
    ),
    Event(
      id: '3',
      title: 'Design Summit 2024',
      organizer: 'Design Community',
      organizerImage: 'https://images.pexels.com/photos/6186/vintage-mockup-old-logo.jpg',
      eventImage: 'https://images.pexels.com/photos/569996/pexels-photo-569996.jpeg',
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      location: 'New York, NY',
      coordinates: const LatLng(40.7128, -74.0060),
      description: 'A gathering of the best designers.',
      attendees: 45,
      maxAttendees: 50,
      attendeeImages: [
        'https://i.insider.com/5c9a115d8e436a63e42c2883',
        'https://play-images-prod-cms.tech.tvnz.co.nz/api/v1/web/image/content/dam/images/entertainment/shows/p/person-of-interest/personofinterest_coverimg.png',
      ],
      attendeeNames: ['Alan Mathew', 'Sarah Chen'],
      status: EventStatus.past,
      tags: ['#Design', '#Creative'],
    ),
  ];
}