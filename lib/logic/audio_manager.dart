import 'package:audioplayers/audioplayers.dart';
import 'package:dartchess/dartchess.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _player = AudioPlayer();
  bool isMuted = false;

  Future<void> init() async {
    await _player.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> playMove(Move move, Position nextGame) async {
    if (isMuted) return;

    try {
      if (nextGame.isCheck) {
        await _player.play(AssetSource('sounds/check.mp3'));
      } else if (move is NormalMove && move.promotion != null) {
        await _player.play(AssetSource('sounds/capture.mp3'));
      } else {
        await _player.play(AssetSource('sounds/move.mp3'));
      }
    } catch (e) {
      // Ignore audio errors silently
    }
  }

  Future<void> playCapture() async {
    if (isMuted) return;
    try {
      await _player.play(AssetSource('sounds/capture.mp3'));
    } catch (e) {}
  }
}
