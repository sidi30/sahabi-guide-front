import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/models/alert_model.dart';
import '../providers/alerts_provider.dart';
import '../widgets/alert_card.dart';
import '../widgets/alert_filter_chips.dart';

class AlertsPage extends ConsumerStatefulWidget {
  const AlertsPage({super.key});

  @override
  ConsumerState<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends ConsumerState<AlertsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AlertType? _selectedFilter;
  String? _pilgrimId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAlerts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAlerts() async {
    // TODO: Récupérer l'ID du pèlerin depuis les préférences/auth
    _pilgrimId = '550e8400-e29b-41d4-a716-446655440020'; // ID de test
    await ref.read(alertsNotifierProvider.notifier).loadPilgrimAlerts(_pilgrimId!);
  }

  @override
  Widget build(BuildContext context) {
    final alertsState = ref.watch(alertsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertes'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (alertsState.unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${alertsState.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadAlerts(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              text: 'Toutes (${alertsState.alerts.length})',
              icon: const Icon(Icons.notifications, size: 20),
            ),
            Tab(
              text: 'Non lues (${alertsState.unreadCount})',
              icon: const Icon(Icons.notifications_active, size: 20),
            ),
            Tab(
              text: 'Critiques (${alertsState.criticalAlerts.length})',
              icon: const Icon(Icons.warning, size: 20),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: AlertFilterChips(
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),
          ),
          
          // Contenu
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Toutes les alertes
                _buildAlertsList(alertsState.alerts),
                
                // Alertes non lues
                _buildAlertsList(alertsState.unreadAlerts),
                
                // Alertes critiques
                _buildAlertsList(alertsState.criticalAlerts),
              ],
            ),
          ),
        ],
      ),
      
      // Bouton flottant pour créer une alerte (pour test)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateAlertDialog(),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add_alert, color: Colors.white),
      ),
    );
  }

  Widget _buildAlertsList(List<AlertModel> alerts) {
    final alertsState = ref.watch(alertsNotifierProvider);

    if (alertsState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (alertsState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              alertsState.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(alertsNotifierProvider.notifier).clearError();
                _loadAlerts();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    // Filtrer par type si nécessaire
    final filteredAlerts = _selectedFilter != null
        ? alerts.where((alert) => alert.type == _selectedFilter).toList()
        : alerts;

    if (filteredAlerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune alerte',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous n\'avez aucune alerte pour le moment',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAlerts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredAlerts.length,
        itemBuilder: (context, index) {
          final alert = filteredAlerts[index];
          return AlertCard(
            alert: alert,
            onTap: () => _showAlertDetail(alert),
            onMarkAsRead: alert.isRead ? null : () => _markAsRead(alert.id),
            onResolve: alert.isResolved ? null : () => _resolveAlert(alert.id),
          );
        },
      ),
    );
  }

  void _showAlertDetail(AlertModel alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // En-tête
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getAlertTypeColor(alert.type).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getAlertTypeIcon(alert.type),
                        color: _getAlertTypeColor(alert.type),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            alert.type.displayName,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildPriorityBadge(alert.priority),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Message
                Text(
                  alert.message,
                  style: const TextStyle(fontSize: 16),
                ),
                
                const SizedBox(height: 20),
                
                // Métadonnées
                _buildMetadataRow('Créée le', DateFormat('dd/MM/yyyy à HH:mm').format(alert.createdAt)),
                if (alert.readAt != null)
                  _buildMetadataRow('Lue le', DateFormat('dd/MM/yyyy à HH:mm').format(alert.readAt!)),
                if (alert.resolvedAt != null)
                  _buildMetadataRow('Résolue le', DateFormat('dd/MM/yyyy à HH:mm').format(alert.resolvedAt!)),
                
                const SizedBox(height: 20),
                
                // Actions
                Row(
                  children: [
                    if (!alert.isRead)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _markAsRead(alert.id);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.done),
                          label: const Text('Marquer comme lue'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    if (!alert.isRead && !alert.isResolved) const SizedBox(width: 12),
                    if (!alert.isResolved)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _resolveAlert(alert.id);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Résoudre'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(AlertPriority priority) {
    Color color;
    switch (priority) {
      case AlertPriority.low:
        color = Colors.green;
        break;
      case AlertPriority.medium:
        color = Colors.orange;
        break;
      case AlertPriority.high:
        color = Colors.red;
        break;
      case AlertPriority.critical:
        color = Colors.red[900]!;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        priority.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getAlertTypeColor(AlertType type) {
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

  IconData _getAlertTypeIcon(AlertType type) {
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

  Future<void> _markAsRead(String alertId) async {
    await ref.read(alertsNotifierProvider.notifier).markAsRead(alertId);
  }

  Future<void> _resolveAlert(String alertId) async {
    await ref.read(alertsNotifierProvider.notifier).resolveAlert(alertId);
  }

  void _showCreateAlertDialog() {
    // Dialog simple pour créer une alerte de test
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer une alerte de test'),
        content: const Text('Voulez-vous créer une alerte de test ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(alertsNotifierProvider.notifier).createAlert(
                pilgrimId: _pilgrimId,
                type: AlertType.other,
                title: 'Alerte de test',
                message: 'Ceci est une alerte de test créée depuis l\'application mobile.',
                priority: AlertPriority.medium,
              );
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}








