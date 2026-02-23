import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:semana_computacao/models/app_state.dart';
import 'package:semana_computacao/screens/home_screen.dart';
import 'package:semana_computacao/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: const FirebaseOptions(
      apiKey: "AIzaSyAdpkFastxUvoypcXd5_RybOrmdfbNfv7s",
      appId: "1:199067693270:web:790df1955ee5e25a595977",
      messagingSenderId: "199067693270",
      projectId: "semana-da-computacao-fa84a", 
    ),

  ); 
  final appState = AppState();
  await appState.loadFromPrefs();
  await appState.loadEventsAndData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Semana da Computação DECSI',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}