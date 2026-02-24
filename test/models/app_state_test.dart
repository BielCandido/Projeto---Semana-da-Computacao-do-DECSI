import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:semana_computacao/models/app_state.dart';
import 'package:semana_computacao/models/participant.dart';
import 'package:semana_computacao/models/event.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('AppState', () {
    late AppState appState;

    setUp(() {
      appState = AppState();
    });

    group('Check-in & Check-out', () {
      test('checkIn sets participant and marks as checked in', () {
        final participant = Participant(
          id: '1',
          name: 'John Doe',
          email: 'john@example.com',
          institution: 'UFMG',
          checkInTime: DateTime.now(),
        );

        appState.checkIn(participant);

        expect(appState.isCheckedIn, true);
        expect(appState.currentParticipant, participant);
        expect(appState.currentParticipant?.name, 'John Doe');
      });

      test('checkOut clears participant and marks as not checked in', () {
        final participant = Participant(
          id: '1',
          name: 'John Doe',
          email: 'john@example.com',
          institution: 'UFMG',
          checkInTime: DateTime.now(),
        );

        appState.checkIn(participant);
        expect(appState.isCheckedIn, true);

        appState.checkOut();

        expect(appState.isCheckedIn, false);
        expect(appState.currentParticipant, null);
      });
    });

    group('Event Management', () {
      test('addEvent adds event to events list', () {
        final event = Event(
          id: '1',
          title: 'Flutter Workshop',
          description: 'Learn Flutter basics',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 2)),
          location: 'Room 101',
          capacity: 30,
        );

        appState.addEvent(event);

        expect(appState.events.length, 1);
        expect(appState.events[0].title, 'Flutter Workshop');
      });

      test('addEvent with multiple events stores all', () {
        final event1 = Event(
          id: '1',
          title: 'Event 1',
          description: 'Description',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          location: 'Room 1',
          capacity: 20,
        );

        final event2 = Event(
          id: '2',
          title: 'Event 2',
          description: 'Description',
          startTime: DateTime.now().add(const Duration(hours: 3)),
          endTime: DateTime.now().add(const Duration(hours: 4)),
          location: 'Room 2',
          capacity: 25,
        );

        appState.addEvent(event1);
        appState.addEvent(event2);

        expect(appState.events.length, 2);
        expect(appState.events[1].id, '2');
      });

      test('removeEvent removes event from list', () {
        final event = Event(
          id: '1',
          title: 'Event to Remove',
          description: 'Description',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          location: 'Room 1',
          capacity: 20,
        );

        appState.addEvent(event);
        expect(appState.events.length, 1);

        appState.removeEvent(event);

        expect(appState.events.length, 0);
      });
    });

    group('Personalized Schedule', () {
      test('addToSchedule adds event to personalized schedule', () {
        final event = Event(
          id: '1',
          title: 'My Event',
          description: 'Description',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          location: 'Room 1',
          capacity: 20,
        );

        appState.addToSchedule(event);

        expect(appState.personalizedSchedule.length, 1);
        expect(appState.personalizedSchedule[0].id, '1');
      });

      test('addToSchedule does not add duplicate events', () {
        final event = Event(
          id: '1',
          title: 'Event',
          description: 'Description',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          location: 'Room 1',
          capacity: 20,
        );

        appState.addToSchedule(event);
        appState.addToSchedule(event);

        expect(appState.personalizedSchedule.length, 1);
      });

      test('removeFromSchedule removes event from schedule', () {
        final event = Event(
          id: '1',
          title: 'Event',
          description: 'Description',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          location: 'Room 1',
          capacity: 20,
        );

        appState.addToSchedule(event);
        expect(appState.personalizedSchedule.length, 1);

        appState.removeFromSchedule(event);

        expect(appState.personalizedSchedule.length, 0);
      });
    });

    group('Questions', () {
      test('submitQuestion adds question to list', () {
        appState.submitQuestion('What is Dart?');

        expect(appState.questions.length, 1);
        expect(appState.questions[0], 'What is Dart?');
      });

      test('submitQuestion adds multiple questions', () {
        appState.submitQuestion('Question 1');
        appState.submitQuestion('Question 2');
        appState.submitQuestion('Question 3');

        expect(appState.questions.length, 3);
      });

      test('removeQuestion removes question from list', () {
        const question = 'What is Flutter?';
        appState.submitQuestion(question);
        expect(appState.questions.length, 1);

        appState.removeQuestion(question);

        expect(appState.questions.length, 0);
      });
    });

    group('ChangeNotifier behavior', () {
      test('notifyListeners is called on checkIn', () {
        var notifyCount = 0;
        appState.addListener(() {
          notifyCount++;
        });

        final participant = Participant(
          id: '1',
          name: 'Test User',
          email: 'test@example.com',
          institution: 'UFMG',
          checkInTime: DateTime.now(),
        );

        appState.checkIn(participant);

        expect(notifyCount, greaterThan(0));
      });

      test('notifyListeners is called on addEvent', () {
        var notifyCount = 0;
        appState.addListener(() {
          notifyCount++;
        });

        final event = Event(
          id: '1',
          title: 'Event',
          description: 'Description',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          location: 'Room 1',
          capacity: 20,
        );

        appState.addEvent(event);

        expect(notifyCount, greaterThan(0));
      });

      test('notifyListeners is called on submitQuestion', () {
        var notifyCount = 0;
        appState.addListener(() {
          notifyCount++;
        });

        appState.submitQuestion('Test question');

        expect(notifyCount, greaterThan(0));
      });
    });

    group('Data validation', () {
      test('participant email is stored correctly', () {
        final participant = Participant(
          id: '1',
          name: 'Test',
          email: 'test@example.com',
          institution: 'UFMG',
          checkInTime: DateTime.now(),
        );

        appState.checkIn(participant);

        expect(appState.currentParticipant?.email, 'test@example.com');
      });

      test('event time properties work correctly', () {
        final now = DateTime.now();
        final event = Event(
          id: '1',
          title: 'Event',
          description: 'Description',
          startTime: now.add(const Duration(hours: 1)),
          endTime: now.add(const Duration(hours: 2)),
          location: 'Room',
          capacity: 20,
        );

        expect(event.isUpcoming, true);
        expect(event.isHappening, false);
        expect(event.isFinished, false);
      });

      test('event capacity is stored correctly', () {
        final event = Event(
          id: '1',
          title: 'Event',
          description: 'Description',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          location: 'Room',
          capacity: 100,
        );

        appState.addEvent(event);

        expect(appState.events[0].capacity, 100);
      });
    });

    group('Event Update', () {
      test('updateEvent replaces existing event by ID', () async {
        final event1 = Event(
          id: '1',
          title: 'Original Title',
          description: 'Original Description',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          location: 'Room 1',
          capacity: 20,
        );

        appState.addEvent(event1);
        expect(appState.events.length, 1);
        expect(appState.events[0].title, 'Original Title');

        final updatedEvent = Event(
          id: '1',
          title: 'Updated Title',
          description: 'Updated Description',
          startTime: DateTime.now().add(const Duration(hours: 2)),
          endTime: DateTime.now().add(const Duration(hours: 3)),
          location: 'Room 2',
          capacity: 30,
        );

        await appState.updateEvent(updatedEvent);

        expect(appState.events.length, 1);
        expect(appState.events[0].id, '1');
        expect(appState.events[0].title, 'Updated Title');
        expect(appState.events[0].description, 'Updated Description');
        expect(appState.events[0].capacity, 30);
      });

      test('updateEvent adds new event if ID does not exist', () async {
        final event1 = Event(
          id: '1',
          title: 'Event 1',
          description: 'First',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          location: 'Room 1',
          capacity: 20,
        );

        appState.addEvent(event1);
        expect(appState.events.length, 1);

        final newEvent = Event(
          id: '2',
          title: 'Event 2',
          description: 'Second',
          startTime: DateTime.now().add(const Duration(hours: 2)),
          endTime: DateTime.now().add(const Duration(hours: 3)),
          location: 'Room 2',
          capacity: 30,
        );

        await appState.updateEvent(newEvent);

        expect(appState.events.length, 2);
        expect(appState.events[1].id, '2');
        expect(appState.events[1].title, 'Event 2');
      });

      test('updateEvent notifies listeners when event is updated', () async {
        var notifyCount = 0;
        appState.addListener(() {
          notifyCount++;
        });

        final event = Event(
          id: '1',
          title: 'Event',
          description: 'Test',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          location: 'Room',
          capacity: 20,
        );

        appState.addEvent(event);
        final initialNotifyCount = notifyCount;

        final updatedEvent = Event(
          id: '1',
          title: 'Updated Event',
          description: 'Updated',
          startTime: DateTime.now().add(const Duration(hours: 1)),
          endTime: DateTime.now().add(const Duration(hours: 2)),
          location: 'Room 2',
          capacity: 25,
        );

        await appState.updateEvent(updatedEvent);

        expect(notifyCount, greaterThan(initialNotifyCount));
      });

      test('updateEvent maintains event list order', () async {
        final event1 = Event(
          id: '1',
          title: 'Event 1',
          description: 'First',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          location: 'Room 1',
          capacity: 20,
        );

        final event2 = Event(
          id: '2',
          title: 'Event 2',
          description: 'Second',
          startTime: DateTime.now().add(const Duration(hours: 2)),
          endTime: DateTime.now().add(const Duration(hours: 3)),
          location: 'Room 2',
          capacity: 30,
        );

        appState.addEvent(event1);
        appState.addEvent(event2);
        expect(appState.events.length, 2);
        expect(appState.events[0].id, '1');
        expect(appState.events[1].id, '2');

        // Update the first event
        final updatedEvent1 = Event(
          id: '1',
          title: 'Updated Event 1',
          description: 'Updated First',
          startTime: DateTime.now().add(const Duration(hours: 4)),
          endTime: DateTime.now().add(const Duration(hours: 5)),
          location: 'Room 3',
          capacity: 40,
        );

        await appState.updateEvent(updatedEvent1);

        expect(appState.events.length, 2);
        expect(appState.events[0].id, '1');
        expect(appState.events[0].title, 'Updated Event 1');
        expect(appState.events[1].id, '2');
        expect(appState.events[1].title, 'Event 2');
      });
    });
  });
}
