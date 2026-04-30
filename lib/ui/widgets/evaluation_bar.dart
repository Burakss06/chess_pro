import 'package:flutter/material.dart';
import '../theme.dart';

class EvaluationBar extends StatelessWidget {
  final double score; // Positive for White, Negative for Black

  const EvaluationBar({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    // Non-linear scaling for a more natural feel (like real apps)
    // +1.0 advantage is visible, but +10.0 doesn't "break" the bar
    double percentage = 0.5 + 0.5 * (score / (score.abs() + 2.0));
    percentage = percentage.clamp(0.05, 0.95); // Prevent fully empty/full

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: 24, // Slightly wider for the container
          height: double.infinity,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Container(
            width: 12,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // White's portion (from bottom)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOutSine,
                  width: 12,
                  height: percentage * (constraints.maxHeight - 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                // Indicator line at 50%
                Positioned(
                  bottom: (constraints.maxHeight - 8) / 2,
                  child: Container(
                    width: 12,
                    height: 2,
                    color: AppTheme.champagneGold,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
