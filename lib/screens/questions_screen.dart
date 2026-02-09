import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:semana_computacao/models/app_state.dart';
import 'package:semana_computacao/screens/checkin_screen.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({Key? key}) : super(key: key);

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    
    if (!appState.isCheckedIn) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Check-in Required'),
          content: const Text('Você precisa fazer check-in para enviar perguntas.'),
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

    final text = _controller.text.trim();
    if (text.isEmpty) return;
    appState.submitQuestion(text);
    _controller.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pergunta enviada')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enviar Pergunta')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Digite sua pergunta...'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () => _submit(context), child: const Text('Enviar')),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Consumer<AppState>(
              builder: (context, appState, child) {
                final qs = appState.questions;
                if (qs.isEmpty) return const Center(child: Text('Nenhuma pergunta enviada ainda'));
                return ListView.separated(
                  itemBuilder: (context, index) => ListTile(title: Text(qs[index])),
                  separatorBuilder: (_, __) => const Divider(),
                  itemCount: qs.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
