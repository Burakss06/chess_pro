import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme.dart';
import '../../bloc/chess_bloc.dart';
import '../../logic/settings_repository.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Square? selectedSquare;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.obsidian, AppTheme.deepCharcoal],
          ),
        ),
        child: SafeArea(
          child: BlocListener<ChessBloc, ChessState>(
            listenWhen: (previous, current) => 
                previous.game.isCheckmate != current.game.isCheckmate || 
                previous.game.isStalemate != current.game.isStalemate,
            listener: (context, state) {
              if (state.game.isCheckmate || state.game.isStalemate) {
                _showGameOverDialog(context, state);
              }
            },
            child: BlocBuilder<ChessBloc, ChessState>(
            builder: (context, state) {
              return Row(
                children: [
                  // Center: Chess Board
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildHeader(state),
                        Expanded(child: _buildBoard(state)),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  
                  // Right Panel: Info and Moves
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 24, bottom: 8),
                            child: Text('MAÇ PANELİ', style: TextStyle(color: AppTheme.champagneGold, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 2)),
                          ),
                          if (state.openingName != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                state.openingName!,
                                style: const TextStyle(color: Colors.white30, fontSize: 11, fontStyle: FontStyle.italic),
                              ),
                            ),
                          const Divider(color: Colors.white10),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: (state.moveHistory.length / 2).ceil(),
                              itemBuilder: (context, index) {
                                final moveNum = index + 1;
                                final whiteMove = state.moveHistory[index * 2];
                                final blackMove = (index * 2 + 1 < state.moveHistory.length) ? state.moveHistory[index * 2 + 1] : '';
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 24, child: Text('$moveNum.', style: const TextStyle(color: Colors.white24, fontSize: 12))),
                                      Expanded(child: Text(whiteMove, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500))),
                                      Expanded(child: Text(blackMove, style: const TextStyle(color: Colors.white70))),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          _buildControlPanel(state),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
           ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ChessState state) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ChessPro',
                style: TextStyle(
                  color: AppTheme.champagneGold,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Text(
                state.isThinking ? 'Stockfish Düşünüyor...' : 'Sıra Sende',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(ChessState state) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.champagneGold.withOpacity(0.5), width: 4),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppTheme.champagneGold.withOpacity(0.05),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
            itemCount: 64,
            itemBuilder: (context, index) {
              int row = index ~/ 8;
              int col = index % 8;
              
              if (state.playerSide == Side.black) {
                row = 7 - row;
                col = 7 - col;
              }
              
              int chessRank = 7 - row;
              int chessFile = col;
              final square = Square.fromCoords(File(chessFile), Rank(chessRank));
              final piece = state.game.board.pieceAt(square);
              final isSelected = selectedSquare == square;
              final isLastMove = square == state.lastMoveFrom || square == state.lastMoveTo;
              final isHintMove = square == state.hintMoveFrom || square == state.hintMoveTo;
              
              bool isLight = ((index ~/ 8) + (index % 8)) % 2 == 0;
              final boardTheme = context.read<SettingsRepository>().boardTheme;
              
              bool isLegalMove = false;
              if (selectedSquare != null && state.game.turn == state.playerSide) {
                final move = NormalMove(from: selectedSquare!, to: square);
                final promoMove = NormalMove(from: selectedSquare!, to: square, promotion: Role.queen);
                if (state.game.isLegal(move) || state.game.isLegal(promoMove)) {
                  isLegalMove = true;
                }
              }

              return GestureDetector(
                onTap: () => _handleSquareTap(square, state),
                child: Container(
                  color: isSelected 
                    ? AppTheme.champagneGold.withOpacity(0.6) 
                    : isHintMove
                      ? Colors.cyanAccent.withOpacity(0.4)
                      : isLastMove
                        ? Colors.yellow.withOpacity(0.2)
                        : (isLight ? AppTheme.getLightSquare(boardTheme) : AppTheme.getDarkSquare(boardTheme)),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isLegalMove)
                          piece != null 
                            ? Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black.withOpacity(0.2), width: 4),
                                  shape: BoxShape.circle,
                                ),
                              )
                            : Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                        if (piece != null)
                          LayoutBuilder(
                              builder: (context, constraints) {
                                return _getPieceWidget(piece, constraints.maxHeight * 0.85);
                              }
                          ),
                      ],
                    ),
                  ),
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

  void _handleSquareTap(Square square, ChessState state) async {
    if (state.isThinking) return;

    if (selectedSquare == null) {
      final piece = state.game.board.pieceAt(square);
      if (piece != null && piece.color == state.game.turn) {
        setState(() {
          selectedSquare = square;
        });
      }
    } else {
      if (selectedSquare == square) {
        setState(() { selectedSquare = null; });
        return;
      }

      final piece = state.game.board.pieceAt(selectedSquare!);
      bool isPromotion = false;
      
      if (piece?.role == Role.pawn && (square.rank == Rank.eighth || square.rank == Rank.first)) {
        // Check if moving to this square with a Queen promotion would be legal
        final testMove = NormalMove(from: selectedSquare!, to: square, promotion: Role.queen);
        if (state.game.isLegal(testMove)) {
          isPromotion = true;
        }
      }

      if (isPromotion) {
        final role = await _showPromotionDialog();
        if (role != null) {
          final move = NormalMove(from: selectedSquare!, to: square, promotion: role);
          context.read<ChessBloc>().add(MovePiece(move));
        }
      } else {
        final move = NormalMove(from: selectedSquare!, to: square);
        if (state.game.isLegal(move)) {
          context.read<ChessBloc>().add(MovePiece(move));
        }
      }

      setState(() {
        selectedSquare = null;
      });
    }
  }

  Future<Role?> _showPromotionDialog() async {
    return showDialog<Role>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final prefix = context.read<ChessBloc>().state.playerSide == Side.white ? 'w' : 'b';
        return AlertDialog(
          backgroundColor: AppTheme.deepCharcoal,
          title: const Text('Terfi Seçimi', style: TextStyle(color: AppTheme.champagneGold)),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPromotionOption(Role.queen, '${prefix}Q.svg'),
              _buildPromotionOption(Role.rook, '${prefix}R.svg'),
              _buildPromotionOption(Role.bishop, '${prefix}B.svg'),
              _buildPromotionOption(Role.knight, '${prefix}N.svg'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPromotionOption(Role role, String asset) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(role),
      child: SvgPicture.asset(
        'assets/pieces/$asset',
        width: 50,
        height: 50,
      ),
    );
  }

  Widget _buildControlPanel(ChessState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.glassWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(Icons.undo, "Geri Al", () {
                  context.read<ChessBloc>().add(UndoMove());
                }),
                _buildActionButton(
                  state.isHinting ? Icons.hourglass_empty : Icons.lightbulb, 
                  state.isHinting ? "Düşünüyor..." : "İpucu", 
                  () {
                    if (!state.isHinting) {
                      context.read<ChessBloc>().add(RequestHint());
                    }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.champagneGold),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, ChessState state) {
    final eloStr = state.eloChange != null ? (state.eloChange! >= 0 ? '+${state.eloChange}' : '${state.eloChange}') : '';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.deepCharcoal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Text(
              state.game.isCheckmate ? 'Mat!' : 'Berabere!',
              style: const TextStyle(color: AppTheme.champagneGold, fontWeight: FontWeight.bold, fontSize: 24),
            ),
            if (state.eloChange != null)
              Text(
                'ELO: $eloStr',
                style: TextStyle(
                  color: state.eloChange! >= 0 ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 16,
                ),
              ),
          ],
        ),
        content: Text(
          state.game.isCheckmate 
              ? (state.game.turn == state.playerSide ? 'Stockfish yine affetmedi!' : 'Tebrikler, kazandın!')
              : 'Oyun bitti, yenişemediniz.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to menu
                },
                child: const Text('Menüye Dön', style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.champagneGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<ChessBloc>().add(ResetGame());
                  setState(() { selectedSquare = null; });
                },
                child: const Text('Yeni Oyun', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
