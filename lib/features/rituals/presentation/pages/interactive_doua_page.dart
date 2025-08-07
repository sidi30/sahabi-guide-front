import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InteractiveDouaPage extends StatefulWidget {
  const InteractiveDouaPage({super.key});

  @override
  State<InteractiveDouaPage> createState() => _InteractiveDouaPageState();
}

class _InteractiveDouaPageState extends State<InteractiveDouaPage> {
  bool isPlayingArafah = false;
  bool isPlayingMina = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1D3557)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'My Duas',
          style: TextStyle(
            color: Color(0xFF1D3557),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Day of Arafah Section
            _buildDouaSection(
              title: 'Day of Arafah',
              subtitle: 'Special prayers for the most blessed day',
              isPlaying: isPlayingArafah,
              onPlayPause: () {
                setState(() {
                  isPlayingArafah = !isPlayingArafah;
                  if (isPlayingArafah) isPlayingMina = false;
                });
              },
              color: const Color(0xFF4FC3F7),
            ),

            const SizedBox(height: 20),

            // Mina Section
            _buildDouaSection(
              title: 'Mina',
              subtitle: 'Prayers during the days of Mina',
              isPlaying: isPlayingMina,
              onPlayPause: () {
                setState(() {
                  isPlayingMina = !isPlayingMina;
                  if (isPlayingMina) isPlayingArafah = false;
                });
              },
              color: const Color(0xFF2A9D8F),
            ),

            const Spacer(),

            // Bottom Navigation
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomNavItem(
                      Icons.home, 'Home', false, () => context.go('/home')),
                  _buildBottomNavItem(Icons.favorite, 'Duas', true, () {}),
                  _buildBottomNavItem(Icons.map, 'Map', false, () {}),
                  _buildBottomNavItem(Icons.person, 'Profile', false, () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDouaSection({
    required String title,
    required String subtitle,
    required bool isPlaying,
    required VoidCallback onPlayPause,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.favorite_border,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D3557),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onPlayPause,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Arabic Text Sample
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'In the name of Allah, the Most Gracious, the Most Merciful',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          if (isPlaying) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.3,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(
      IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF4FC3F7) : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? const Color(0xFF4FC3F7) : Colors.grey,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
