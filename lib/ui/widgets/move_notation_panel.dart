import 'package:flutter/material.dart';
import '../theme.dart';

class MoveNotationPanel extends StatelessWidget {
  final List<String> moves;

  const MoveNotationPanel({super.key, required this.moves});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: moves.isEmpty
          ? const Center(child: Text('Maç başladı, hamle bekleniyor...', style: TextStyle(color: Colors.white24, fontSize: 12)))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _buildMovePairs(),
              ),
            ),
    );
  }

  List<Widget> _buildMovePairs() {
    List<Widget> widgets = [];
    for (int i = 0; i < moves.length; i += 2) {
      int moveNumber = (i ~/ 2) + 1;
      String whiteMove = moves[i];
      String blackMove = (i + 1 < moves.length) ? moves[i + 1] : "...";

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$moveNumber. ',
                  style: const TextStyle(color: AppTheme.champagneGold, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '$whiteMove ',
                  style: const TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: blackMove,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return widgets;
  }
}
