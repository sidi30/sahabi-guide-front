import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1D3557)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Explanatory Videos',
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
            // Preparation Section
            const Text(
              'Preparation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D3557),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildVideoCard(
                    'assets/images/preparation1.jpg',
                    'Pre-departure preparations',
                    () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVideoCard(
                    'assets/images/preparation2.jpg',
                    'Packing essentials',
                    () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Rituals Section
            const Text(
              'Rituals',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D3557),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildVideoCard(
                    'assets/images/tawaf.jpg',
                    'Tawaf',
                    () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVideoCard(
                    'assets/images/sai.jpg',
                    'Sa\'i',
                    () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // App Usage Section
            const Text(
              'App Usage',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D3557),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildVideoCard(
                    'assets/images/navigation.jpg',
                    'Navigation',
                    () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVideoCard(
                    'assets/images/features.jpg',
                    'Features',
                    () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 2),
    );
  }

  Widget _buildVideoCard(String imagePath, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF4FC3F7).withValues(alpha: 0.1),
        ),
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4FC3F7).withValues(alpha: 0.8),
                    const Color(0xFF2A9D8F).withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),

            // Play button
            const Center(
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.play_arrow,
                  color: Color(0xFF4FC3F7),
                  size: 28,
                ),
              ),
            ),

            // Title
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
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
