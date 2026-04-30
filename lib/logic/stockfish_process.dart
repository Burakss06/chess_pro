import 'dart:async';
import 'dart:convert';
import 'dart:io';

class StockfishProcess {
  Process? _process;
  final StreamController<String> _stdoutController = StreamController<String>.broadcast();
  bool _isReady = false;

  Stream<String> get stdout => _stdoutController.stream;
  bool get isReady => _isReady;

  Future<void> init() async {
    // Assuming the app is run from the project root in debug mode
    final executable = File('assets/engine/stockfish.exe');
    if (!await executable.exists()) {
      print('Stockfish executable not found at ${executable.path}');
      return;
    }

    _process = await Process.start(executable.path, []);

    _process!.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      if (line == 'readyok') {
        _isReady = true;
      }
      _stdoutController.add(line);
    });

    _process!.stderr.transform(utf8.decoder).listen((error) {
      print('Stockfish Error: $error');
    });

    send('uci');
    send('isready');
  }

  void send(String command) {
    if (_process != null) {
      _process!.stdin.writeln(command);
    }
  }

  void dispose() {
    send('quit');
    _process?.kill();
    _stdoutController.close();
  }
}
