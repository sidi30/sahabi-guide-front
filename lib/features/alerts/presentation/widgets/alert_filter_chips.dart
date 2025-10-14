import 'package:flutter/material.dart';
import '../../../../shared/models/alert_model.dart';

class AlertFilterChips extends StatelessWidget {
  final AlertType? selectedFilter;
  final ValueChanged<AlertType?> onFilterChanged;

  const AlertFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip(null, 'Toutes', Icons.notifications),
          const SizedBox(width: 8),
          _buildFilterChip(AlertType.weather, 'Météo', Icons.cloud),
          const SizedBox(width: 8),
          _buildFilterChip(AlertType.health, 'Santé', Icons.local_hospital),
          const SizedBox(width: 8),
          _buildFilterChip(AlertType.schedule, 'Horaires', Icons.schedule),
          const SizedBox(width: 8),
          _buildFilterChip(AlertType.emergency, 'Urgence', Icons.emergency),
          const SizedBox(width: 8),
          _buildFilterChip(AlertType.security, 'Sécurité', Icons.security),
        ],
      ),
    );
  }

  Widget _buildFilterChip(AlertType? type, String label, IconData icon) {
    final isSelected = selectedFilter == type;
    
    return GestureDetector(
      onTap: () => onFilterChanged(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _getTypeColor(type) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _getTypeColor(type) : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : _getTypeColor(type),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(AlertType? type) {
    if (type == null) return Colors.grey[700]!;
    
    switch (type) {
      case AlertType.weather:
        return Colors.blue;
      case AlertType.health:
        return Colors.red;
      case AlertType.schedule:
        return Colors.orange;
      case AlertType.emergency:
        return Colors.red[900]!;
      case AlertType.security:
        return Colors.purple;
      case AlertType.other:
        return Colors.grey;
    }
  }
}


