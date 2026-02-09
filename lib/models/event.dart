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
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      location: json['location'],
      speaker: json['speaker'],
      category: json['category'],
      capacity: json['capacity'],
    );
  }
}
