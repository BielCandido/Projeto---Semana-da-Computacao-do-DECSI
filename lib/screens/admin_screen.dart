import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:semana_computacao/models/app_state.dart';
import 'package:semana_computacao/models/event.dart';
import 'package:semana_computacao/screens/admin_settings_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  Future<void> _openEventForm(BuildContext context, {Event? existing}) async {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final locationCtrl = TextEditingController(text: existing?.location ?? '');
    final speakerCtrl = TextEditingController(text: existing?.speaker ?? '');
    final capacityCtrl = TextEditingController(text: existing?.capacity.toString() ?? '30');

    DateTime start = existing?.startTime ?? DateTime.now().add(const Duration(hours: 1));
    DateTime end = existing?.endTime ?? start.add(const Duration(hours: 1));

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Criar Evento' : 'Editar Evento'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descrição')),
              TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Local')),
              TextField(controller: speakerCtrl, decoration: const InputDecoration(labelText: 'Palestrante')),
              TextField(controller: capacityCtrl, decoration: const InputDecoration(labelText: 'Capacidade'), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text('Início: ${start.toLocal()}'.split('.').first),
                  ),
                  TextButton(
                    onPressed: () async {
                      final d = await showDatePicker(context: ctx, initialDate: start, firstDate: DateTime(2020), lastDate: DateTime(2100));
                      if (d != null) {
                        final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(start));
                        if (t != null) start = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                      }
                    },
                    child: const Text('Alterar'),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(child: Text('Fim: ${end.toLocal()}'.split('.').first)),
                  TextButton(
                    onPressed: () async {
                      final d = await showDatePicker(context: ctx, initialDate: end, firstDate: DateTime(2020), lastDate: DateTime(2100));
                      if (d != null) {
                        final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(end));
                        if (t != null) end = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                      }
                    },
                    child: const Text('Alterar'),
                  )
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final id = existing?.id ?? const Uuid().v4();
              final capacity = int.tryParse(capacityCtrl.text) ?? 30;
              final event = Event(
                id: id,
                title: titleCtrl.text.trim(),
                description: descCtrl.text.trim(),
                startTime: start,
                endTime: end,
                location: locationCtrl.text.trim(),
                speaker: speakerCtrl.text.trim().isEmpty ? null : speakerCtrl.text.trim(),
                capacity: capacity,
              );

              final appState = Provider.of<AppState>(context, listen: false);
              if (existing == null) {
                appState.addEvent(event);
              } else {
                appState.removeEvent(existing);
                appState.addEvent(event);
              }

              Navigator.of(ctx).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Gerenciar Eventos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configurações',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminSettingsScreen())),
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final events = appState.events;
          if (events.isEmpty) return const Center(child: Text('Nenhum evento cadastrado'));

          return ListView.separated(
            itemCount: events.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final e = events[index];
              return ListTile(
                title: Text(e.title),
                subtitle: Text('${e.location} • ${e.startTime}'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _openEventForm(context, existing: e),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Confirmar'),
                          content: const Text('Remover este evento?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
                            ElevatedButton(
                              onPressed: () {
                                Provider.of<AppState>(context, listen: false).removeEvent(e);
                                Navigator.of(ctx).pop();
                              },
                              child: const Text('Remover'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ]),
                onTap: () => _openEventForm(context, existing: e),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEventForm(context),
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Evento',
      ),
    );
  }
}
