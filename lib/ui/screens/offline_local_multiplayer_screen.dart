// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../widgets/chess_board_widget.dart';
// import '../widgets/pgn_viewer_widget.dart';
// import '../../providers/chess_game_provider.dart';

// class OfflineLocalMultiplayerScreen extends ConsumerWidget {
//   const OfflineLocalMultiplayerScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Local 2-Player Chess'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () =>
//                 ref.read(chessGameProvider.notifier).reset(),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           const Expanded(child: ChessBoardWidget()),
//           const Divider(height: 1),
//           const PgnViewerWidget(),
//         ],
//       ),
//     );
//   }
// }