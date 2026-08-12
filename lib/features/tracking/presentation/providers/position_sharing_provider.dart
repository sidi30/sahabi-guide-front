import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/presentation/providers/passport_auth_provider.dart';
import '../../../sos/domain/sos_request.dart';
import '../../../sos/presentation/providers/sos_provider.dart';
import '../../data/models/tracking_config_model.dart';
import '../../data/services/position_tracking_service.dart';

/// Partage de position : l'interrupteur du pèlerin, et le seul endroit qui
/// démarre ou arrête [PositionTrackingService].
///
/// <h2>Pourquoi ce fichier existe</h2>
///
/// [PositionTrackingService] était enregistré dans l'injection de dépendances et
/// **jamais démarré** : aucun appel à `startTracking` dans toute l'application. Une
/// seule position n'a donc jamais été envoyée depuis la mise en service — la table
/// `positions` de production affiche `n_tup_ins = 0`, et la carte du back-office
/// montre fidèlement un ensemble vide. Les alertes SOS, elles, remontaient : c'est
/// bien ce maillon-ci qui manquait, pas la chaîne entière.
///
/// <h2>La règle</h2>
///
/// Le suivi est **éteint par défaut** et ne démarre que si les trois conditions
/// suivantes sont réunies : le pèlerin l'a activé, il est authentifié, et son
/// identifiant est connu. Perdre l'une des trois l'arrête. Il n'y a pas d'autre
/// chemin d'allumage : un service de localisation qui démarre « quelque part
/// ailleurs » est un service qu'on ne sait plus éteindre.
///
/// L'intervalle par défaut est de 30 minutes. Les cadences courtes existent dans
/// [TrackingMode] pour l'escalade d'une alerte, pas comme réglage.
class PositionSharingState {
  /// Le pèlerin a-t-il activé le partage ? Faux tant qu'il n'a rien demandé.
  final bool enabled;

  /// Cadence choisie. Toujours l'un des [TrackingConfig.selectableModes].
  final TrackingMode mode;

  const PositionSharingState({
    this.enabled = false,
    this.mode = TrackingMode.every30min,
  });

  PositionSharingState copyWith({bool? enabled, TrackingMode? mode}) =>
      PositionSharingState(
        enabled: enabled ?? this.enabled,
        mode: mode ?? this.mode,
      );
}

class PositionSharingNotifier extends StateNotifier<PositionSharingState> {
  final SharedPreferences _prefs;

  /// Persistance par NOM et non par index : ajouter un mode à l'énumération ne
  /// doit pas changer silencieusement le réglage déjà choisi par le pèlerin.
  static const enabledKey = 'position_sharing_enabled';
  static const modeKey = 'position_sharing_mode';

  PositionSharingNotifier(this._prefs) : super(const PositionSharingState()) {
    _load();
  }

  void _load() {
    final enabled = _prefs.getBool(enabledKey) ?? false;
    final storedMode = _prefs.getString(modeKey);
    final mode = TrackingConfig.selectableModes.firstWhere(
      (m) => m.name == storedMode,
      orElse: () => TrackingMode.every30min,
    );
    state = PositionSharingState(enabled: enabled, mode: mode);
  }

  Future<void> setEnabled(bool value) async {
    state = state.copyWith(enabled: value);
    await _prefs.setBool(enabledKey, value);
  }

  Future<void> setMode(TrackingMode mode) async {
    // Un mode hors de la liste proposée serait une cadence courte imposée au
    // pèlerin sans qu'il l'ait demandée : on refuse plutôt que de l'accepter.
    if (!TrackingConfig.selectableModes.contains(mode)) {
      AppLogger.debug('Mode de suivi refusé (hors liste proposée) : ${mode.name}');
      return;
    }
    state = state.copyWith(mode: mode);
    await _prefs.setString(modeKey, mode.name);
  }
}

final positionSharingProvider =
    StateNotifierProvider<PositionSharingNotifier, PositionSharingState>((ref) {
  throw UnimplementedError(
      'positionSharingProvider doit être surchargé dans main.dart');
});

/// Applique l'état ci-dessus au service. À lire une fois au démarrage de
/// l'application ; il se réévalue ensuite tout seul à chaque changement
/// d'authentification ou de réglage.
final positionSharingControllerProvider = Provider<void>((ref) {
  final sharing = ref.watch(positionSharingProvider);
  final auth = ref.watch(authNotifierProvider);
  final sos = ref.watch(sosQueueProvider);
  final service = sl<PositionTrackingService>();

  final userId = auth.pilgrimProfile?.id;

  // ESCALADE — le seul cas où la cadence se resserre sans que le pèlerin l'ait
  // demandée. Tant qu'un SOS n'est pas parti et confirmé, sa position doit être
  // fraîche : des secours qui cherchent quelqu'un ne peuvent rien faire d'un
  // point vieux d'une demi-heure. L'escalade s'applique MÊME si le partage est
  // éteint — appeler à l'aide, c'est demander à être trouvé — et retombe d'elle
  // même dès que le serveur a confirmé l'alerte.
  final sosEnCours = sos.requests.any((r) =>
      r.status == SosDeliveryStatus.pending ||
      r.status == SosDeliveryStatus.sending ||
      r.status == SosDeliveryStatus.failed);

  final shouldTrack =
      (sharing.enabled || sosEnCours) && auth.isAuthenticated && userId != null;

  if (!shouldTrack) {
    if (service.isTracking) {
      AppLogger.debug('Partage de position : arrêt (désactivé ou déconnecté)');
      service.stopTracking();
    }
    return;
  }

  final wantedMode = sosEnCours ? TrackingMode.high : sharing.mode;
  final wantedConfig = TrackingConfig(mode: wantedMode);

  if (!service.isTracking) {
    AppLogger.debug('Partage de position : démarrage (${wantedMode.label})');
    service.startTracking(userId, config: wantedConfig);
  } else if (service.config.mode != wantedMode) {
    AppLogger.debug('Partage de position : cadence -> ${wantedMode.label}');
    service.updateConfig(wantedConfig);
  }
});
