import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/models/alert_model.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onResolve;

  const AlertCard({
    super.key,
    required this.alert,
    this.onTap,
    this.onMarkAsRead,
    this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: alert.isRead ? 1 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: alert.isRead ? Colors.grey[300]! : _getTypeColor(alert.type),
          width: alert.isRead ? 1 : 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec type et priorité
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _getTypeColor(alert.type).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _getTypeIcon(alert.type),
                      size: 16,
                      color: _getTypeColor(alert.type),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    alert.type.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  _buildPriorityBadge(alert.priority),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Titre
              Row(
                children: [
                  Expanded(
                    child: Text(
                      alert.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: alert.isRead ? Colors.grey[700] : Colors.black,
                      ),
                    ),
                  ),
                  if (!alert.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Message (tronqué)
              Text(
                alert.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: alert.isRead ? Colors.grey[600] : Colors.grey[800],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Footer avec date et actions
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(alert.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  
                  // Actions rapides
                  if (onMarkAsRead != null)
                    _buildActionButton(
                      icon: Icons.done,
                      label: 'Lue',
                      onPressed: onMarkAsRead!,
                      color: Colors.blue,
                    ),
                  if (onMarkAsRead != null && onResolve != null)
                    const SizedBox(width: 8),
                  if (onResolve != null)
                    _buildActionButton(
                      icon: Icons.check_circle,
                      label: 'Résoudre',
                      onPressed: onResolve!,
                      color: Colors.green,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(AlertPriority priority) {
    Color color = _getPriorityColor(priority);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        priority.displayName,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(AlertType type) {
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

  IconData _getTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.weather:
        return Icons.cloud;
      case AlertType.health:
        return Icons.local_hospital;
      case AlertType.schedule:
        return Icons.schedule;
      case AlertType.emergency:
        return Icons.emergency;
      case AlertType.security:
        return Icons.security;
      case AlertType.other:
        return Icons.info;
    }
  }

  Color _getPriorityColor(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.low:
        return Colors.green;
      case AlertPriority.medium:
        return Colors.orange;
      case AlertPriority.high:
        return Colors.red;
      case AlertPriority.critical:
        return Colors.red[900]!;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'À l\'instant';
    }
  }
}


