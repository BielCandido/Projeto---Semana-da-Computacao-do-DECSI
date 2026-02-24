import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semana_computacao/models/event.dart';

void main() {
  group('Event', () {
    group('fromJson', () {
      test('parses event from ISO 8601 date strings', () {
        final json = {
          'id': 'event-1',
          'title': 'Flutter Workshop',
          'description': 'Learn Flutter',
          'startTime': '2026-03-19T14:00:00.000',
          'endTime': '2026-03-19T16:00:00.000',
          'location': 'Room 101',
          'speaker': 'Dr. Smith',
          'category': 'Workshop',
          'capacity': 30,
        };

        final event = Event.fromJson(json);

        expect(event.id, 'event-1');
        expect(event.title, 'Flutter Workshop');
        expect(event.description, 'Learn Flutter');
        expect(event.location, 'Room 101');
        expect(event.speaker, 'Dr. Smith');
        expect(event.category, 'Workshop');
        expect(event.capacity, 30);
        expect(event.startTime.year, 2026);
        expect(event.startTime.month, 3);
        expect(event.startTime.day, 19);
        expect(event.endTime.hour, 16);
      });

      test('parses event from Firestore Timestamp', () {
        final now = DateTime.now();
        final timestamp = Timestamp.fromDate(now);

        final json = {
          'id': 'event-2',
          'title': 'Seminar',
          'description': 'Tech Seminar',
          'startTime': timestamp,
          'endTime': timestamp.toDate().add(const Duration(hours: 2)),
          'location': 'Auditorium',
          'capacity': 50,
        };

        final event = Event.fromJson(json);

        expect(event.id, 'event-2');
        expect(event.title, 'Seminar');
        expect(event.startTime.day, now.day);
        expect(event.capacity, 50);
      });

      test('parses event with integer milliseconds for dates', () {
        final now = DateTime.now();
        final startMs = now.millisecondsSinceEpoch;
        final endMs = now.add(const Duration(hours: 1)).millisecondsSinceEpoch;

        final json = {
          'id': 'event-3',
          'title': 'Int Milliseconds Test',
          'description': 'Test',
          'startTime': startMs,
          'endTime': endMs,
          'location': 'Lab',
          'capacity': 20,
        };

        final event = Event.fromJson(json);

        expect(event.id, 'event-3');
        expect(event.startTime.millisecondsSinceEpoch, startMs);
      });

      test('handles DateTime objects directly', () {
        final now = DateTime.now();
        final later = now.add(const Duration(hours: 1));

        final json = {
          'id': 'event-4',
          'title': 'DateTime Test',
          'description': 'Direct DateTime',
          'startTime': now,
          'endTime': later,
          'location': 'Office',
          'capacity': 10,
        };

        final event = Event.fromJson(json);

        expect(event.id, 'event-4');
        expect(event.startTime.isAtSameMomentAs(now), true);
        expect(event.endTime.isAtSameMomentAs(later), true);
      });

      test('handles null speaker and category gracefully', () {
        final json = {
          'id': 'event-5',
          'title': 'Minimal Event',
          'description': 'No speaker/category',
          'startTime': '2026-03-20T10:00:00.000',
          'endTime': '2026-03-20T11:00:00.000',
          'location': 'Room',
          'speaker': null,
          'category': null,
          'capacity': 15,
        };

        final event = Event.fromJson(json);

        expect(event.speaker, null);
        expect(event.category, null);
        expect(event.title, 'Minimal Event');
      });

      test('coerces string capacity to int', () {
        final json = {
          'id': 'event-6',
          'title': 'String Capacity',
          'description': 'Test coercion',
          'startTime': '2026-03-21T09:00:00.000',
          'endTime': '2026-03-21T10:00:00.000',
          'location': 'Lab',
          'capacity': '25',
        };

        final event = Event.fromJson(json);

        expect(event.capacity, 25);
        expect(event.capacity is int, true);
      });

      test('defaults to empty/zero for missing fields', () {
        final json = {
          'startTime': '2026-03-22T08:00:00.000',
          'endTime': '2026-03-22T09:00:00.000',
        };

        final event = Event.fromJson(json);

        expect(event.id, '');
        expect(event.title, '');
        expect(event.description, '');
        expect(event.location, '');
        expect(event.speaker, null);
        expect(event.category, null);
        expect(event.capacity, 0);
      });

      test('preserves all data in round-trip (toJson -> fromJson)', () {
        final now = DateTime(2026, 3, 19, 14, 30);
        final endTime = now.add(const Duration(hours: 2));

        final original = Event(
          id: 'event-round-trip',
          title: 'Round Trip Test',
          description: 'Testing serialization',
          startTime: now,
          endTime: endTime,
          location: 'Conference Room',
          speaker: 'Dr. Jane Doe',
          category: 'Presentation',
          capacity: 75,
        );

        final json = original.toJson();
        final reconstructed = Event.fromJson(json);

        expect(reconstructed.id, original.id);
        expect(reconstructed.title, original.title);
        expect(reconstructed.description, original.description);
        expect(reconstructed.location, original.location);
        expect(reconstructed.speaker, original.speaker);
        expect(reconstructed.category, original.category);
        expect(reconstructed.capacity, original.capacity);
        // Dates are ISO strings, so compare year/month/day/hour/minute
        expect(reconstructed.startTime.year, original.startTime.year);
        expect(reconstructed.startTime.month, original.startTime.month);
        expect(reconstructed.startTime.day, original.startTime.day);
        expect(reconstructed.startTime.hour, original.startTime.hour);
        expect(reconstructed.startTime.minute, original.startTime.minute);
      });
    });

    group('Event status getters', () {
      test('isUpcoming returns true for future events', () {
        final future = DateTime.now().add(const Duration(hours: 2));
        final event = Event(
          id: '1',
          title: 'Future Event',
          description: 'Later',
          startTime: future,
          endTime: future.add(const Duration(hours: 1)),
          location: 'Room',
          capacity: 20,
        );

        expect(event.isUpcoming, true);
        expect(event.isHappening, false);
        expect(event.isFinished, false);
      });

      test('isHappening returns true for ongoing events', () {
        final past = DateTime.now().subtract(const Duration(minutes: 30));
        final future = DateTime.now().add(const Duration(minutes: 30));
        final event = Event(
          id: '1',
          title: 'Happening Now',
          description: 'Currently',
          startTime: past,
          endTime: future,
          location: 'Room',
          capacity: 20,
        );

        expect(event.isUpcoming, false);
        expect(event.isHappening, true);
        expect(event.isFinished, false);
      });

      test('isFinished returns true for past events', () {
        final past = DateTime.now().subtract(const Duration(hours: 2));
        final event = Event(
          id: '1',
          title: 'Past Event',
          description: 'Already finished',
          startTime: past.subtract(const Duration(hours: 1)),
          endTime: past,
          location: 'Room',
          capacity: 20,
        );

        expect(event.isUpcoming, false);
        expect(event.isHappening, false);
        expect(event.isFinished, true);
      });
    });

    group('Event toJson', () {
      test('converts DateTime to ISO 8601 strings', () {
        final time = DateTime(2026, 3, 19, 14, 30);
        final event = Event(
          id: 'iso-test',
          title: 'ISO Test',
          description: 'Test',
          startTime: time,
          endTime: time.add(const Duration(hours: 1)),
          location: 'Room',
          capacity: 30,
        );

        final json = event.toJson();

        expect(json['startTime'], isA<String>());
        expect(json['endTime'], isA<String>());
        expect(json['startTime'], contains('2026-03-19'));
      });

      test('handles null speaker and category in toJson', () {
        final event = Event(
          id: 'null-test',
          title: 'Null Test',
          description: 'Test',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          location: 'Room',
          speaker: null,
          category: null,
          capacity: 20,
        );

        final json = event.toJson();

        expect(json['speaker'], null);
        expect(json['category'], null);
      });
    });
  });
}
