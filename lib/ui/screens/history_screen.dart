import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../../logic/settings_repository.dart';
import 'replay_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsRepository>();
    final history = settings.matchHistory;

    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      appBar: AppBar(
        title: const Text('Maç Geçmişi', style: TextStyle(color: AppTheme.champagneGold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      body: history.isEmpty
          ? const Center(
              child: Text(
                'Henüz maç kaydı yok.',
                style: TextStyle(color: Colors.white38),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final match = history[index];
                final date = DateTime.parse(match['date']);
                final result = match['result'];
                final moves = match['moves'];

                return InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ReplayScreen(matchData: match)));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getResultColor(result, match['playerSide']).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getResultIcon(result, match['playerSide']),
                            color: _getResultColor(result, match['playerSide']),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                DateFormat('dd MMM yyyy, HH:mm').format(date),
                                style: const TextStyle(color: Colors.white38, fontSize: 12),
                              ),
                              if (match['moveList'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    match['moveList'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white24, fontSize: 10, fontStyle: FontStyle.italic),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$moves Hamle',
                              style: const TextStyle(color: AppTheme.champagneGold, fontWeight: FontWeight.w500),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.white24),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getResultColor(String result, String? playerSide) {
    if (result.contains('Berabere')) return Colors.amberAccent;
    if (playerSide != null) {
      if (result.contains(playerSide)) return Colors.greenAccent; // User won
      return Colors.redAccent; // User lost
    }
    // Fallback for old matches without playerSide
    if (result.contains('Beyaz')) return Colors.greenAccent;
    if (result.contains('Siyah')) return Colors.redAccent;
    return Colors.amberAccent;
  }

  IconData _getResultIcon(String result, String? playerSide) {
    if (result.contains('Berabere')) return Icons.handshake;
    if (playerSide != null) {
      if (result.contains(playerSide)) return Icons.emoji_events;
      return Icons.sentiment_very_dissatisfied;
    }
    // Fallback for old matches
    if (result.contains('Beyaz')) return Icons.emoji_events;
    if (result.contains('Siyah')) return Icons.sentiment_very_dissatisfied;
    return Icons.handshake;
  }
}
