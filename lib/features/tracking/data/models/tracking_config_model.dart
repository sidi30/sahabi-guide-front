/// Configuration du tracking GPS
///
/// Les intervalles courts (1 à 5 minutes) ne sont PAS des choix proposés au pèlerin :
/// ils vident la batterie et n'apportent rien pour un déplacement à pied entre des
/// lieux distants de quelques centaines de mètres. Ils restent dans l'énumération pour
/// l'escalade automatique — un SOS en cours a besoin d'une position fraîche, et c'est
/// le seul cas où elle est nécessaire.
///
/// Les deux modes offerts à l'activation sont [every30min] (défaut) et [hourly].
enum TrackingMode {
  /// Suivi espacé, choix par défaut à l'activation : une position toutes les 30 minutes.
  every30min(
    interval: Duration(minutes: 30),
    accuracy: 'medium',
    distanceFilter: 100,
    label: 'Toutes les 30 minutes',
    batteryImpact: 'Très faible',
  ),

  /// Suivi le plus économe proposé : une position par heure.
  hourly(
    interval: Duration(minutes: 60),
    accuracy: 'medium',
    distanceFilter: 200,
    label: 'Toutes les heures',
    batteryImpact: 'Négligeable',
  ),

  /// Mode haute précision : mise à jour toutes les 1 minute.
  /// RÉSERVÉ à l'escalade pendant une alerte : ne pas l'exposer comme réglage.
  high(
    interval: Duration(minutes: 1),
    accuracy: 'high',
    distanceFilter: 10,
    label: 'Haute précision',
    batteryImpact: 'Élevé',
  ),

  /// Mode normal : mise à jour toutes les 2 minutes
  normal(
    interval: Duration(minutes: 2),
    accuracy: 'medium',
    distanceFilter: 20,
    label: 'Normal',
    batteryImpact: 'Moyen',
  ),

  /// Mode économie d'énergie : mise à jour toutes les 5 minutes
  eco(
    interval: Duration(minutes: 5),
    accuracy: 'low',
    distanceFilter: 50,
    label: 'Économie d\'énergie',
    batteryImpact: 'Faible',
  );

  const TrackingMode({
    required this.interval,
    required this.accuracy,
    required this.distanceFilter,
    required this.label,
    required this.batteryImpact,
  });

  final Duration interval;
  final String accuracy;
  final int distanceFilter;
  final String label;
  final String batteryImpact;
}

/// Configuration du tracking
class TrackingConfig {
  final TrackingMode mode;
  final bool pauseOnLowBattery;
  final int lowBatteryThreshold;
  final bool trackOnlyWhenMoving;

  /// Modes proposés au pèlerin, dans l'ordre d'affichage. Les modes courts
  /// (`high`, `normal`, `eco`) n'y figurent pas : voir l'en-tête de [TrackingMode].
  static const List<TrackingMode> selectableModes = [
    TrackingMode.every30min,
    TrackingMode.hourly,
  ];

  const TrackingConfig({
    this.mode = TrackingMode.every30min,
    this.pauseOnLowBattery = true,
    this.lowBatteryThreshold = 15,
    this.trackOnlyWhenMoving = true,
  });

  TrackingConfig copyWith({
    TrackingMode? mode,
    bool? pauseOnLowBattery,
    int? lowBatteryThreshold,
    bool? trackOnlyWhenMoving,
  }) {
    return TrackingConfig(
      mode: mode ?? this.mode,
      pauseOnLowBattery: pauseOnLowBattery ?? this.pauseOnLowBattery,
      lowBatteryThreshold: lowBatteryThreshold ?? this.lowBatteryThreshold,
      trackOnlyWhenMoving: trackOnlyWhenMoving ?? this.trackOnlyWhenMoving,
    );
  }
}


