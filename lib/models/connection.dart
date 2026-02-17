class Connection {
  final String id;
  final String name;
  final String role;
  final String? company;
  final String imageUrl;
  final bool isMutual;
  final bool isOnline;

  const Connection({
    required this.id,
    required this.name,
    required this.role,
    this.company,
    required this.imageUrl,
    this.isMutual = false,
    this.isOnline = false,
  });

  // ADD THIS GETTER: This fixes the "category isn't defined" errors in connections.dart
  String get category => role;

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      company: json['company'] as String?,
      imageUrl: json['imageUrl'] as String? ?? '',
      isMutual: json['isMutual'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'company': company,
      'imageUrl': imageUrl,
      'isMutual': isMutual,
      'isOnline': isOnline,
    };
  }
}
