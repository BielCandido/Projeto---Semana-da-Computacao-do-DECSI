import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:semana_computacao/models/event.dart';
import 'package:semana_computacao/models/app_state.dart';
import 'package:semana_computacao/screens/checkin_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final inSchedule = appState.personalizedSchedule.contains(event);

    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('${event.location} • ${event.startTime} - ${event.endTime}'),
            const SizedBox(height: 12),
            if (event.speaker != null) Text('Palestrante: ${event.speaker}'),
            const SizedBox(height: 12),
            Text(event.description),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (!appState.isCheckedIn) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Check-in Required'),
                            content: const Text('Você precisa fazer check-in para adicionar eventos à sua agenda.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const CheckInScreen()),
                                  );
                                },
                                child: const Text('Fazer Check-in'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      if (inSchedule) {
                        appState.removeFromSchedule(event);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removido da sua agenda')));
                      } else {
                        appState.addToSchedule(event);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adicionado à sua agenda')));
                      }
                      Navigator.of(context).pop();
                    },
                    child: Text(inSchedule ? 'Remover da Agenda' : 'Adicionar à Agenda'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
