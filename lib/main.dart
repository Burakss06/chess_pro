import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ui/theme.dart';
import 'ui/screens/menu_screen.dart';
import 'logic/settings_repository.dart';
import 'bloc/chess_bloc.dart';
import 'logic/audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final settingsRepository = SettingsRepository();
  await settingsRepository.init();
  
  AudioManager().isMuted = settingsRepository.isMuted;

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: settingsRepository),
      ],
      child: BlocProvider(
        create: (context) => ChessBloc(settings: settingsRepository),
        child: const ChessProApp(),
      ),
    ),
  );
}

class ChessProApp extends StatelessWidget {
  const ChessProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChessPro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: AppTheme.obsidian,
      ),
      home: const MenuScreen(),
    );
  }
}
