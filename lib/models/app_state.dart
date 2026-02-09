import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:semana_computacao/models/participant.dart';
import 'package:semana_computacao/models/event.dart';

class AppState extends ChangeNotifier {
  bool _isCheckedIn = false;
  List<Event> _events = [];
  List<Event> _personalizedSchedule = [];
  List<String> _questions = [];
  Participant? _currentParticipant;

  // Getters
  bool get isCheckedIn => _isCheckedIn;
  List<Event> get events => _events;
  List<Event> get personalizedSchedule => _personalizedSchedule;
  List<String> get questions => _questions;
  Participant? get currentParticipant => _currentParticipant;

  // Check-in
  void checkIn(Participant participant) {
    _currentParticipant = participant;
    _isCheckedIn = true;
    _saveCurrentParticipant();
    notifyListeners();
  }

  void checkOut() {
    _isCheckedIn = false;
    _currentParticipant = null;
    _clearSavedParticipant();
    notifyListeners();
  }

  // Persistence
  static const String _kParticipantKey = 'current_participant';
  static const String _kEventsKey = 'events';
  static const String _kScheduleKey = 'personalized_schedule';
  static const String _kQuestionsKey = 'questions';

  Future<void> _saveCurrentParticipant() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentParticipant == null) return;
    final jsonStr = jsonEncode(_currentParticipant!.toJson());
    await prefs.setString(_kParticipantKey, jsonStr);
  }

  Future<void> _clearSavedParticipant() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kParticipantKey);
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _events.map((e) => e.toJson()).toList();
    await prefs.setString(_kEventsKey, jsonEncode(list));
  }

  Future<void> _saveSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    // save schedule as list of event ids
    final ids = _personalizedSchedule.map((e) => e.id).toList();
    await prefs.setString(_kScheduleKey, jsonEncode(ids));
  }

  Future<void> _saveQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kQuestionsKey, jsonEncode(_questions));
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_kParticipantKey);
    if (jsonStr != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        _currentParticipant = Participant.fromJson(data);
        _isCheckedIn = true;
        notifyListeners();
      } catch (_) {
        // ignore malformed stored data
      }
    }
  }

  /// Load events, schedule and questions from preferences
  Future<void> loadEventsAndData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load events
    final eventsStr = prefs.getString(_kEventsKey);
    if (eventsStr != null) {
      try {
        final List<dynamic> raw = jsonDecode(eventsStr);
        _events = raw.map((e) => Event.fromJson(Map<String, dynamic>.from(e))).toList();
      } catch (_) {
        _events = [];
      }
    }

    // Load schedule (by ids)
    final scheduleStr = prefs.getString(_kScheduleKey);
    if (scheduleStr != null) {
      try {
        final List<dynamic> ids = jsonDecode(scheduleStr);
        final idSet = ids.map((e) => e.toString()).toSet();
        _personalizedSchedule = _events.where((ev) => idSet.contains(ev.id)).toList();
      } catch (_) {
        _personalizedSchedule = [];
      }
    }

    // Load questions
    final qsStr = prefs.getString(_kQuestionsKey);
    if (qsStr != null) {
      try {
        final List<dynamic> qs = jsonDecode(qsStr);
        _questions = qs.map((e) => e.toString()).toList();
      } catch (_) {
        _questions = [];
      }
    }

    notifyListeners();
  }

  // Event management
  void addEvent(Event event) {
    _events.add(event);
    _saveEvents();
    notifyListeners();
  }

  void removeEvent(Event event) {
    _events.remove(event);
    _saveEvents();
    notifyListeners();
  }

  // Personalized schedule
  void addToSchedule(Event event) {
    if (!_personalizedSchedule.contains(event)) {
      _personalizedSchedule.add(event);
      _saveSchedule();
      notifyListeners();
    }
  }

  void removeFromSchedule(Event event) {
    _personalizedSchedule.remove(event);
    _saveSchedule();
    notifyListeners();
  }

  // Questions
  void submitQuestion(String question) {
    _questions.add(question);
    _saveQuestions();
    notifyListeners();
  }

  void removeQuestion(String question) {
    _questions.remove(question);
    _saveQuestions();
    notifyListeners();
  }
}
