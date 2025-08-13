import 'package:flutter/material.dart';
import 'package:livchess/offline_multiplayer_page.dart';
import 'package:livchess/offline_vs_computer.dart';
import 'package:livchess/picture_to_fen.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'LivChess',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF240046), // cosmic purple
              Color(0xFF5A189A), // rich violet
              Color(0xFFF72585), // vivid pink
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // decorative chess icon
              Icon(
                Icons.castle,
                size: 64,
                color: Colors.white.withOpacity(.85),
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose Mode',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),
              // three glass-morphism cards
              _MenuCard(
                icon: Icons.group,
                title: 'Offline Multiplayer',
                subtitle: 'Play with friends side-by-side',
                onTap: () => _open(context, 'Offline Multiplayer'),
              ),
              const SizedBox(height: 20),
              _MenuCard(
                icon: Icons.network_check_rounded,
                title: 'Online Multiplayer',
                subtitle: 'Challenge the built-in engine',
                onTap: () => _open(context, 'Online Multiplayer'),
              ),
              const SizedBox(height: 20),
              _MenuCard(
                icon: Icons.computer,
                title: 'Offline vs Computer',
                subtitle: 'Challenge the built-in engine',
                onTap: () => _open(context, 'Offline vs Computer'),
              ),
              const SizedBox(height: 20),
              _MenuCard(
                icon: Icons.camera_alt,
                title: 'Picture to FEN',
                subtitle: 'Scan a board and get FEN instantly',
                onTap: () => _open(context, 'Picture to FEN'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _open(BuildContext ctx, String route) {
    ScaffoldMessenger.of(
      ctx,
    ).showSnackBar(SnackBar(content: Text('Opening $route...')));

    if (route == 'Offline Multiplayer') {
      Navigator.push(
        ctx,
        MaterialPageRoute(builder: (_) => const OfflineMultiplayerPage()),
      );
    } else if (route == 'Online Multiplayer') {
      // Navigate to Online Multiplayer page
      // Navigator.push(ctx, MaterialPageRoute(builder: (_) => const OnlineMultiplayerPage()));
    } else if (route == 'Offline vs Computer') {
      // Navigate to Offline vs Computer page
      Navigator.push(
        ctx,
        MaterialPageRoute(builder: (_) => const OfflineVsComputerPage()),
      );
    } else if (route == 'Picture to FEN') {
      // Navigate to Picture to FEN page
      Navigator.push(ctx, MaterialPageRoute(builder: (_) => const PictureToFENPage()));
    }
    // Navigator.push(ctx, MaterialPageRoute(builder: (_) => const Placeholder()));
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.15),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(.25), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
