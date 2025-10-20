/// Modèle pour les statistiques de parcours
class RouteStatisticsModel {
  final double totalDistanceMeters;
  final String totalDistanceFormatted;
  final int durationSeconds;
  final String durationFormatted;
  final double averageSpeedKmh;
  final int totalPoints;
  final DateTime? startTime;
  final DateTime? endTime;
  final CoordinateModel? startPoint;
  final CoordinateModel? endPoint;

  RouteStatisticsModel({
    required this.totalDistanceMeters,
    required this.totalDistanceFormatted,
    required this.durationSeconds,
    required this.durationFormatted,
    required this.averageSpeedKmh,
    required this.totalPoints,
    this.startTime,
    this.endTime,
    this.startPoint,
    this.endPoint,
  });

  factory RouteStatisticsModel.fromJson(Map<String, dynamic> json) {
    return RouteStatisticsModel(
      totalDistanceMeters: (json['totalDistanceMeters'] ?? 0).toDouble(),
      totalDistanceFormatted: json['totalDistanceFormatted'] ?? '0 m',
      durationSeconds: json['durationSeconds'] ?? 0,
      durationFormatted: json['durationFormatted'] ?? '0 min',
      averageSpeedKmh: (json['averageSpeedKmh'] ?? 0).toDouble(),
      totalPoints: json['totalPoints'] ?? 0,
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      startPoint: json['startPoint'] != null ? CoordinateModel.fromJson(json['startPoint']) : null,
      endPoint: json['endPoint'] != null ? CoordinateModel.fromJson(json['endPoint']) : null,
    );
  }
}

/// Modèle simple pour une coordonnée GPS
class CoordinateModel {
  final double lat;
  final double lng;

  CoordinateModel({required this.lat, required this.lng});

  factory CoordinateModel.fromJson(Map<String, dynamic> json) {
    return CoordinateModel(
      lat: json['lat'].toDouble(),
      lng: json['lng'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}


