import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartchess/dartchess.dart';
import '../logic/stockfish_process.dart';
import '../logic/settings_repository.dart';
import '../logic/audio_manager.dart';

abstract class ChessEvent {}

class MovePiece extends ChessEvent {
  final Move move;
  MovePiece(this.move);
}

class UpdateEvaluation extends ChessEvent {
  final double evaluation;
  UpdateEvaluation(this.evaluation);
}

class UndoMove extends ChessEvent {}

class ResetGame extends ChessEvent {}

class LoadSavedGame extends ChessEvent {}

class RequestHint extends ChessEvent {}

class ReceiveHint extends ChessEvent {
  final Move move;
  ReceiveHint(this.move);
}

class ChessState {
  final Position game;
  final bool isThinking;
  final String? lastMove;
  final Square? lastMoveFrom;
  final Square? lastMoveTo;
  final String? openingName;
  final String? coachMessage;
  final double evaluation;
  final List<String> moveHistory;
  final List<Position> gameHistory;
  final Map<String, int> moveStats;
  final int currentLevel;
  final int? eloChange;
  final Side playerSide;

  final bool isHinting;
  final Square? hintMoveFrom;
  final Square? hintMoveTo;

  ChessState({
    required this.game,
    this.isThinking = false,
    this.lastMove,
    this.lastMoveFrom,
    this.lastMoveTo,
    this.openingName,
    this.coachMessage,
    this.evaluation = 0.0,
    this.moveHistory = const [],
    this.gameHistory = const [],
    this.moveStats = const {'!!': 0, '!': 0, '?': 0, '??': 0},
    this.currentLevel = 5,
    this.eloChange,
    this.playerSide = Side.white,
    this.isHinting = false,
    this.hintMoveFrom,
    this.hintMoveTo,
  });

  ChessState copyWith({
    Position? game,
    bool? isThinking,
    String? lastMove,
    Square? lastMoveFrom,
    Square? lastMoveTo,
    String? openingName,
    String? coachMessage,
    double? evaluation,
    List<String>? moveHistory,
    List<Position>? gameHistory,
    Map<String, int>? moveStats,
    int? currentLevel,
    int? eloChange,
    Side? playerSide,
    bool? isHinting,
    Square? hintMoveFrom,
    Square? hintMoveTo,
  }) {
    return ChessState(
      game: game ?? this.game,
      isThinking: isThinking ?? this.isThinking,
      lastMove: lastMove ?? this.lastMove,
      lastMoveFrom: lastMoveFrom ?? this.lastMoveFrom,
      lastMoveTo: lastMoveTo ?? this.lastMoveTo,
      openingName: openingName ?? this.openingName,
      coachMessage: coachMessage ?? this.coachMessage,
      evaluation: evaluation ?? this.evaluation,
      moveHistory: moveHistory ?? this.moveHistory,
      gameHistory: gameHistory ?? this.gameHistory,
      moveStats: moveStats ?? this.moveStats,
      currentLevel: currentLevel ?? this.currentLevel,
      eloChange: eloChange ?? this.eloChange,
      playerSide: playerSide ?? this.playerSide,
      isHinting: isHinting ?? this.isHinting,
      hintMoveFrom: hintMoveFrom ?? this.hintMoveFrom,
      hintMoveTo: hintMoveTo ?? this.hintMoveTo,
    );
  }
}

class ChessBloc extends Bloc<ChessEvent, ChessState> {
  late StockfishProcess _stockfish;
  final SettingsRepository settings;

  ChessBloc({required this.settings}) : super(ChessState(
    game: Chess.fromSetup(Setup.parseFen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')),
    currentLevel: settings.isAdaptive 
        ? _mapEloToLevel(settings.playerElo) 
        : settings.manualLevel,
  )) {
    
    _stockfish = StockfishProcess();
    _stockfish.init();
    
    _stockfish.stdout.listen((line) {
      if (line == 'readyok') {
        _stockfish.send('setoption name Skill Level value ${state.currentLevel}');
      }
      
      if (line.contains('score cp')) {
        final match = RegExp(r'score cp (-?\d+)').firstMatch(line);
        if (match != null) {
          final score = int.parse(match.group(1)!) / 100.0;
          add(UpdateEvaluation(score));
        }
      }
      
      if (line.startsWith('bestmove')) {
        final parts = line.split(' ');
        if (parts.length > 1) {
          final uci = parts[1];
          final move = _parseUci(uci);
          if (move != null) {
            if (state.isHinting) {
              add(ReceiveHint(move));
            } else if (state.game.turn != state.playerSide) {
              add(MovePiece(move));
            }
          }
        }
      }
    });

    on<RequestHint>((event, emit) {
      if (!state.isThinking && _stockfish.isReady) {
        emit(state.copyWith(isHinting: true, hintMoveFrom: null, hintMoveTo: null));
        // Use max Stockfish level for the best possible hint
        _stockfish.send('setoption name Skill Level value 20');
        _stockfish.send('position fen ${state.game.fen}');
        _stockfish.send('go depth 18');
      }
    });

    on<ReceiveHint>((event, emit) {
      Square? from;
      Square? to;
      if (event.move is NormalMove) {
        from = (event.move as NormalMove).from;
        to = (event.move as NormalMove).to;
      }
      emit(state.copyWith(
        isHinting: false,
        hintMoveFrom: from,
        hintMoveTo: to,
      ));
    });

    on<UpdateEvaluation>((event, emit) {
      emit(state.copyWith(
        evaluation: event.evaluation, 
      ));
    });

    on<MovePiece>((event, emit) async {
      if (state.game.isLegal(event.move)) {
        final san = state.game.toSan(event.move);
        Square? from;
        Square? to;
        
        if (event.move is NormalMove) {
          from = (event.move as NormalMove).from;
          to = (event.move as NormalMove).to;
        }
        
        final nextGame = state.game.play(event.move);
        List<Position> newHistory = List.from(state.gameHistory)..add(state.game);
        List<String> newMoveHistory = List.from(state.moveHistory)..add(san);

        if (nextGame.isCheckmate || nextGame.isStalemate) {
           // ELO Calculation — playerSide aware
           int currentElo = settings.playerElo;
           
           // Determine if the PLAYER won or lost
           // nextGame.turn = the side that is checkmated (can't move)
           bool playerWon = nextGame.isCheckmate && nextGame.turn != state.playerSide;
           bool playerLost = nextGame.isCheckmate && nextGame.turn == state.playerSide;
           
           int resultBase;
           if (playerWon) {
             resultBase = 25;
           } else if (playerLost) {
             resultBase = -20;
           } else {
             resultBase = 2; // Stalemate/draw
           }
           
           // Difficulty modifier: beating higher levels = more ELO
           int difficultyMod = 0;
           if (playerWon) {
             difficultyMod = (state.currentLevel - 5).clamp(0, 15); // Bonus for beating tough AI
           } else if (playerLost) {
             difficultyMod = -((10 - state.currentLevel).clamp(0, 10)); // Extra penalty for losing to easy AI
           }
           
           int totalChange = resultBase + difficultyMod;
           
           if (playerLost) {
             totalChange = totalChange.clamp(-50, -5);
           } else if (playerWon) {
             totalChange = totalChange.clamp(5, 50);
           } else {
             totalChange = totalChange.clamp(-5, 5);
           }

           int newElo = (currentElo + totalChange).clamp(100, 3000);
           
           await settings.setPlayerElo(newElo);

           await settings.saveMatch({
             'date': DateTime.now().toIso8601String(),
             'result': nextGame.isCheckmate ? (nextGame.turn == Side.white ? 'Siyah Kazandı' : 'Beyaz Kazandı') : 'Berabere',
             'moves': newMoveHistory.length,
             'fen': nextGame.fen,
             'moveList': newMoveHistory.join(' '),
             'eloChange': totalChange,
             'playerSide': state.playerSide == Side.white ? 'Beyaz' : 'Siyah',
           });

           await settings.clearCurrentGame();

           emit(state.copyWith(
             game: nextGame, 
             isThinking: false, 
             gameHistory: newHistory,
             moveHistory: newMoveHistory,
             lastMoveFrom: from,
             lastMoveTo: to,
             eloChange: totalChange,
             hintMoveFrom: null,
             hintMoveTo: null,
           ));
           return;
        }

        if (san.contains('x')) {
          AudioManager().playCapture();
        } else {
          AudioManager().playMove(event.move, nextGame);
        }

        final opening = _detectOpening(newMoveHistory);

        // Save ongoing game state
        await settings.setCurrentGameFen(nextGame.fen);
        await settings.setCurrentMoveHistory(newMoveHistory);

        emit(state.copyWith(
          game: nextGame, 
          isThinking: nextGame.turn != state.playerSide,
          gameHistory: newHistory,
          moveHistory: newMoveHistory,
          lastMoveFrom: from,
          lastMoveTo: to,
          openingName: opening,
          hintMoveFrom: null,
          hintMoveTo: null,
        ));
        
        if (nextGame.turn != state.playerSide && _stockfish.isReady) {
          final depth = _depthForLevel(state.currentLevel);
          Future.delayed(const Duration(milliseconds: 500), () {
            _stockfish.send('setoption name Skill Level value ${state.currentLevel}');
            _stockfish.send('position fen ${nextGame.fen}');
            _stockfish.send('go depth $depth');
          });
        }
      }
    });

    on<UndoMove>((event, emit) {
      if (state.gameHistory.isNotEmpty) {
        Position prev = state.gameHistory.last;
        List<Position> newHist = List.from(state.gameHistory)..removeLast();
        List<String> newMoveHist = List.from(state.moveHistory)..removeLast();
                // Undo both player and AI moves together
         if (newHist.isNotEmpty && prev.turn != state.playerSide) {
            prev = newHist.last;
            newHist.removeLast();
            newMoveHist.removeLast();
         }
        
        emit(state.copyWith(
          game: prev,
          gameHistory: newHist,
          moveHistory: newMoveHist,
          isThinking: false,
          coachMessage: "Hamle geri alındı.",
          lastMoveFrom: null,
          lastMoveTo: null,
        ));
      }
    });

    on<ResetGame>((event, emit) async {
      await settings.clearCurrentGame();
      
      final playerSideStr = settings.preferredSide;
      Side pSide = Side.white;
      if (playerSideStr == 'black') {
        pSide = Side.black;
      } else if (playerSideStr == 'random') {
        pSide = (DateTime.now().millisecondsSinceEpoch % 2 == 0) ? Side.white : Side.black;
      }

      await settings.setCurrentPlayerSide(pSide == Side.white ? 'white' : 'black');

      final initialGame = Chess.fromSetup(Setup.parseFen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'));

      emit(ChessState(
        game: initialGame,
        currentLevel: settings.isAdaptive 
            ? _mapEloToLevel(settings.playerElo) 
            : settings.manualLevel,
        playerSide: pSide,
      ));

      if (pSide == Side.black && _stockfish.isReady) {
        // Stockfish plays first as white
        emit(state.copyWith(isThinking: true));
        final depth = _depthForLevel(state.currentLevel);
        _stockfish.send('setoption name Skill Level value ${state.currentLevel}');
        _stockfish.send('position fen ${initialGame.fen}');
        _stockfish.send('go depth $depth');
      }
    });

    on<LoadSavedGame>((event, emit) async {
      final fen = settings.currentGameFen;
      final history = settings.currentMoveHistory;
      
      if (fen != null) {
        Position loadedGame;
        try {
          loadedGame = Chess.fromSetup(Setup.parseFen(fen));
        } catch (e) {
          loadedGame = Chess.fromSetup(Setup.parseFen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'));
        }

        final savedSideStr = settings.currentPlayerSide;
        Side pSide = Side.white;
        if (savedSideStr == 'black') {
          pSide = Side.black;
        } else if (savedSideStr == null) {
          // Fallback if null
          if (settings.preferredSide == 'black') pSide = Side.black;
        }

        emit(ChessState(
          game: loadedGame,
          currentLevel: settings.isAdaptive 
              ? _mapEloToLevel(settings.playerElo) 
              : settings.manualLevel,
          moveHistory: history,
          playerSide: pSide,
        ));

        if (loadedGame.turn != pSide && _stockfish.isReady) {
          emit(state.copyWith(isThinking: true));
          final depth = _depthForLevel(state.currentLevel);
          _stockfish.send('setoption name Skill Level value ${state.currentLevel}');
          _stockfish.send('position fen ${loadedGame.fen}');
          _stockfish.send('go depth $depth');
        }
      }
    });
  }


  Move? _parseUci(String uci) {
    if (uci == '(none)') return null;
    if (uci.length < 4) return null;
    
    try {
      final from = Square.fromName(uci.substring(0, 2));
      final to = Square.fromName(uci.substring(2, 4));
      
      Role? promotion;
      if (uci.length == 5) {
        switch (uci[4]) {
          case 'q': promotion = Role.queen; break;
          case 'r': promotion = Role.rook; break;
          case 'b': promotion = Role.bishop; break;
          case 'n': promotion = Role.knight; break;
        }
      }
      
      if (promotion != null) {
        return NormalMove(from: from, to: to, promotion: promotion);
      }
      return NormalMove(from: from, to: to);
    } catch (e) {
      return null;
    }
  }

  String? _detectOpening(List<String> moves) {
    final openings = {
      'e4 e5': 'Açık Oyun',
      'e4 e5 Nf3 Nc6 Bb5': 'İspanyol Açılışı (Ruy Lopez)',
      'e4 e5 Nf3 Nc6 Bc4': 'İtalyan Açılışı',
      'e4 c5': 'Sicilya Savunması',
      'd4 d5': 'Kapalı Oyun',
      'd4 Nf6 c4 e6 Nc3 Bb4': 'Nimzo-Hint Savunması',
      'e4 e6': 'Fransız Savunması',
      'c4': 'İngiliz Açılışı',
      'Nf3': 'Reti Açılışı',
      'e4 d5': 'İskandinav Savunması',
      'd4 d5 c4': 'Vezir Gambiti',
    };

    final fullMoves = moves.join(' ');
    for (var entry in openings.entries) {
      if (fullMoves.startsWith(entry.key)) return entry.value;
    }
    return null;
  }

  static int _mapEloToLevel(int elo) {
    if (elo < 600) return 0;
    if (elo < 800) return 1;
    if (elo < 1000) return 2;
    if (elo < 1200) return 3;
    if (elo < 1400) return 5;
    if (elo < 1600) return 8;
    if (elo < 1800) return 11;
    if (elo < 2000) return 14;
    if (elo < 2200) return 17;
    return 20;
  }

  static int _depthForLevel(int level) {
    // Scale search depth with level so low-level AI truly plays weak
    if (level <= 1) return 3;
    if (level <= 3) return 5;
    if (level <= 5) return 7;
    if (level <= 8) return 9;
    if (level <= 12) return 11;
    if (level <= 16) return 13;
    return 15;
  }

  @override
  Future<void> close() {
    _stockfish.dispose();
    return super.close();
  }
}
