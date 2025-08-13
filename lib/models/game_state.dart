import 'package:chess/chess.dart' as chess;

class GameState {
  final chess.Chess game;
  final List<String> pgnMoves;

  GameState({required this.game, required this.pgnMoves});

  GameState copyWith({chess.Chess? game, List<String>? pgnMoves}) =>
      GameState(
        game: game ?? this.game,
        pgnMoves: pgnMoves ?? this.pgnMoves,
      );
}