import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RitualTimelinePage extends StatefulWidget {
  const RitualTimelinePage({super.key});

  @override
  State<RitualTimelinePage> createState() => _RitualTimelinePageState();
}

class _RitualTimelinePageState extends State<RitualTimelinePage> {
  final List<Map<String, dynamic>> rituals = [
    {
      'title': 'Tawaf',
      'subtitle': 'Circumambulation of the Kaaba',
      'isCompleted': false,
      'isActive': true,
      'hasAudio': true,
      'hasVideo': true,
    },
    {
      'title': 'Sa\'i',
      'subtitle': 'Walking between Safa and Marwa',
      'isCompleted': true,
      'isActive': false,
      'hasAudio': false,
      'hasVideo': false,
    },
    {
      'title': 'Mina',
      'subtitle': 'Stay in Mina',
      'isCompleted': true,
      'isActive': false,
      'hasAudio': false,
      'hasVideo': false,
    },
    {
      'title': 'Arafat',
      'subtitle': 'Day of Arafat',
      'isCompleted': true,
      'isActive': false,
      'hasAudio': false,
      'hasVideo': false,
    },
    {
      'title': 'Muzdalifah',
      'subtitle': 'Night in Muzdalifah',
      'isCompleted': true,
      'isActive': false,
      'hasAudio': false,
      'hasVideo': false,
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
          'Hajj Rituals',
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
          children: [
            ...rituals.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> ritual = entry.value;
              bool isLast = index == rituals.length - 1;
              
              return _buildTimelineItem(ritual, isLast);
            }),
            
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 2),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> ritual, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: ritual['isActive'] 
                    ? const Color(0xFF4FC3F7) 
                    : ritual['isCompleted'] 
                        ? const Color(0xFF10B981) 
                        : const Color(0xFFE5E7EB),
                shape: BoxShape.circle,
              ),
              child: Icon(
                ritual['isActive'] 
                    ? Icons.access_time
                    : ritual['isCompleted'] 
                        ? Icons.check 
                        : Icons.circle,
                color: Colors.white,
                size: 16,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: ritual['isCompleted'] 
                    ? const Color(0xFF10B981) 
                    : const Color(0xFFE5E7EB),
              ),
          ],
        ),
        
        const SizedBox(width: 16),
        
        // Content
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and subtitle
                Text(
                  ritual['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D3557),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ritual['subtitle'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                
                // Action buttons for active ritual
                if (ritual['isActive']) ...[
                  const SizedBox(height: 16),
                  
                  // Audio Guide Button
                  if (ritual['hasAudio'])
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.headphones, size: 20),
                        label: const Text('Audio Guide (Hausa)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE3F2FD),
                          foregroundColor: const Color(0xFF4FC3F7),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  
                  // Video Demonstration Button
                  if (ritual['hasVideo'])
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.play_circle_outline, size: 20),
                        label: const Text('Video Demonstration'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE3F2FD),
                          foregroundColor: const Color(0xFF4FC3F7),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  
                  // Mark as completed button
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        ritual['isCompleted'] = true;
                        ritual['isActive'] = false;
                        
                        // Activate next ritual if exists
                        int currentIndex = rituals.indexOf(ritual);
                        if (currentIndex < rituals.length - 1) {
                          rituals[currentIndex + 1]['isActive'] = true;
                        }
                      });
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: const Text('Mark as completed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      foregroundColor: const Color(0xFF1D3557),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context, int currentIndex) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
            icon: Icons.timeline,
            label: 'Rituals',
            isActive: currentIndex == 2,
            onTap: () => context.go('/hajj-timeline'),
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
