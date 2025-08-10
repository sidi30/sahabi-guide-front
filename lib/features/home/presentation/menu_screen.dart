import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
// import '../../../rituals/presentation/timeline_screen.dart';
// import '../../../rituals/presentation/duas_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF8F9FA),
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   title: const Text(
      //     'Hajj Guide',
      //     style: TextStyle(
      //       color: Color(0xFF1D3557),
      //       fontSize: 20,
      //       fontWeight: FontWeight.w600,
      //     ),
      //   ),
      //   centerTitle: true,
      // ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMenuCard(
              icon: Icons.luggage,
              title: 'My Hajj',
              color: AppColors.primary,
              onTap: () => context.go('/timeline'),
            ),
            _buildMenuCard(
              icon: Icons.favorite_border,
              title: 'My Duas',
              color: AppColors.primary,
              onTap: () => context.go('/duas'),
            ),
            _buildMenuCard(
              icon: Icons.map_outlined,
              title: 'Map & Location',
              color: AppColors.primary,
              onTap: () {
                // TODO: Implement map screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feature coming soon')),
                );
              },
            ),
            _buildMenuCard(
              icon: Icons.play_circle_outline,
              title: 'Video\nPreparation',
              color: AppColors.primary,
              onTap: () {
                // TODO: Implement videos screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feature coming soon')),
                );
              },
            ),
            _buildMenuCard(
              icon: Icons.favorite,
              title: 'My Health',
              color: AppColors.primary,
              onTap: () {
                // TODO: Implement health screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feature coming soon')),
                );
              },
            ),
            _buildMenuCard(
              icon: Icons.account_circle_outlined,
              title: 'Profile &\nEmergency',
              color: AppColors.primary,
              onTap: () {
                // TODO: Implement profile screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feature coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D3557),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
