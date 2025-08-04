import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DuasScreen extends StatefulWidget {
  const DuasScreen({Key? key}) : super(key: key);

  @override
  State<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends State<DuasScreen> {
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildDuasSection(
            title: 'Dua for Entering Ihram',
            subtitle: 'Labbaik Allahumma labbaik...',
            isPlaying: false,
            onPlayPause: () {
              // TODO: Implement audio playback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Audio playback coming soon')),
              );
            },
            color: const Color(0xFF2A9D8F),
          ),
          const SizedBox(height: 16),
          _buildDuasSection(
            title: 'Dua for Tawaf',
            subtitle: 'Subhan Allah, Alhamdulillah...',
            isPlaying: false,
            onPlayPause: () {
              // TODO: Implement audio playback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Audio playback coming soon')),
              );
            },
            color: const Color(0xFFE9C46A),
          ),
          const SizedBox(height: 16),
          _buildDuasSection(
            title: 'Dua for Sa\'i',
            subtitle: 'Inna al-safa wa al-marwata...',
            isPlaying: false,
            onPlayPause: () {
              // TODO: Implement audio playback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Audio playback coming soon')),
              );
            },
            color: const Color(0xFFF4A261),
          ),
          const SizedBox(height: 16),
          _buildDuasSection(
            title: 'Dua for Arafat',
            subtitle: 'La ilaha illa Allah wahdahu...',
            isPlaying: false,
            onPlayPause: () {
              // TODO: Implement audio playback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Audio playback coming soon')),
              );
            },
            color: const Color(0xFFE76F51),
          ),
        ],
      ),
    );
  }

  Widget _buildDuasSection({
    required String title,
    required String subtitle,
    required bool isPlaying,
    required VoidCallback onPlayPause,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D3557),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: color,
                    size: 20,
                  ),
                  onPressed: onPlayPause,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LinearProgressIndicator(
                  value: 0.3,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '1:45 / 3:20',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
