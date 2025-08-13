// import 'package:flutter/material.dart';
// import 'package:flutter_chess_board/flutter_chess_board.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../providers/chess_game_provider.dart';

// class ChessBoardWidget extends ConsumerStatefulWidget {
//   const ChessBoardWidget({super.key});

//   @override
//   ConsumerState<ChessBoardWidget> createState() => _ChessBoardWidgetState();
// }

// class _ChessBoardWidgetState extends ConsumerState<ChessBoardWidget> {
//   late final ChessBoardController _controller;
//   String _lastFen = '';

//   @override
//   void initState() {
//     super.initState();
//     _controller = ChessBoardController();
//     _lastFen = _controller.game.fen;
//     _controller.addListener(_onControllerChange);
//   }

//   @override
//   void dispose() {
//     _controller.removeListener(_onControllerChange);
//     super.dispose();
//   }

//   void _onControllerChange() {
//     final currentFen = _controller.game.fen;
//     if (currentFen == _lastFen) return; // nothing actually changed

//     // Ask the provider to accept the new FEN
//     final accepted = ref.read(chessGameProvider.notifier).loadFen(currentFen);
//     if (!accepted) {
//       // illegal move – revert the controller to the last legal FEN
//       _controller.loadFen(_lastFen);
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('Illegal move')));
//     } else {
//       _lastFen = currentFen;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final fen = ref.watch(chessGameProvider).game.fen;
//     if (_controller.game.fen != fen) _controller.loadFen(fen);



//     return ChessBoard(
//       controller: _controller,
//       boardColor: BoardColor.green,
//       boardOrientation: PlayerColor.white,
//       enableUserMoves: true,
//       onMove: () {}, // required by package; listener does the work
//     );
//   }
// }