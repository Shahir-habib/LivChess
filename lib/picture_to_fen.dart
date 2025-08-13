import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as imglib;
import 'package:tensorflow_lite_flutter/tensorflow_lite_flutter.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:livchess/global.dart';
import 'package:path_provider/path_provider.dart';

const List<String> classNames = [
  'dark_bishop',
  'dark_king',
  'dark_knight',
  'dark_pawn',
  'dark_queen',
  'dark_rook',
  'empty',
  'empty',
  'light_bishop',
  'light_king',
  'light_knight',
  'light_pawn',
  'light_queen',
  'light_rook',
];

const Map<String, String> pieceToFen = {
  'dark_bishop': 'b',
  'dark_king': 'k',
  'dark_knight': 'n',
  'dark_pawn': 'p',
  'dark_queen': 'q',
  'dark_rook': 'r',
  'empty': '1',
  'light_bishop': 'B',
  'light_king': 'K',
  'light_knight': 'N',
  'light_pawn': 'P',
  'light_queen': 'Q',
  'light_rook': 'R',
};

Future<void> loadModel() async {
  try {
    String? result = await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
      numThreads: 2,
      isAsset: true,
      useGpuDelegate: false,
    );
    print('Model loaded successfully: $result');
  } catch (e) {
    print('Failed to load model: $e');
  }
}

Future<void> disposeModel() async {
  await Tflite.close();
  print('Model resources released');
}

class PictureToFENPage extends StatefulWidget {
  const PictureToFENPage({super.key});

  @override
  State<PictureToFENPage> createState() => _PictureToFENPageState();
}

class _PictureToFENPageState extends State<PictureToFENPage> {
  File? _image;
  String _fen = '';
  bool _loading = false;
  String _errorMessage = '';

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _fenController = TextEditingController();
  ChessBoardController? _boardController;

  @override
  void initState() {
    super.initState();
    loadModel();
    _fenController.addListener(_updateBoardFromText);
  }

  void _updateBoardFromText() {
    if (_fenController.text.isNotEmpty) {
      try {
        setState(() {
          _boardController = ChessBoardController.fromFEN(_fenController.text);
          _errorMessage = '';
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Invalid FEN notation';
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _loading = true;
        _errorMessage = '';
        _fen = '';
        _fenController.clear();
        _image = null;
        _boardController = null;
      });

      final XFile? picked = await _picker.pickImage(source: source);
      if (picked == null) {
        setState(() {
          _loading = false;
        });
        return;
      }

      final file = File(picked.path);
      setState(() {
        _image = file;
      });

      print('Processing image: ${file.path}');

      // Generate FEN from the image
      final String? generatedFen = await generateFEN(file.path);

      if (generatedFen != null && generatedFen.isNotEmpty) {
        setState(() {
          _fen = generatedFen;
          _fenController.text = generatedFen;
          _loading = false;
        });
        print('FEN successfully generated: $generatedFen');
      } else {
        setState(() {
          _errorMessage = 'Failed to generate FEN from image';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error processing image: $e';
        _loading = false;
      });
      print('Error in _pickImage: $e');
    }
  }

  Future<String?> generateFEN(String imagePath) async {
    try {
      // Load the image using the image package
      final originalImageBytes = await File(imagePath).readAsBytes();
      imglib.Image? image = imglib.decodeImage(originalImageBytes);

      if (image == null) {
        print('Error loading image');
        return null;
      }

      // Make image square
      int boardSize = min(image.width, image.height);
      image = imglib.copyResize(image, width: boardSize, height: boardSize);

      int squareSize = boardSize ~/ 8;

      // Get temporary directory for saving cropped squares
      final tempDir = await getTemporaryDirectory();

      // 8x8 board representation
      List<List<String>> board = [];

      for (int row = 0; row < 8; row++) {
        List<String> rowPieces = [];
        for (int col = 0; col < 8; col++) {
          // Crop the square
          imglib.Image croppedSquare = imglib.copyCrop(
            image,
            col * squareSize,
            row * squareSize,
            squareSize,
            squareSize,
          );

          // Save cropped image to temp file
          String tempPath = '${tempDir.path}/square_${row}_$col.jpg';
          await File(tempPath).writeAsBytes(imglib.encodeJpg(croppedSquare));

          // Run model on the cropped square
          List? recognitions = await Tflite.runModelOnImage(
            path: tempPath,
            imageMean: 0.0,
            imageStd: 1.0,
            numResults: 1,
            threshold: 0.1,
            asynch: true,
          );

          String piece = '';
          if (recognitions != null && recognitions.isNotEmpty) {
            String label = recognitions[0]['label'];
            if (label != 'empty' && label != '6' && label != '7') { // Handle empty squares
              piece = label;
            }
          }

          rowPieces.add(piece);

          // Delete temp file to save space
          try {
            await File(tempPath).delete();
          } catch (e) {
            print('Could not delete temp file: $e');
          }
        }
        board.add(rowPieces);
      }

      // Build the FEN board position string
      String position = '';
      for (var row in board) {
        int emptyCount = 0;
        for (var piece in row) {
          if (piece.isEmpty) {
            emptyCount++;
          } else {
            if (emptyCount > 0) {
              position += emptyCount.toString();
              emptyCount = 0;
            }
            position += pieceToFen[piece] ?? piece;
          }
        }
        if (emptyCount > 0) {
          position += emptyCount.toString();
        }
        position += '/';
      }
      position = position.substring(0, position.length - 1); // Remove trailing '/'

      // Complete FEN with defaults
      String fen = '$position w KQkq - 0 1';

      print('Generated FEN: $fen');
      return fen;
    } catch (e) {
      print('Error generating FEN: $e');
      return null;
    }
  }

  @override
  void dispose() {
    disposeModel();
    _fenController.dispose();
    _boardController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Picture → FEN',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildGradientBody(),
    );
  }

  Widget _buildGradientBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [t1, t2, t3],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /* Pick buttons */
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _sourceCard(
                    Icons.camera_alt,
                    'Take Photo',
                        () => _pickImage(ImageSource.camera),
                  ),
                  _sourceCard(
                    Icons.photo_library,
                    'Gallery',
                        () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              /* Loading indicator */
              if (_loading) ...[
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Processing image...',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 24),
              ],

              /* Error message */
              if (_errorMessage.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              /* Image and FEN result */
              if (!_loading && _image != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _image!,
                    width: 280,
                    height: 280,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              /* Editable FEN section */
              if (!_loading && _fenController.text.isNotEmpty) ...[
                _EditableFenSection(
                  fenController: _fenController,
                  boardController: _boardController,
                  errorMessage: _errorMessage,
                ),
                const SizedBox(height: 20),

                /* Play vs Computer button */
                SizedBox(
                  width: 220,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play vs Computer'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: _errorMessage.isEmpty ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FenToBoardScreen(fen: _fenController.text),
                        ),
                      );
                    } : null,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _sourceCard(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: _loading ? null : onTap,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_loading ? 0.05 : 0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: Colors.white.withOpacity(_loading ? 0.1 : 0.25),
              width: 2
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                icon,
                size: 44,
                color: Colors.white.withOpacity(_loading ? 0.3 : 1.0)
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(_loading ? 0.3 : 1.0),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditableFenSection extends StatelessWidget {
  final TextEditingController fenController;
  final ChessBoardController? boardController;
  final String errorMessage;

  const _EditableFenSection({
    required this.fenController,
    required this.boardController,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /* TextField */
        TextField(
          controller: fenController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Edit FEN',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white.withOpacity(.15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorText: errorMessage.isNotEmpty ? errorMessage : null,
            errorStyle: const TextStyle(color: Colors.red),
          ),
          maxLines: 2,
          minLines: 1,
        ),
        const SizedBox(height: 16),

        /* Live board */
        if (boardController != null) ...[
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(8),
            child: AspectRatio(
              aspectRatio: 1,
              child: IgnorePointer(
                child: ChessBoard(
                  controller: boardController!,
                  boardOrientation: PlayerColor.white,
                ),
              ),
            ),
          ),
        ] else if (fenController.text.isNotEmpty) ...[
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'Invalid FEN - Board cannot be displayed',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class FenToBoardScreen extends StatefulWidget {
  final String fen;
  const FenToBoardScreen({required this.fen, super.key});

  @override
  State<FenToBoardScreen> createState() => _FenToBoardScreenState();
}

class _FenToBoardScreenState extends State<FenToBoardScreen> {
  late ChessBoardController _controller;

  @override
  void initState() {
    super.initState();
    try {
      _controller = ChessBoardController.fromFEN(widget.fen);
    } catch (e) {
      _controller = ChessBoardController();
      print('Error loading FEN: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play vs Computer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [t1, t2, t3],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'From custom FEN – Engine as Black',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: ChessBoard(
                    controller: _controller,
                    boardOrientation: PlayerColor.white,
                    onMove: () {
                      // TODO: integrate Stockfish exactly like OfflineVsComputerPage
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'FEN: ${widget.fen}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}