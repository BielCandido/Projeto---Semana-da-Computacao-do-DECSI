import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:semana_computacao/models/app_state.dart';
import 'package:semana_computacao/models/participant.dart';
import 'package:semana_computacao/screens/home_screen.dart';

class MockAppState extends Mock implements AppState {
  @override
  bool get isCheckedIn => _isCheckedIn;
  bool _isCheckedIn = false;

  @override
  Participant? get currentParticipant => _currentParticipant;
  Participant? _currentParticipant;

  void setCheckedIn(bool value, {Participant? participant}) {
    _isCheckedIn = value;
    _currentParticipant = participant;
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
  group('HomeScreen Widget Tests', () {
    late MockAppState mockAppState;

    setUp(() {
      mockAppState = MockAppState();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: ChangeNotifierProvider<AppState>.value(
          value: mockAppState,
          child: const HomeScreen(),
        ),
      );
    }

    testWidgets('displays welcome text when not checked in', (WidgetTester tester) async {
      mockAppState.setCheckedIn(false);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Bem-vindo à Semana da Computação!'), findsOneWidget);
      expect(find.text('Faça seu check-in para começar'), findsOneWidget);
    });

    testWidgets('displays participant name when checked in', (WidgetTester tester) async {
      final participant = Participant(
        id: '1',
        name: 'João da Silva',
        email: 'joao@example.com',
        institution: 'UFMG',
        checkInTime: DateTime.now(),
      );

      mockAppState.setCheckedIn(true, participant: participant);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Você fez check-in! João da Silva'), findsOneWidget);
    });

    testWidgets('renders four navigation buttons', (WidgetTester tester) async {
      mockAppState.setCheckedIn(false);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Check-in'), findsOneWidget);
      expect(find.text('Programação'), findsWidgets); // pode aparecer múltiplas vezes
      expect(find.text('Perguntas'), findsOneWidget);
    });

    testWidgets('renders "Ver Perfil" button', (WidgetTester tester) async {
      mockAppState.setCheckedIn(false);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Ver Perfil'), findsOneWidget);
    });

    testWidgets('renders admin hint text', (WidgetTester tester) async {
      mockAppState.setCheckedIn(false);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(
        find.textContaining('segure o título'),
        findsOneWidget,
      );
    });

    testWidgets('Card is visible and centered', (WidgetTester tester) async {
      mockAppState.setCheckedIn(false);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('BottomNavigationBar is present', (WidgetTester tester) async {
      mockAppState.setCheckedIn(false);

      await tester.pumpWidget(createWidgetUnderTest());

      final navBar = find.byType(BottomNavigationBar);
      expect(navBar, findsOneWidget);
    });

    testWidgets('AppBar displays title', (WidgetTester tester) async {
      mockAppState.setCheckedIn(false);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(
        find.text('Semana da Computação DECSI'),
        findsOneWidget,
      );
    });

    testWidgets('GridView adapts to changes in state', (WidgetTester tester) async {
      mockAppState.setCheckedIn(false);

      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('Check-in'), findsOneWidget);

      // Update state
      final participant = Participant(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        institution: 'UFMG',
        checkInTime: DateTime.now(),
      );
      mockAppState.setCheckedIn(true, participant: participant);
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Você fez check-in! Test User'), findsOneWidget);
    });
  });
}
