import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _isAdaptiveKey = 'is_adaptive';
  static const String _manualLevelKey = 'manual_level';
  static const String _playerEloKey = 'player_elo';
  static const String _historyKey = 'match_history';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // AI Settings
  bool get isAdaptive => _prefs.getBool(_isAdaptiveKey) ?? true;
  Future<void> setAdaptive(bool value) => _prefs.setBool(_isAdaptiveKey, value);

  int get manualLevel => _prefs.getInt(_manualLevelKey) ?? 5;
  Future<void> setManualLevel(int value) => _prefs.setInt(_manualLevelKey, value);

  int get playerElo => _prefs.getInt(_playerEloKey) ?? 1200;
  Future<void> setPlayerElo(int value) => _prefs.setInt(_playerEloKey, value);

  // Match History
  List<Map<String, dynamic>> get matchHistory {
    final String? json = _prefs.getString(_historyKey);
    if (json == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(json));
  }

  Future<void> saveMatch(Map<String, dynamic> match) async {
    final history = matchHistory;
    history.insert(0, match); // Add to beginning
    // Limit history to last 50 matches for performance
    if (history.length > 50) history.removeLast();
    await _prefs.setString(_historyKey, jsonEncode(history));
  }

  // Theme & Appearance
  static const String _boardThemeKey = 'board_theme';
  String get boardTheme => _prefs.getString(_boardThemeKey) ?? 'obsidian';
  Future<void> setBoardTheme(String value) => _prefs.setString(_boardThemeKey, value);

  // Gameplay Settings
  static const String _preferredSideKey = 'preferred_side';
  String get preferredSide => _prefs.getString(_preferredSideKey) ?? 'white';
  Future<void> setPreferredSide(String value) => _prefs.setString(_preferredSideKey, value);

  static const String _isMutedKey = 'is_muted';
  bool get isMuted => _prefs.getBool(_isMutedKey) ?? false;
  Future<void> setMuted(bool value) => _prefs.setBool(_isMutedKey, value);

  // Game Resume State
  static const String _currentGameFenKey = 'current_game_fen';
  static const String _currentMoveHistoryKey = 'current_move_history';
  static const String _currentPlayerSideKey = 'current_player_side';
  
  String? get currentGameFen => _prefs.getString(_currentGameFenKey);
  Future<void> setCurrentGameFen(String? value) async {
    if (value == null) await _prefs.remove(_currentGameFenKey);
    else await _prefs.setString(_currentGameFenKey, value);
  }

  String? get currentPlayerSide => _prefs.getString(_currentPlayerSideKey);
  Future<void> setCurrentPlayerSide(String? value) async {
    if (value == null) await _prefs.remove(_currentPlayerSideKey);
    else await _prefs.setString(_currentPlayerSideKey, value);
  }

  List<String> get currentMoveHistory {
    final jsonStr = _prefs.getString(_currentMoveHistoryKey);
    if (jsonStr == null) return [];
    return List<String>.from(jsonDecode(jsonStr));
  }

  Future<void> setCurrentMoveHistory(List<String> moves) async {
    await _prefs.setString(_currentMoveHistoryKey, jsonEncode(moves));
  }

  Future<void> clearCurrentGame() async {
    await _prefs.remove(_currentGameFenKey);
    await _prefs.remove(_currentMoveHistoryKey);
    await _prefs.remove(_currentPlayerSideKey);
  }
}
