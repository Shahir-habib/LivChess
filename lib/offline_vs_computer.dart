import 'package:livchess/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'dart:core';
import 'package:chess/chess.dart' as chess;

extension Uci on chess.Move {
  String toUci(chess.Chess game) {
    final fromSq = chess.Chess.algebraic(from); // e.g., "e2"
    final toSq = chess.Chess.algebraic(to); // e.g., "e4"
    final promo = promotion ?? ''; // "q","r","b","n" or ""
    return '$fromSq$toSq$promo';
  }
}

/// ------------------------------------------------------------------
///  Evaluation helpers
/// ------------------------------------------------------------------
const _pieceValue = {
  'p': 100,
  'n': 320,
  'b': 330,
  'r': 500,
  'q': 900,
  'k': 20000,
};

const _pawnTable = [
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  50,
  50,
  50,
  50,
  50,
  50,
  50,
  50,
  10,
  10,
  20,
  30,
  30,
  20,
  10,
  10,
  5,
  5,
  10,
  25,
  25,
  10,
  5,
  5,
  0,
  0,
  0,
  20,
  20,
  0,
  0,
  0,
  5,
  -5,
  -10,
  0,
  0,
  -10,
  -5,
  5,
  5,
  10,
  10,
  -20,
  -20,
  10,
  10,
  5,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
];

const _knightTable = [
  -50,
  -40,
  -30,
  -30,
  -30,
  -30,
  -40,
  -50,
  -40,
  -20,
  0,
  5,
  5,
  0,
  -20,
  -40,
  -30,
  0,
  10,
  15,
  15,
  10,
  0,
  -30,
  -30,
  0,
  15,
  20,
  20,
  15,
  5,
  -30,
  -30,
  0,
  15,
  20,
  20,
  15,
  5,
  -30,
  -30,
  0,
  10,
  15,
  15,
  10,
  0,
  -30,
  -40,
  -20,
  0,
  0,
  0,
  0,
  -20,
  -40,
  -50,
  -40,
  -30,
  -30,
  -30,
  -30,
  -40,
  -50,
];

const _bishopTable = [
  -20,
  -10,
  -10,
  -10,
  -10,
  -10,
  -10,
  -20,
  -10,
  5,
  0,
  0,
  0,
  0,
  5,
  -10,
  -10,
  10,
  10,
  10,
  10,
  10,
  10,
  -10,
  -10,
  0,
  10,
  10,
  10,
  10,
  0,
  -10,
  -10,
  5,
  5,
  10,
  10,
  5,
  5,
  -10,
  -10,
  0,
  5,
  10,
  10,
  5,
  0,
  -10,
  -10,
  0,
  0,
  0,
  0,
  0,
  0,
  -10,
  -20,
  -10,
  -10,
  -10,
  -10,
  -10,
  -10,
  -20,
];

const _rookTable = [
  0,
  0,
  0,
  5,
  5,
  0,
  0,
  0,
  -5,
  0,
  0,
  0,
  0,
  0,
  0,
  -5,
  -5,
  0,
  0,
  0,
  0,
  0,
  0,
  -5,
  -5,
  0,
  0,
  0,
  0,
  0,
  0,
  -5,
  -5,
  0,
  0,
  0,
  0,
  0,
  0,
  -5,
  -5,
  0,
  0,
  0,
  0,
  0,
  0,
  -5,
  5,
  10,
  10,
  10,
  10,
  10,
  10,
  5,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
];

const _queenTable = [
  -20,
  -10,
  -10,
  -5,
  -5,
  -10,
  -10,
  -20,
  -10,
  0,
  5,
  0,
  0,
  0,
  0,
  -10,
  -10,
  5,
  5,
  5,
  5,
  5,
  0,
  -10,
  0,
  0,
  5,
  5,
  5,
  5,
  0,
  -5,
  -5,
  0,
  5,
  5,
  5,
  5,
  0,
  -5,
  -10,
  0,
  5,
  5,
  5,
  5,
  0,
  -10,
  -10,
  0,
  0,
  0,
  0,
  0,
  0,
  -10,
  -20,
  -10,
  -10,
  -5,
  -5,
  -10,
  -10,
  -20,
];
const _kingTable = [
  -30,
  -40,
  -40,
  -50,
  -50,
  -40,
  -40,
  -30,
  -30,
  -40,
  -40,
  -50,
  -50,
  -40,
  -40,
  -30,
  -30,
  -40,
  -40,
  -50,
  -50,
  -40,
  -40,
  -30,
  -30,
  -40,
  -40,
  -50,
  -50,
  -40,
  -40,
  -30,
  -20,
  -30,
  -30,
  -40,
  -40,
  -30,
  -30,
  -20,
  -10,
  -20,
  -20,
  -20,
  -20,
  -20,
  -20,
  -10,
  20,
  20,
  0,
  0,
  0,
  0,
  20,
  20,
  20,
  30,
  10,
  0,
  0,
  10,
  30,
  20,
];
const _kingEndgameTable = [
  -50,
  -30,
  -30,
  -30,
  -30,
  -30,
  -30,
  -50,
  -30,
  -10,
  0,
  10,
  10,
  0,
  -10,
  -30,
  -30,
  -5,
  20,
  30,
  30,
  20,
  -5,
  -30,
  -30,
  -5,
  30,
  40,
  40,
  30,
  -5,
  -30,
  -30,
  -5,
  30,
  40,
  40,
  30,
  -5,
  -30,
  -30,
  -5,
  20,
  30,
  30,
  20,
  -5,
  -30,
  -30,
  -10,
  0,
  10,
  10,
  0,
  -10,
  -30,
  -50,
  -30,
  -30,
  -30,
  -30,
  -30,
  -30,
  -50,
];

double _evalPosition(chess.Chess game) {
  double score = 0.0;
  for (var sq = 0; sq < 64; sq++) {
    int row = sq ~/ 8;
    int col = sq % 8;
    final p = game.board[row * 16 + col];
    if (p == null) continue;
    final color = p.color == chess.Color.WHITE ? 1 : -1;
    String tpe = '';
    switch (p.type) {
      case chess.PieceType.PAWN:
        tpe = 'p';
        break;
      case chess.PieceType.KNIGHT:
        tpe = 'n';
        break;
      case chess.PieceType.BISHOP:
        tpe = 'b';
        break;
      case chess.PieceType.ROOK:
        tpe = 'r';
        break;
      case chess.PieceType.QUEEN:
        tpe = 'q';
        break;
      case chess.PieceType.KING:
        tpe = 'k';
        break;
    }
    final val = _pieceValue[tpe]!;
    var pst = 0;
    if (p.type == chess.PieceType.PAWN) {
      pst = _pawnTable[p.color == chess.Color.WHITE ? sq : 63 - sq];
    } else if (p.type == chess.PieceType.KNIGHT) {
      pst = _knightTable[p.color == chess.Color.WHITE ? sq : 63 - sq];
    } else if (p.type == chess.PieceType.BISHOP) {
      pst = _bishopTable[p.color == chess.Color.WHITE ? sq : 63 - sq];
    } else if (p.type == chess.PieceType.ROOK) {
      pst = _rookTable[p.color == chess.Color.WHITE ? sq : 63 - sq];
    } else if (p.type == chess.PieceType.QUEEN) {
      pst = _queenTable[p.color == chess.Color.WHITE ? sq : 63 - sq];
    } else if (p.type == chess.PieceType.KING) {
      pst = _kingTable[p.color == chess.Color.WHITE ? sq : 63 - sq];
    }
    score += color * (val + pst);
  }
  score = score / 100.0;
  return game.turn == chess.Color.WHITE ? score : -score;
}

/// ------------------------------------------------------------------
///  Move ordering
/// -------------------------------------------------------------------
int _scoreMove(chess.Move move, chess.Chess game) {
  //uci like 'e2e4' or 'e7e8q' (promotion handled by the library)
  final from = move.from;
  final to = move.to;

  // Get verbose moves from the 'from' square to find the exact move object.
  Map<dynamic, dynamic> obj = {'square': from, 'verbose': true};
  final moves = game.moves(obj);

  Map<String, dynamic>? matched;
  for (final m in moves.cast<Map<String, dynamic>>()) {
    if (m['from'] == from && m['to'] == to) {
      matched = m;
      break;
    }
  }

  final captured = matched?['captured'] as String?;
  if (captured != null) {
    return 10 * _pieceValue[captured]!;
  }
  return 0;
}

/// ------------------------------------------------------------------
///  Alpha-Beta search
/// -------------------------------------------------------------------
double _alphaBeta(chess.Chess game, int depth, double alpha, double beta) {
  if (depth == 0) return _evalPosition(game);

  final moves = game.generate_moves();
  if (moves.isEmpty) {
    return game.in_check ? -30000.0 + game.half_moves : 0.0;
  }

  // move ordering: captures first
  moves.sort((a, b) => _scoreMove(b, game).compareTo(_scoreMove(a, game)));

  for (final m in moves) {
    game.make_move(m);
    final inCheck = game.in_check;
    final newDepth = (inCheck && depth < 15) ? depth + 1 : depth;
    final score = -_alphaBeta(game, newDepth - 1, -beta, -alpha);
    game.undo_move();
    if (score >= beta) return beta; // cutoff
    if (score > alpha) alpha = score;
  }
  return alpha;
}

/// ------------------------------------------------------------------
///  Iterative deepening driver
/// ------------------------------------------------------------------
Future<dynamic> search(chess.Chess game, {int depth = 4}) async {
  print('Searching for best move at depth $depth');
  print('Current position: ${game.fen}');

  dynamic best;
  double bestScore = -999999.0;

  final moves = game.generate_moves();
  if (moves.isEmpty) throw Exception('no moves');

  // iterative deepening
  for (int d = 1; d <= depth; d++) {
    for (final m in moves) {
      game.make_move(m);
      final score = -_alphaBeta(game, d - 1, -30000, 30000);
      game.undo_move();
      if (score > bestScore) {
        bestScore = score;
        best = m;
      }
    }
  }
  return best!;
}

class OfflineVsComputerPage extends StatelessWidget {
  const OfflineVsComputerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Offline vs Computer',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: Colors.greenAccent.shade400,
        elevation: 8,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
      ),
      body: Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [c1, c2, c3],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Choose Time Control',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Blitz Section
              const Text(
                'Blitz',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16.0, // space between buttons

                children: [
                  _timeButton(context, '3 min', const Duration(minutes: 3)),
                  _timeButton(
                    context,
                    '3 | 2',
                    const Duration(minutes: 3),
                    const Duration(seconds: 2),
                  ),
                  _timeButton(context, '5 min', const Duration(minutes: 5)),
                ],
              ),

              const SizedBox(height: 20),

              // Rapid Section
              const Text(
                'Rapid',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16.0, // space between buttons
                children: [
                  _timeButton(context, '10', const Duration(minutes: 10)),
                  _timeButton(context, '15 min', const Duration(minutes: 15)),
                  _timeButton(context, '30', const Duration(minutes: 30)),
                ],
              ),

              const SizedBox(height: 20),

              // Classical Section
              const Text(
                'Classical',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16.0, // space between buttons

                children: [
                  _timeButton(context, '60 min', const Duration(minutes: 60)),
                  _timeButton(context, '90 min', const Duration(minutes: 90)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeButton(
    BuildContext context,
    String label,
    Duration baseTime, [
    Duration? increment,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [b1, b2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BoardScreen(
                baseTime: baseTime,
                increment: increment ?? Duration.zero,
              ),
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

/// Actual board screen with clocks above the chessboard.
class BoardScreen extends StatefulWidget {
  final Duration baseTime;
  final Duration increment;

  const BoardScreen({
    super.key,
    required this.baseTime,
    required this.increment,
  });

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  late ChessBoardController _controller;
  late Duration _whiteTime, _blackTime;
  late bool _whiteTurn;
  late bool _gameOver;
  late bool _whiteTimerActive;
  late bool _blackTimerActive;
  String _pgn = '';
  @override
  void initState() {
    super.initState();

    _controller = ChessBoardController();
    _whiteTime = _blackTime = widget.baseTime;
    _whiteTurn = true;
    _gameOver = false;
    _whiteTimerActive = true;
    _blackTimerActive = false;
    _controller.addListener(_updatePGN); // listen to moves
    _startTimer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String mapToUnicode(String san) {
    const pieceMap = {'K': '♔', 'Q': '♕', 'R': '♖', 'B': '♗', 'N': '♘'};
    // Replace every piece letter with its Unicode symbol
    return san.split('').map((c) {
      return pieceMap[c] ?? c;
    }).join();
  }

  void _updatePGN() {
    final san = mapToUnicode(_controller.getSan().join(' '));
    setState(() => _pgn = san);
  }

  // inside _BoardScreenState
  void _checkGameOver() {
    // time loss
    if (_whiteTime.inSeconds <= 0) {
      _showGameOverDialog('Player B wins on time!');
      return;
    }
    if (_blackTime.inSeconds <= 0) {
      _showGameOverDialog('Player A wins on time!');
      return;
    }

    // checkmate / stalemate / draw
    final game = _controller.game;
    if (_controller.isCheckMate()) {
      _showGameOverDialog(
        game.turn == _whiteTurn ? 'Player B wins!' : 'Player A wins!',
      );
    } else if (_controller.isStaleMate() || _controller.isDraw()) {
      _showGameOverDialog('Draw');
    }
  }

  void _showGameOverDialog(String result) {
    _gameOver = true;
    final pgn = _controller.getSan().join(' ');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverDialog(result: result, pgn: pgn),
    );
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_gameOver) return;
      setState(() {
        if (_whiteTimerActive) {
          _whiteTime -= const Duration(seconds: 1);
          if (_whiteTime.inSeconds <= 0) _gameOver = true;
        } else {
          _blackTime -= const Duration(seconds: 1);
          if (_blackTime.inSeconds <= 0) _gameOver = true;
        }
      });
      _checkGameOver();
      if (!_gameOver) _startTimer();
    });
  }

  // Top-level function for isolate computation
Future<Map<String, dynamic>?> findBestMove(Map<String, dynamic> args) async {
  final String fen = args['fen'];
  final int depth = args['depth'];
  final game = chess.Chess.fromFEN(fen);
  // No need to set game.turn as it's already set from FEN
  // Assuming search is synchronous and computationally intensive
  final bestMove = await search(game, depth: depth);
  if (bestMove == null) return null;
  return {
    'from': bestMove.from,
    'to': bestMove.to,
    // Add 'promotion': bestMove.promotion if your Move class supports it and it's needed
  };
}
  Future<void> _onMove() async {
  // 1) Human just moved
  _updatePGN();
  _checkGameOver();
  if (_gameOver) return;
  // 2) Stop human clock, start engine clock
  setState(() {
    // Human just moved, so stop their clock and start engine's clock
    if (_whiteTurn) {
      // White (human) just played, add increment to white, switch to black (engine)
      _whiteTime += widget.increment;
      _whiteTimerActive = false; // Stop white clock
      _blackTimerActive = true; // Start black clock (engine)
    } else {
      // Black (human) just played, add increment to black, switch to white (engine)
      _blackTime += widget.increment;
      _blackTimerActive = false; // Stop black clock
      _whiteTimerActive = true; // Start white clock (engine)
    }
    _whiteTurn = !_whiteTurn; // Switch turn
  }); // ← this flips _whiteTimerActive

  // 3) Let engine think in an isolate to avoid UI freeze
  final fen = _controller.getFen();
  final stopwatch = Stopwatch()..start();
  Map<String, dynamic>? moveMap;
  try {
    moveMap = await findBestMove({'fen': fen, 'depth': 4});
  } catch (e) {
    print('Error in engine search: $e');
    return;
  }
  stopwatch.stop();
  print(chess.Chess.algebraic(moveMap?['from']));
  print(chess.Chess.algebraic(moveMap?['to']));
  const minThinkingTime = 500;
  if (stopwatch.elapsedMilliseconds < minThinkingTime) {
    await Future.delayed(
      Duration(milliseconds: minThinkingTime - stopwatch.elapsedMilliseconds),
    );
  }

  // 4) Engine plays
  if (!_gameOver && moveMap != null) {
    try {
      _controller.makeMove(
        from: chess.Chess.algebraic(moveMap['from']),
        to: chess.Chess.algebraic(moveMap['to']),
      );
      _updatePGN();
      _checkGameOver();
    } catch (e) {
      print('Error making engine move: $e');
      return;
    }
  }

  // 5) Stop engine clock, start human clock again
  if (!_gameOver) {
    setState(() {
      // Engine just moved, so stop engine clock and start human clock
      if (_whiteTurn) {
        // White (engine) just played, add increment to white, switch to black (human)
        _whiteTime += widget.increment;
        _whiteTimerActive = false; // Stop white clock (engine)
        _blackTimerActive = true; // Start black clock (human)
      } else {
        // Black (engine) just played, add increment to black, switch to white (human)
        _blackTime += widget.increment;
        _blackTimerActive = false; // Stop black clock (engine)
        _whiteTimerActive = true; // Start white clock (human)
      }
      _whiteTurn = !_whiteTurn; // Switch turn back to human
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Player vs Computer',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Top clock (Black – Player B)
            _ClockRow(
              name: 'Player B',
              time: _blackTime,
              active: !_whiteTimerActive && !_gameOver,
            ),

            const SizedBox(height: 8),

            // Chessboard
            Expanded(
              child: ChessBoard(
                controller: _controller,
                // boardOrientation: _whiteTurn
                //     ? PlayerColor.white
                //     : PlayerColor.black, // keeps white at bottom
                onMove: _onMove,
              ),
            ),
            if (_gameOver)
              Text(
                'Game Over: Player ${_whiteTurn ? 'A' : 'B'} wins!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            const SizedBox(height: 8),
            _PgnBar(pgn: _pgn),
            // Bottom clock (White – Player A)
            _ClockRow(
              name: 'Player A',
              time: _whiteTime,
              active: _whiteTimerActive && !_gameOver,
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal PGN viewer
class _PgnBar extends StatelessWidget {
  final String pgn;
  const _PgnBar({required this.pgn});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          pgn.isEmpty ? 'Game started: make a move' : pgn,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}

/// Re-usable row showing name and remaining time.
class _ClockRow extends StatelessWidget {
  final String name;
  final Duration time;
  final bool active;

  const _ClockRow({
    required this.name,
    required this.time,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = time.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = time.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: active ? Colors.green.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Text(
            '$minutes:$seconds',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class GameOverDialog extends StatelessWidget {
  final String result;
  final String pgn;

  const GameOverDialog({super.key, required this.result, required this.pgn});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(result, style: const TextStyle(fontSize: 22)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('PGN (tap to copy):'),
            const SizedBox(height: 8),
            SelectableText(
              pgn,
              style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.content_copy),
          label: const Text('Copy PGN'),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: pgn));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PGN copied to clipboard')),
            );
          },
        ),
      ],
    );
  }
}
