import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String? speaker;
  final String? category;
  final int capacity;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.speaker,
    this.category,
    required this.capacity,
  });

  bool get isUpcoming => DateTime.now().isBefore(startTime);
  bool get isHappening => DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);
  bool get isFinished => DateTime.now().isAfter(endTime);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'speaker': speaker,
      'category': category,
      'capacity': capacity,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    DateTime parseDynamic(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      if (v is Timestamp) return v.toDate();
      if (v is String) return DateTime.parse(v);
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      // fallback
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    return Event(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      startTime: parseDynamic(json['startTime']),
      endTime: parseDynamic(json['endTime']),
      location: json['location']?.toString() ?? '',
      speaker: json['speaker']?.toString(),
      category: json['category']?.toString(),
      capacity: json['capacity'] is int ? json['capacity'] as int : int.tryParse(json['capacity']?.toString() ?? '') ?? 0,
    );
  }
}
