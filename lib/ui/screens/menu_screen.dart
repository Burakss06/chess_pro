import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'history_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/settings_repository.dart';
import '../../bloc/chess_bloc.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/menu_bg.png'),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.obsidian, AppTheme.deepCharcoal],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Hero(
                  tag: 'logo',
                  child: Text(
                    'ChessPro',
                    style: TextStyle(
                      color: AppTheme.champagneGold,
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const Text(
                  'PREMIUM CHESS EXPERIENCE',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 64),
                if (context.read<SettingsRepository>().currentGameFen != null) ...[
                  _buildMenuButton(
                    context,
                    'Devam Et',
                    Icons.play_circle_filled,
                    () async {
                      context.read<ChessBloc>().add(LoadSavedGame());
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen()));
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                _buildMenuButton(
                  context,
                  'Yeni Oyun',
                  Icons.play_arrow_rounded,
                  () => _showSideSelectionDialog(context),
                ),
                const SizedBox(height: 16),
                _buildMenuButton(
                  context,
                  'Maç Geçmişi',
                  Icons.history_rounded,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                ),
                const SizedBox(height: 16),
                _buildMenuButton(
                  context,
                  'Ayarlar',
                  Icons.settings_rounded,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                ),
                const SizedBox(height: 64),
                const Text(
                  'v2.0.0',
                  style: TextStyle(color: Colors.white24, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String label, IconData icon, VoidCallback onPressed) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 250,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Row(
                  children: [
                    Icon(icon, color: AppTheme.champagneGold),
                    const SizedBox(width: 16),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSideSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.deepCharcoal,
        title: const Text('Taraf Seçimi', style: TextStyle(color: AppTheme.champagneGold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.circle, color: Colors.white),
              title: const Text('Beyaz', style: TextStyle(color: Colors.white)),
              onTap: () {
                _startNewGame(context, 'white');
              },
            ),
            ListTile(
              leading: const Icon(Icons.circle, color: Colors.black),
              title: const Text('Siyah', style: TextStyle(color: Colors.white)),
              onTap: () {
                _startNewGame(context, 'black');
              },
            ),
            ListTile(
              leading: const Icon(Icons.casino, color: Colors.grey),
              title: const Text('Rastgele', style: TextStyle(color: Colors.white)),
              onTap: () {
                _startNewGame(context, 'random');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startNewGame(BuildContext context, String side) async {
    context.read<SettingsRepository>().setPreferredSide(side);
    context.read<ChessBloc>().add(ResetGame());
    Navigator.pop(context); // Close dialog
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen()));
    setState(() {});
  }
}
