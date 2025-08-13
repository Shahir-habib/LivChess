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


Future<void> main() async {
  chess.Chess game = chess.Chess();
  game = chess.Chess.fromFEN("1k4r1/1Bp4p/1p2p3/n7/P2P1n1q/2P2Q2/3N1PP1/R4RK1 b - - 4 25");
  int score = _evalPosition(game);
  print("Position score: ${score/100}");
  chess.Move bestMove = await search(game,depth: 3);
  print("Best move: ${chess.Chess.algebraic(bestMove.from) } -> ${chess.Chess.algebraic(bestMove.to)} ");

  // final game = chess.Chess();       // New game from starting position
  // const int maxPly = 100;           // Stop after 100 half-moves
  // const int depth = 5;              // Search depth for both sides
  // int ply = 0;

  // while (!game.game_over && ply < maxPly) {
  //   // 1) Print board and side to move
  //   stdout.writeln('\n${game.ascii}');
  //   stdout.writeln(
  //     '${game.turn == chess.Color.WHITE ? 'White' : 'Black'} to move...'
  //   );

  //   // 2) Time the search
  //   final start = DateTime.now();
  //   // Pass a clone if your search mutates the board internally
  //   chess.Move bestMove = await search(game, depth: depth);
  //   final elapsed = DateTime.now().difference(start);

  //   // 3) Play the move on the real game
  //   final uci = bestMove.toUci(game);
  //   game.move(bestMove);

  //   // 4) Report and delay
  //   stdout.writeln(
  //     '${game.turn == chess.Color.BLACK ? 'White' : 'Black'} plays $uci'
  //     '(${bestMove.piece.name}) in ${elapsed.inSeconds}.${(elapsed.inMilliseconds % 1000).toString().padLeft(3, '0')}s'
  //   );
  //   //await Future.delayed(const Duration(seconds: 3));

  //   ply++;
  // }

  // // Final result
  // stdout.writeln('\n=== Game Over ===');      // e.g., "1-0", "0-1", "1/2-1/2"
  // stdout.writeln('PGN:\n${game.pgn()}');
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

int _evalPosition(chess.Chess game) {
  int score = 0;
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
/// ------------------------------------------------------------------
int _alphaBeta(chess.Chess game, int depth, int alpha, int beta) {
  if (depth == 0) return _evalPosition(game);

  final moves = game.generate_moves();
  if (moves.isEmpty) {
    return game.in_check ? -30000 + game.half_moves : 0;
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
  dynamic best;
  int bestScore = -999999;

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
