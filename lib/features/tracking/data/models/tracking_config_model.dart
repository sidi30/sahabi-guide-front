/// Configuration du tracking GPS
enum TrackingMode {
  /// Mode haute précision : mise à jour toutes les 1 minute
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

  const TrackingConfig({
    this.mode = TrackingMode.normal,
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


