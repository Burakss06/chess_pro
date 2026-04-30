import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PerformanceData {
  final double averageAccuracy;
  final int calculatedElo;
  final int gamesPlayed;

  PerformanceData({
    required this.averageAccuracy,
    required this.calculatedElo,
    required this.gamesPlayed,
  });

  Map<String, dynamic> toJson() => {
    'averageAccuracy': averageAccuracy,
    'calculatedElo': calculatedElo,
    'gamesPlayed': gamesPlayed,
  };

  factory PerformanceData.fromJson(Map<String, dynamic> json) => PerformanceData(
    averageAccuracy: json['averageAccuracy'],
    calculatedElo: json['calculatedElo'],
    gamesPlayed: json['gamesPlayed'],
  );
}

class PerformanceManager {
  static const String _fileName = 'user_performance.json';

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<void> savePerformance(PerformanceData data) async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode(data.toJson()));
  }

  Future<PerformanceData> loadPerformance() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        return PerformanceData.fromJson(jsonDecode(content));
      }
    } catch (e) {
      // Ignore error and return default
    }
    return PerformanceData(averageAccuracy: 50.0, calculatedElo: 800, gamesPlayed: 0);
  }
}
