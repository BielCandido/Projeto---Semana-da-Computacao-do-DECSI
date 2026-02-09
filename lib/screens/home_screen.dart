import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:semana_computacao/models/app_state.dart';
import 'package:semana_computacao/screens/checkin_screen.dart';
import 'package:semana_computacao/screens/event_list_screen.dart';
import 'package:semana_computacao/screens/schedule_screen.dart';
import 'package:semana_computacao/screens/questions_screen.dart';
import 'package:semana_computacao/screens/profile_screen.dart';
import 'package:semana_computacao/screens/admin_screen.dart';
import 'package:semana_computacao/services/admin_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: () async {
            final ok = await AdminAuth.requestAuth(context);
            if (ok) Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminScreen()));
          },
          child: const Text('Semana da Computação DECSI'),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Consumer<AppState>(
          builder: (context, appState, child) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Bem-vindo à Semana da Computação!',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      appState.isCheckedIn
                          ? 'Você fez check-in! ${appState.currentParticipant?.name}'
                          : 'Faça seu check-in para começar',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 18),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 3,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CheckInScreen())),
                          icon: const Icon(Icons.login),
                          label: const Text('Check-in'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EventListScreen())),
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Programação'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScheduleScreen())),
                          icon: const Icon(Icons.assignment),
                          label: const Text('Minha Agenda'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QuestionsScreen())),
                          icon: const Icon(Icons.help),
                          label: const Text('Perguntas'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
                        child: const Text('Ver Perfil'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text('Dica: segure o título no topo para acessar funções administrativas', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Programação',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Minha Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: 'Dúvidas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // Navigate for non-home tabs
          if (index == 1) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EventListScreen()));
          } else if (index == 2) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScheduleScreen()));
          } else if (index == 3) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QuestionsScreen()));
          } else if (index == 4) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }
        },
      ),
    );
  }
}
