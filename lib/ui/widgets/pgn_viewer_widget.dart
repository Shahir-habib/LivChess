// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../providers/chess_game_provider.dart';

// class PgnViewerWidget extends ConsumerWidget {
//   const PgnViewerWidget({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final pgn = ref.watch(chessGameProvider).pgnMoves;
//     print('PGN: $pgn');
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('PGN:', style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 4),
//             Text(
//               pgn.isEmpty
//                   ? 'No moves yet'
//                   : pgn.join(' '),
//               style: const TextStyle(fontFamily: 'monospace',color: Colors.red),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }