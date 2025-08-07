import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DouaPage extends StatefulWidget {
  const DouaPage({super.key});

  @override
  State<DouaPage> createState() => _DouaPageState();
}

class _DouaPageState extends State<DouaPage> {
  bool autoPlay = false;
  int? playingIndex;

  final List<Map<String, dynamic>> arafatDuas = [
    {
      'title': 'Labbaik Allahumma Labbaik',
      'subtitle': 'French Translation',
      'isPlaying': false,
    },
    {
      'title': 'Allahumma Inni As\'aluka',
      'subtitle': 'French Translation',
      'isPlaying': false,
    },
    {
      'title': 'Subhanallah Walhamdulillah',
      'subtitle': 'French Translation',
      'isPlaying': false,
    },
  ];

  final List<Map<String, dynamic>> minaDuas = [
    {
      'title': 'Bismillahi Allahu Akbar',
      'subtitle': 'French Translation',
      'isPlaying': false,
    },
    {
      'title': 'Allahumma Taqabbal Minni',
      'subtitle': 'French Translation',
      'isPlaying': false,
    },
    {
      'title': 'Allahumma Salli Ala Muhammad',
      'subtitle': 'French Translation',
      'isPlaying': false,
    },
  ];

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
          'Duas for Hajj',
          style: TextStyle(
            color: Color(0xFF1D3557),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day of Arafah Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Day of Arafah',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D3557),
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      'Auto-play',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: autoPlay,
                      onChanged: (value) => setState(() => autoPlay = value),
                      activeColor: const Color(0xFF4FC3F7),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Arafat Duas List
            ...arafatDuas.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> dua = entry.value;
              return _buildDouaCard(dua, index, true);
            }),

            const SizedBox(height: 40),

            // Mina Section
            const Text(
              'Mina',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D3557),
              ),
            ),

            const SizedBox(height: 20),

            // Mina Duas List
            ...minaDuas.asMap().entries.map((entry) {
              int index = entry.key + arafatDuas.length;
              Map<String, dynamic> dua = entry.value;
              return _buildDouaCard(dua, index, false);
            }),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 1),
    );
  }

  Widget _buildDouaCard(Map<String, dynamic> dua, int index, bool isArafat) {
    bool isPlaying = playingIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dua['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D3557),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dua['subtitle'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                if (isPlaying) {
                  playingIndex = null;
                } else {
                  playingIndex = index;
                }
              });
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPlaying
                    ? const Color(0xFF4FC3F7)
                    : const Color(0xFFE5F4FD),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: isPlaying ? Colors.white : const Color(0xFF4FC3F7),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, int currentIndex) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home,
            label: 'Home',
            isActive: currentIndex == 0,
            onTap: () => context.go('/menu'),
          ),
          _buildNavItem(
            icon: Icons.map,
            label: 'Map',
            isActive: currentIndex == 1,
            onTap: () => context.go('/map'),
          ),
          _buildNavItem(
            icon: Icons.info_outline,
            label: 'Info',
            isActive: currentIndex == 2,
            onTap: () => context.go('/videos'),
          ),
          _buildNavItem(
            icon: Icons.person,
            label: 'Profile',
            isActive: currentIndex == 3,
            onTap: () => context.go('/profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4FC3F7) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
