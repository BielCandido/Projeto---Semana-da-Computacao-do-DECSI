import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:semana_computacao/models/app_state.dart';
import 'package:semana_computacao/models/event.dart';
import 'package:semana_computacao/screens/event_detail_screen.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({Key? key}) : super(key: key);

  void _addSampleEvents(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final now = DateTime.now();
    final idGen = const Uuid();

    final events = [
      Event(
        id: idGen.v4(),
        title: 'Abertura e Boas-vindas',
        description: 'Abertura oficial do evento com informações gerais.',
        startTime: now.add(const Duration(hours: 1)),
        endTime: now.add(const Duration(hours: 2)),
        location: 'Auditório Principal',
        speaker: 'Prof. Silva',
        capacity: 200,
      ),
      Event(
        id: idGen.v4(),
        title: 'Palestra: Flutter na Prática',
        description: 'Introdução prática ao desenvolvimento com Flutter.',
        startTime: now.add(const Duration(hours: 3)),
        endTime: now.add(const Duration(hours: 4)),
        location: 'Sala 101',
        speaker: 'Drª. Almeida',
        capacity: 80,
      ),
      Event(
        id: idGen.v4(),
        title: 'Workshop: Git e Colaboração',
        description: 'Boas práticas de versionamento e colaboração.',
        startTime: now.add(const Duration(hours: 5)),
        endTime: now.add(const Duration(hours: 7)),
        location: 'Laboratório',
        speaker: 'Equipe DECSI',
        capacity: 30,
      ),
    ];

    for (final e in events) {
      appState.addEvent(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Programação')),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final events = appState.events;
          if (events.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Nenhum evento cadastrado.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _addSampleEvents(context),
                      child: const Text('Adicionar eventos de exemplo'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final e = events[index];
              return ListTile(
                title: Text(e.title),
                subtitle: Text('${e.location} • ${e.startTime.hour}:${e.startTime.minute.toString().padLeft(2, '0')}'),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => EventDetailScreen(event: e)),
                    );
                  },
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => EventDetailScreen(event: e)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
