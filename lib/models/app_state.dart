import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:semana_computacao/models/participant.dart';
import 'package:semana_computacao/models/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import do Firebase

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

  // --- CARREGAMENTO DO FIREBASE ---
  Future<void> loadEventsAndData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Ouvir a coleção 'activities' em TEMPO REAL!
    FirebaseFirestore.instance.collection('activities').snapshots().listen((snapshot) {
      _events = snapshot.docs.map((doc) {
        final data = doc.data();
        return Event.fromJson(data);
      }).toList();
      notifyListeners(); 
    });

    // 2. Carregar a Agenda Personalizada
    final scheduleStr = prefs.getString(_kScheduleKey);
    if (scheduleStr != null) {
      try {
        final List<dynamic> ids = jsonDecode(scheduleStr);
        final idSet = ids.map((e) => e.toString()).toSet();
        _personalizedSchedule = _events.where((ev) => idSet.contains(ev.id)).toList();
      } catch (e) { 
        _personalizedSchedule = [];
      }
    }

    // 3. Ouvir as perguntas em TEMPO REAL!
    FirebaseFirestore.instance
        .collection('questions')
        .orderBy('data_envio', descending: false)
        .snapshots()
        .listen((snapshot) {
      _questions = snapshot.docs.map<String>((doc) {
        final data = doc.data() as Map<String, dynamic>; 
        return data['texto']?.toString() ?? 'Pergunta sem texto';
      }).toList();
      notifyListeners();
    });
  }

  // --- EVENTOS NO FIREBASE ---
// --- EVENTOS NO FIREBASE ---
  Future<void> addEvent(Event event) async {
    _events.add(event);
    notifyListeners(); 

    try {
      // TRUQUE: Em vez de .add(), usamos .doc(event.id).set() 
      // Assim o nome do ficheiro no Firebase será exatamente o ID do evento,
      // o que facilita muito na hora de o apagar!
      await FirebaseFirestore.instance
          .collection('activities')
          .doc(event.id) 
          .set(event.toJson());
      print("Sucesso: Evento salvo no Firebase!");
    } catch (erro) {
      print("Erro ao salvar evento no Firebase: $erro");
    }
  }

  Future<void> removeEvent(Event event) async {
    // 1. Remove da tela na hora
    _events.remove(event);
    _saveEvents();
    notifyListeners();

    // 2. Apaga da base de dados do Firebase usando o ID do evento
    try {
      await FirebaseFirestore.instance
          .collection('activities')
          .doc(event.id)
          .delete();
      print("Sucesso: Evento apagado do Firebase!");
    } catch (erro) {
      print("Erro ao apagar evento no Firebase: $erro");
    }
  }

  // --- INSCRIÇÕES NO FIREBASE ---
  Future<void> addToSchedule(Event event) async {
    if (!_personalizedSchedule.contains(event)) {
      _personalizedSchedule.add(event);
      _saveSchedule(); 
      notifyListeners();

      if (_currentParticipant != null) {
        try {
          String docId = '${_currentParticipant!.id}_${event.id}';
          await FirebaseFirestore.instance.collection('enrollments').doc(docId).set({
            'usuario_id': _currentParticipant!.id,
            'atividade_id': event.id,
            'data_inscricao': FieldValue.serverTimestamp(),
          });
          print("Sucesso: Inscrição salva no Firebase!");
        } catch (erro) {
          print("Erro ao salvar inscrição: $erro");
        }
      }
    }
  }

  Future<void> removeFromSchedule(Event event) async {
    if (_personalizedSchedule.contains(event)) {
      _personalizedSchedule.remove(event);
      _saveSchedule();
      notifyListeners();

      if (_currentParticipant != null) {
        try {
          String docId = '${_currentParticipant!.id}_${event.id}';
          await FirebaseFirestore.instance.collection('enrollments').doc(docId).delete();
          print("Sucesso: Inscrição removida do Firebase!");
        } catch (erro) {
          print("Erro ao remover inscrição: $erro");
        }
      }
    }
  }

  // --- PERGUNTAS NO FIREBASE ---
  Future<void> submitQuestion(String question) async {
    _questions.add(question);
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('questions').add({
        'texto': question,
        'data_envio': FieldValue.serverTimestamp(), 
      });
      print("Sucesso: Pergunta enviada para o Firebase!");
    } catch (erro) {
      print("Erro ao enviar pergunta: $erro");
    }
  }

  void removeQuestion(String question) {
    _questions.remove(question);
    _saveQuestions();
    notifyListeners();
  }
}