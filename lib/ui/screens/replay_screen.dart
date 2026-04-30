import 'package:flutter/material.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme.dart';

class ReplayScreen extends StatefulWidget {
  final Map<String, dynamic> matchData;

  const ReplayScreen({super.key, required this.matchData});

  @override
  State<ReplayScreen> createState() => _ReplayScreenState();
}

class _ReplayScreenState extends State<ReplayScreen> {
  late Position _currentPosition;
  late List<Move> _parsedMoves;
  int _currentMoveIndex = 0;
  
  Square? _lastMoveFrom;
  Square? _lastMoveTo;

  @override
  void initState() {
    super.initState();
    _currentPosition = Chess.fromSetup(Setup.parseFen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'));
    _parseMoves();
  }

  void _parseMoves() {
    _parsedMoves = [];
    final String moveListStr = widget.matchData['moveList'] ?? '';
    if (moveListStr.isEmpty) return;

    final sanMoves = moveListStr.split(' ');
    Position tempPos = Chess.fromSetup(Setup.parseFen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'));
    
    for (String san in sanMoves) {
      if (san.trim().isEmpty) continue;
      try {
        final move = tempPos.parseSan(san);
        if (move != null) {
          _parsedMoves.add(move);
          tempPos = tempPos.play(move);
        }
      } catch (e) {
        // Failed to parse move
        break;
      }
    }
  }

  void _nextMove() {
    if (_currentMoveIndex < _parsedMoves.length) {
      final move = _parsedMoves[_currentMoveIndex];
      setState(() {
        _currentPosition = _currentPosition.play(move);
        _currentMoveIndex++;
        if (move is NormalMove) {
          _lastMoveFrom = move.from;
          _lastMoveTo = move.to;
        }
      });
    }
  }

  void _prevMove() {
    if (_currentMoveIndex > 0) {
      setState(() {
        _currentMoveIndex--;
        // We have to replay from start up to current index
        _currentPosition = Chess.fromSetup(Setup.parseFen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'));
        _lastMoveFrom = null;
        _lastMoveTo = null;
        for (int i = 0; i < _currentMoveIndex; i++) {
          final move = _parsedMoves[i];
          _currentPosition = _currentPosition.play(move);
          if (move is NormalMove) {
            _lastMoveFrom = move.from;
            _lastMoveTo = move.to;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      appBar: AppBar(
        title: const Text('Maç Tekrarı', style: TextStyle(color: AppTheme.champagneGold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.matchData['result'] ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: _buildBoard(),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: _currentMoveIndex > 0 ? _prevMove : null,
                    icon: const Icon(Icons.skip_previous, size: 36),
                    color: AppTheme.champagneGold,
                    disabledColor: Colors.white10,
                  ),
                  Text(
                    'Hamle: $_currentMoveIndex / ${_parsedMoves.length}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  IconButton(
                    onPressed: _currentMoveIndex < _parsedMoves.length ? _nextMove : null,
                    icon: const Icon(Icons.skip_next, size: 36),
                    color: AppTheme.champagneGold,
                    disabledColor: Colors.white10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoard() {
    return Center(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.champagneGold.withOpacity(0.5), width: 4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
            itemCount: 64,
            itemBuilder: (context, index) {
              int row = index ~/ 8;
              int col = index % 8;
              int chessRank = 7 - row;
              int chessFile = col;
              final square = Square.fromCoords(File(chessFile), Rank(chessRank));
              final piece = _currentPosition.board.pieceAt(square);
              final isLastMove = square == _lastMoveFrom || square == _lastMoveTo;
              bool isLight = (row + col) % 2 == 0;

              return Container(
                color: isLastMove
                    ? Colors.yellow.withOpacity(0.2)
                    : (isLight ? AppTheme.boardLight : AppTheme.boardDark),
                child: Center(
                  child: piece != null
                      ? LayoutBuilder(
                          builder: (context, constraints) {
                            return _getPieceWidget(piece, constraints.maxHeight * 0.85);
                          }
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _getPieceWidget(Piece piece, double size) {
    String name;
    String color = piece.color == Side.white ? 'w' : 'b';
    switch (piece.role) {
      case Role.pawn: name = 'P'; break;
      case Role.knight: name = 'N'; break;
      case Role.bishop: name = 'B'; break;
      case Role.rook: name = 'R'; break;
      case Role.queen: name = 'Q'; break;
      case Role.king: name = 'K'; break;
    }
    return SvgPicture.asset(
      'assets/pieces/$color$name.svg',
      width: size,
      height: size,
    );
  }
}
