import 'package:flutter/material.dart';
import 'package:livchess/home_page.dart';
void main() => runApp(const LivChessApp());

class LivChessApp extends StatelessWidget {
  const LivChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'LivChess',
     theme: ThemeData(
      useMaterial3: true,
        fontFamily: 'Lato',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
          secondary: Colors.amber,
        ),
      ),
      home: const HomePage(),
    );
  }
}
