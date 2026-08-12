import 'package:flutter_test/flutter_test.dart';
import 'package:sahabi_guide/features/tracking/data/models/tracking_config_model.dart';
import 'package:sahabi_guide/features/tracking/presentation/providers/position_sharing_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ce que ces tests verrouillent : le partage de position est ÉTEINT tant que le
/// pèlerin ne l'a pas allumé, et la cadence proposée reste espacée.
///
/// Le défaut d'origine n'était pas un mauvais réglage mais une absence totale de
/// branchement : `PositionTrackingService` n'était jamais démarré, et la table
/// `positions` de production n'a jamais reçu une seule ligne. Les tests ci-dessous
/// portent donc sur l'état persistant qui pilote ce démarrage.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('État du partage de position', () {
    test('éteint par défaut, sans réglage enregistré', () async {
      final prefs = await SharedPreferences.getInstance();
      final notifier = PositionSharingNotifier(prefs);

      expect(notifier.state.enabled, isFalse,
          reason: 'un suivi de personnes ne s\'allume pas tout seul');
      expect(notifier.state.mode, TrackingMode.every30min);
    });

    test('l\'activation et la cadence survivent au redémarrage', () async {
      final prefs = await SharedPreferences.getInstance();
      final premier = PositionSharingNotifier(prefs);
      await premier.setEnabled(true);
      await premier.setMode(TrackingMode.hourly);

      final apresRedemarrage = PositionSharingNotifier(prefs);
      expect(apresRedemarrage.state.enabled, isTrue);
      expect(apresRedemarrage.state.mode, TrackingMode.hourly);
    });

    test('une cadence courte ne peut pas être imposée par le réglage', () async {
      final prefs = await SharedPreferences.getInstance();
      final notifier = PositionSharingNotifier(prefs);

      await notifier.setMode(TrackingMode.high);

      expect(notifier.state.mode, TrackingMode.every30min,
          reason: 'high est réservé à l\'escalade d\'une alerte');
    });

    test('un mode inconnu en mémoire retombe sur 30 minutes', () async {
      SharedPreferences.setMockInitialValues({
        PositionSharingNotifier.enabledKey: true,
        PositionSharingNotifier.modeKey: 'mode_supprime_dans_une_version_future',
      });
      final prefs = await SharedPreferences.getInstance();

      final notifier = PositionSharingNotifier(prefs);

      expect(notifier.state.enabled, isTrue);
      expect(notifier.state.mode, TrackingMode.every30min);
    });
  });

  group('Cadences proposées', () {
    test('seules 30 minutes et 1 heure sont offertes au pèlerin', () {
      expect(TrackingConfig.selectableModes,
          [TrackingMode.every30min, TrackingMode.hourly]);
    });

    test('les cadences proposées sont espacées d\'au moins 30 minutes', () {
      for (final mode in TrackingConfig.selectableModes) {
        expect(mode.interval.inMinutes, greaterThanOrEqualTo(30),
            reason: '${mode.name} viderait la batterie pour rien');
      }
    });

    test('la cadence d\'escalade reste courte', () {
      expect(TrackingMode.high.interval, const Duration(minutes: 1),
          reason: 'des secours en recherche ont besoin d\'une position fraîche');
    });
  });
}
