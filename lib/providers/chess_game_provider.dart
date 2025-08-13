// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:chess/chess.dart' as chess;
// import '../models/game_state.dart';

// final chessGameProvider =
// StateNotifierProvider<ChessGameNotifier, GameState>((ref) {
//   final game = chess.Chess();
//   return ChessGameNotifier(
//     GameState(game: game, pgnMoves: []),
//   );
// });

// class ChessGameNotifier extends StateNotifier<GameState> {
//   ChessGameNotifier(super._state);

//   // NEW
//   bool loadFen(String fen) {
//     try {
//       final newGame = chess.Chess.fromFEN(fen);
//       state = state.copyWith(
//         game: newGame,
//         pgnMoves: newGame.pgn().split(' '),
//       );
//       return true;
//     } catch (_) {
//       return false; // illegal FEN
//     }
//   }

//   bool makeMove({required String from, required String to}) {
//     final newGame = chess.Chess.fromFEN(state.game.fen);
//     final move = newGame.move({'from': from, 'to': to});

//     state = state.copyWith(
//       game: newGame,
//       pgnMoves: newGame.pgn().split(' '),
//     );
//     return true;
//   }

//   void reset() {
//     state = GameState(game: chess.Chess(), pgnMoves: []);
//   }
// }