/// Modèle pour représenter une position GPS
class PositionModel {
  final String? id;
  final String userId;
  final double lat;
  final double lng;
  final double? accuracy;
  final int? battery;
  final double? speed;
  final double? heading;
  final DateTime timestamp;

  PositionModel({
    this.id,
    required this.userId,
    required this.lat,
    required this.lng,
    this.accuracy,
    this.battery,
    this.speed,
    this.heading,
    required this.timestamp,
  });

  /// Conversion depuis JSON (réponse API)
  factory PositionModel.fromJson(Map<String, dynamic> json) {
    return PositionModel(
      id: json['id'],
      userId: json['userId'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      accuracy: json['accuracy'] != null ? (json['accuracy'] as num).toDouble() : null,
      battery: json['battery'],
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
      heading: json['heading'] != null ? (json['heading'] as num).toDouble() : null,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  /// Conversion vers JSON (requête API)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'lat': lat,
      'lng': lng,
      if (accuracy != null) 'accuracy': accuracy,
      if (battery != null) 'battery': battery,
      if (speed != null) 'speed': speed,
      if (heading != null) 'heading': heading,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Copie avec modifications
  PositionModel copyWith({
    String? id,
    String? userId,
    double? lat,
    double? lng,
    double? accuracy,
    int? battery,
    double? speed,
    double? heading,
    DateTime? timestamp,
  }) {
    return PositionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      accuracy: accuracy ?? this.accuracy,
      battery: battery ?? this.battery,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'PositionModel(id: $id, userId: $userId, lat: $lat, lng: $lng, '
        'accuracy: $accuracy, battery: $battery, speed: $speed, heading: $heading, '
        'timestamp: $timestamp)';
  }
}


