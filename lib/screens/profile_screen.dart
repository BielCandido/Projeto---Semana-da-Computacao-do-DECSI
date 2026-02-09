import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:semana_computacao/models/app_state.dart';
import 'package:semana_computacao/screens/checkin_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final p = appState.currentParticipant;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: p == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Nenhum participante logado.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CheckInScreen()));
                    },
                    child: const Text('Fazer Check-in'),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nome: ${p.name}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('E-mail: ${p.email}'),
                  const SizedBox(height: 8),
                  Text('Instituição: ${p.institution}'),
                  const SizedBox(height: 8),
                  Text('Check-in: ${p.checkInTime}'),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      appState.checkOut();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Você fez check-out')));
                    },
                    child: const Text('Fazer Check-out'),
                  ),
                ],
              ),
      ),
    );
  }
}
