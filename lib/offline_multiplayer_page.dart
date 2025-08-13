import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

/// Pick a time-control first, then push the real board.
class OfflineMultiplayerPage extends StatelessWidget {
  const OfflineMultiplayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Multiplayer'),
        backgroundColor: Colors.green.shade300,
        elevation: 10,
        centerTitle: true,
      ),
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white, 
              Colors.brown, 
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

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
              'Bullet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 16.0, // space between buttons
              children: [
                _timeButton(context, '1 min', const Duration(minutes: 1)),
                _timeButton(
                  context,
                  '1 | 1',
                  const Duration(minutes: 1),
                  const Duration(seconds: 1),
                ),
                _timeButton(
                  context,
                  '2 | 1',
                  const Duration(minutes: 2),
                  const Duration(seconds: 1),
                ),
              ],
            ),
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
                _timeButton(context, '10 min', const Duration(minutes: 10)),
                _timeButton(
                  context,
                  '15 | 10',
                  const Duration(minutes: 15),
                  const Duration(seconds: 10),
                ),
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
    );
  }

  Widget _timeButton(
  BuildContext context,
  String label,
  Duration baseTime, [
  Duration? increment,
]) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade400,          // brown fill
        foregroundColor: Colors.white,          // white text
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,         // bold text
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 16,
        ),
        elevation: 4,                           // optional: adjust shadow
        shape: RoundedRectangleBorder(         // optional: rounded corners
          borderRadius: BorderRadius.circular( 8),
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
  String _pgn = '';
  @override
  void initState() {
    super.initState();
    _controller = ChessBoardController();
    _whiteTime = _blackTime = widget.baseTime;
    _whiteTurn = true;
    _gameOver = false;
    _whiteTimerActive = true;
    _controller.addListener(_updatePGN);   // listen to moves
    _startTimer();
  }
  String mapToUnicode(String san) {
    const pieceMap = {
    'K': '♔',
    'Q': '♕',
    'R': '♖',
    'B': '♗',
    'N': '♘',
  };
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
          game.turn == _whiteTurn ? 'Player B wins!' : 'Player A wins!');
    } else if (_controller.isStaleMate()|| _controller.isDraw()) {
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

  void _onMove() {
    _updatePGN();  
    _checkGameOver(); 
    if (_gameOver) return;
    setState(() {
      // switch clock
      _whiteTimerActive = !_whiteTimerActive;
      // add increment
      if (_whiteTurn) {
        _blackTime += widget.increment;
      } else {
        _whiteTime += widget.increment;
      }
      _whiteTurn = !_whiteTurn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player A vs Player B',
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
            if(_gameOver)
              Text(
                'Game Over: Player ${_whiteTurn ? 'A' : 'B'} wins!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
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
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600,color: Colors.green),
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