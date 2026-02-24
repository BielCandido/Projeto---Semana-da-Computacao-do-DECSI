import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:semana_computacao/models/app_state.dart';
import 'package:semana_computacao/models/event.dart';
import 'package:semana_computacao/screens/admin_screen.dart';
import 'package:semana_computacao/services/admin_auth.dart';

class MockAdminAuth extends Mock implements AdminAuth {}

class MockAppState extends Mock implements AppState {
  @override
  List<Event> get events => _events;
  List<Event> _events = [];

  void setEvents(List<Event> events) {
    _events = events;
    notifyListeners();
  }

  @override
  Future<void> addEvent(Event event) async {
    _events.add(event);
    notifyListeners();
  }

  @override
  Future<void> updateEvent(Event event) async {
    final idx = _events.indexWhere((e) => e.id == event.id);
    if (idx != -1) {
      _events[idx] = event;
      notifyListeners();
    }
  }

  @override
  Future<void> removeEvent(Event event) async {
    _events.remove(event);
    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  final List<VoidCallback> _listeners = [];
}

void main() {
  group('AdminScreen Widget Tests', () {
    late MockAppState mockAppState;

    setUp(() {
      mockAppState = MockAppState();
      registerFallbackValue(Event(
        id: 'test-id',
        title: 'Test Event',
        description: 'Test',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        location: 'Test Location',
        capacity: 20,
      ));
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: ChangeNotifierProvider<AppState>.value(
          value: mockAppState,
          child: const AdminScreen(),
        ),
      );
    }

    testWidgets('displays empty state message when no events', (WidgetTester tester) async {
      mockAppState.setEvents([]);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Nenhum evento cadastrado'), findsOneWidget);
    });

    testWidgets('displays list of events', (WidgetTester tester) async {
      final event1 = Event(
        id: '1',
        title: 'Flutter Workshop',
        description: 'Learn Flutter',
        startTime: DateTime(2026, 3, 20, 10, 0),
        endTime: DateTime(2026, 3, 20, 12, 0),
        location: 'Room 101',
        capacity: 30,
      );

      final event2 = Event(
        id: '2',
        title: 'Dart Seminar',
        description: 'Dart Language',
        startTime: DateTime(2026, 3, 20, 14, 0),
        endTime: DateTime(2026, 3, 20, 16, 0),
        location: 'Room 102',
        capacity: 25,
      );

      mockAppState.setEvents([event1, event2]);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Flutter Workshop'), findsOneWidget);
      expect(find.text('Dart Seminar'), findsOneWidget);
    });

    testWidgets('displays event list items', (WidgetTester tester) async {
      final event = Event(
        id: '1',
        title: 'Test Event',
        description: 'Test',
        startTime: DateTime(2026, 3, 20, 10, 30),
        endTime: DateTime(2026, 3, 20, 12, 0),
        location: 'Conference Hall',
        capacity: 40,
      );

      mockAppState.setEvents([event]);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Test Event'), findsOneWidget);
    });

    testWidgets('renders add button (FAB)', (WidgetTester tester) async {
      mockAppState.setEvents([]);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders appbar with title', (WidgetTester tester) async {
      mockAppState.setEvents([]);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Admin - Gerenciar Eventos'), findsOneWidget);
    });

    testWidgets('displays edit and delete icons for each event', (WidgetTester tester) async {
      final event = Event(
        id: '1',
        title: 'Event to Edit',
        description: 'Test',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        location: 'Room',
        capacity: 20,
      );

      mockAppState.setEvents([event]);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('FAB opens add event dialog', (WidgetTester tester) async {
      mockAppState.setEvents([]);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Criar Evento'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('event form has required fields', (WidgetTester tester) async {
      mockAppState.setEvents([]);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsWidgets);
      expect(find.text('Título'), findsOneWidget);
      expect(find.text('Descrição'), findsOneWidget);
      expect(find.text('Local'), findsOneWidget);
      expect(find.text('Palestrante'), findsOneWidget);
      expect(find.text('Capacidade'), findsOneWidget);
    });

    testWidgets('form has save and cancel buttons', (WidgetTester tester) async {
      mockAppState.setEvents([]);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Salvar'), findsOneWidget);
    });

    testWidgets('cancel button closes dialog', (WidgetTester tester) async {
      mockAppState.setEvents([]);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('tapping edit icon opens edit dialog', (WidgetTester tester) async {
      final event = Event(
        id: '1',
        title: 'Event to Edit',
        description: 'Description',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        location: 'Room',
        capacity: 20,
      );

      mockAppState.setEvents([event]);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expect(find.text('Editar Evento'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('tapping delete icon shows confirmation dialog', (WidgetTester tester) async {
      final event = Event(
        id: '1',
        title: 'Event to Delete',
        description: 'Test',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        location: 'Room',
        capacity: 20,
      );

      mockAppState.setEvents([event]);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.text('Confirmar'), findsOneWidget);
      expect(find.text('Remover este evento?'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('settings icon in appbar is present', (WidgetTester tester) async {
      mockAppState.setEvents([]);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('renders multiple events in list', (WidgetTester tester) async {
      final events = List.generate(
        5,
        (i) => Event(
          id: '$i',
          title: 'Event $i',
          description: 'Description $i',
          startTime: DateTime.now().add(Duration(hours: i)),
          endTime: DateTime.now().add(Duration(hours: i + 1)),
          location: 'Room $i',
          capacity: 20 + i,
        ),
      );

      mockAppState.setEvents(events);

      await tester.pumpWidget(createWidgetUnderTest());

      for (int i = 0; i < 5; i++) {
        expect(find.text('Event $i'), findsOneWidget);
      }
    });

    testWidgets('event list updates when events are changed', (WidgetTester tester) async {
      final event1 = Event(
        id: '1',
        title: 'Event 1',
        description: 'Test',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        location: 'Room',
        capacity: 20,
      );

      mockAppState.setEvents([event1]);

      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('Event 1'), findsOneWidget);

      // Add another event
      final event2 = Event(
        id: '2',
        title: 'Event 2',
        description: 'Test',
        startTime: DateTime.now().add(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        location: 'Room 2',
        capacity: 30,
      );

      mockAppState.setEvents([event1, event2]);
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Event 1'), findsOneWidget);
      expect(find.text('Event 2'), findsOneWidget);
    });
  });
}
