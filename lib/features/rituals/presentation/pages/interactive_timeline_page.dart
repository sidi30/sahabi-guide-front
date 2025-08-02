import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InteractiveTimelinePage extends StatefulWidget {
  const InteractiveTimelinePage({super.key});

  @override
  State<InteractiveTimelinePage> createState() => _InteractiveTimelinePageState();
}

class _InteractiveTimelinePageState extends State<InteractiveTimelinePage> {
  List<RitualStep> ritualSteps = [
    RitualStep(
      title: 'Ihram',
      description: 'Enter the sacred state of pilgrimage',
      status: RitualStatus.completed,
      day: 'Day 1',
    ),
    RitualStep(
      title: 'Tawaf al-Qudum',
      description: 'Arrival circumambulation around the Kaaba',
      status: RitualStatus.completed,
      day: 'Day 1',
    ),
    RitualStep(
      title: 'Sa\'i',
      description: 'Walking between Safa and Marwah hills',
      status: RitualStatus.inProgress,
      day: 'Day 1',
    ),
    RitualStep(
      title: 'Day of Tarwiyah',
      description: 'Proceed to Mina for preparation',
      status: RitualStatus.pending,
      day: 'Day 8',
    ),
    RitualStep(
      title: 'Day of Arafah',
      description: 'Stand at Mount Arafah for prayers',
      status: RitualStatus.pending,
      day: 'Day 9',
    ),
    RitualStep(
      title: 'Muzdalifah',
      description: 'Overnight stay and collect pebbles',
      status: RitualStatus.pending,
      day: 'Day 9-10',
    ),
    RitualStep(
      title: 'Ramy al-Jamarat',
      description: 'Stone throwing at the pillars',
      status: RitualStatus.pending,
      day: 'Day 10-12',
    ),
    RitualStep(
      title: 'Tawaf al-Ifadah',
      description: 'Circumambulation after Hajj',
      status: RitualStatus.pending,
      day: 'Day 10',
    ),
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
          'My Hajj Timeline',
          style: TextStyle(
            color: Color(0xFF1D3557),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Header
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Hajj Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1D3557),
                  ),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _getProgressValue(),
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_getProgressValue() * 100).toInt()}% Complete',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Timeline List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: ritualSteps.length,
              itemBuilder: (context, index) {
                return _buildTimelineItem(ritualSteps[index], index);
              },
            ),
          ),
          
          // Bottom Navigation
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBottomNavItem(Icons.home, 'Home', false, () => context.go('/home')),
                _buildBottomNavItem(Icons.timeline, 'Timeline', true, () {}),
                _buildBottomNavItem(Icons.map, 'Map', false, () {}),
                _buildBottomNavItem(Icons.person, 'Profile', false, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getProgressValue() {
    int completed = ritualSteps.where((step) => step.status == RitualStatus.completed).length;
    int inProgress = ritualSteps.where((step) => step.status == RitualStatus.inProgress).length;
    return (completed + (inProgress * 0.5)) / ritualSteps.length;
  }

  Widget _buildTimelineItem(RitualStep step, int index) {
    Color statusColor = _getStatusColor(step.status);
    IconData statusIcon = _getStatusIcon(step.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusIcon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              if (index < ritualSteps.length - 1)
                Container(
                  width: 2,
                  height: 40,
                  color: Colors.grey[300],
                ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Container(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        step.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D3557),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          step.day,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (step.status == RitualStatus.inProgress) ...[
                        ElevatedButton.icon(
                          onPressed: () => _markAsCompleted(index),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Mark Complete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4FC3F7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.play_circle_outline),
                        color: const Color(0xFF4FC3F7),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.videocam_outlined),
                        color: const Color(0xFF2A9D8F),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(RitualStatus status) {
    switch (status) {
      case RitualStatus.completed:
        return const Color(0xFF2A9D8F);
      case RitualStatus.inProgress:
        return const Color(0xFF4FC3F7);
      case RitualStatus.pending:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(RitualStatus status) {
    switch (status) {
      case RitualStatus.completed:
        return Icons.check;
      case RitualStatus.inProgress:
        return Icons.play_arrow;
      case RitualStatus.pending:
        return Icons.schedule;
    }
  }

  void _markAsCompleted(int index) {
    setState(() {
      ritualSteps[index].status = RitualStatus.completed;
      // Start next step if available
      if (index + 1 < ritualSteps.length && 
          ritualSteps[index + 1].status == RitualStatus.pending) {
        ritualSteps[index + 1].status = RitualStatus.inProgress;
      }
    });
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
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

class RitualStep {
  final String title;
  final String description;
  RitualStatus status;
  final String day;

  RitualStep({
    required this.title,
    required this.description,
    required this.status,
    required this.day,
  });
}

enum RitualStatus {
  completed,
  inProgress,
  pending,
}
