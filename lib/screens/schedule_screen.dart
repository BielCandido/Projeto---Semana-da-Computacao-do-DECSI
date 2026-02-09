import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:semana_computacao/models/app_state.dart';
import 'package:semana_computacao/models/event.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minha Agenda')),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final schedule = appState.personalizedSchedule;
          if (schedule.isEmpty) {
            return const Center(child: Text('Sua agenda está vazia. Adicione eventos na programação.'));
          }

          return ListView.builder(
            itemCount: schedule.length,
            itemBuilder: (context, index) {
              final Event e = schedule[index];
              return ListTile(
                title: Text(e.title),
                subtitle: Text('${e.location} • ${e.startTime}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    appState.removeFromSchedule(e);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
