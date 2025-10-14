import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/alert_model.dart';
import '../../../alerts/data/services/alerts_service.dart';
import '../../../../core/di/injection_container.dart';

// Provider pour le service
final alertsServiceProvider = Provider<AlertsService>((ref) {
  return sl<AlertsService>();
});

// État des alertes
class AlertsState {
  final List<AlertModel> alerts;
  final bool isLoading;
  final String? error;
  final bool hasUnread;

  AlertsState({
    required this.alerts,
    required this.isLoading,
    this.error,
    required this.hasUnread,
  });

  AlertsState.initial()
      : alerts = [],
        isLoading = false,
        error = null,
        hasUnread = false;

  AlertsState copyWith({
    List<AlertModel>? alerts,
    bool? isLoading,
    String? error,
    bool? hasUnread,
  }) {
    return AlertsState(
      alerts: alerts ?? this.alerts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasUnread: hasUnread ?? this.hasUnread,
    );
  }

  int get unreadCount => alerts.where((alert) => !alert.isRead).length;
  
  List<AlertModel> get unreadAlerts => alerts.where((alert) => !alert.isRead).toList();
  
  List<AlertModel> get criticalAlerts => alerts.where((alert) => 
    alert.priority == AlertPriority.critical && alert.isActive).toList();
}

// Notifier pour les alertes
class AlertsNotifier extends StateNotifier<AlertsState> {
  final AlertsService _alertsService;

  AlertsNotifier(this._alertsService) : super(AlertsState.initial());

  /// Charge les alertes d'un pèlerin
  Future<void> loadPilgrimAlerts(String pilgrimId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final alerts = await _alertsService.getPilgrimAlerts(pilgrimId);
      final hasUnread = alerts.any((alert) => !alert.isRead);
      
      state = state.copyWith(
        alerts: alerts,
        isLoading: false,
        hasUnread: hasUnread,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Charge toutes les alertes (pour admin)
  Future<void> loadAlerts({
    String? status,
    String? pilgrimId,
    int page = 0,
    int size = 20,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final alerts = await _alertsService.getAlerts(
        status: status,
        pilgrimId: pilgrimId,
        page: page,
        size: size,
      );
      
      state = state.copyWith(
        alerts: alerts,
        isLoading: false,
        hasUnread: alerts.any((alert) => !alert.isRead),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Crée une nouvelle alerte
  Future<void> createAlert({
    String? pilgrimId,
    required AlertType type,
    required String title,
    required String message,
    AlertPriority priority = AlertPriority.medium,
    Map<String, dynamic>? payload,
  }) async {
    try {
      final newAlert = await _alertsService.createAlert(
        pilgrimId: pilgrimId,
        type: type,
        title: title,
        message: message,
        priority: priority,
        payload: payload,
      );

      // Ajouter la nouvelle alerte en début de liste
      final updatedAlerts = [newAlert, ...state.alerts];
      state = state.copyWith(
        alerts: updatedAlerts,
        hasUnread: true,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Marque une alerte comme lue
  Future<void> markAsRead(String alertId) async {
    try {
      await _alertsService.markAsRead(alertId);

      // Mettre à jour localement
      final updatedAlerts = state.alerts.map((alert) {
        if (alert.id == alertId) {
          return alert.copyWith(
            status: AlertStatus.read,
            readAt: DateTime.now(),
          );
        }
        return alert;
      }).toList();

      state = state.copyWith(
        alerts: updatedAlerts,
        hasUnread: updatedAlerts.any((alert) => !alert.isRead),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Résout une alerte
  Future<void> resolveAlert(String alertId) async {
    try {
      await _alertsService.resolveAlert(alertId);

      // Mettre à jour localement
      final updatedAlerts = state.alerts.map((alert) {
        if (alert.id == alertId) {
          return alert.copyWith(
            status: AlertStatus.resolved,
            resolvedAt: DateTime.now(),
          );
        }
        return alert;
      }).toList();

      state = state.copyWith(alerts: updatedAlerts);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Actualise les alertes
  Future<void> refresh(String pilgrimId) async {
    await loadPilgrimAlerts(pilgrimId);
  }

  /// Efface l'erreur
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider pour le notifier
final alertsNotifierProvider = StateNotifierProvider<AlertsNotifier, AlertsState>((ref) {
  final alertsService = ref.watch(alertsServiceProvider);
  return AlertsNotifier(alertsService);
});

// Provider pour les alertes critiques
final criticalAlertsProvider = Provider<List<AlertModel>>((ref) {
  final alertsState = ref.watch(alertsNotifierProvider);
  return alertsState.criticalAlerts;
});

// Provider pour le nombre d'alertes non lues
final unreadAlertsCountProvider = Provider<int>((ref) {
  final alertsState = ref.watch(alertsNotifierProvider);
  return alertsState.unreadCount;
});


