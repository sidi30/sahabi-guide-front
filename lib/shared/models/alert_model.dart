import 'dart:convert';

class AlertModel {
  final String id;
  final String agencyId;
  final String pilgrimId;
  final String type;
  final String status;
  final Map<String, dynamic>? payload;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  AlertModel({
    required this.id,
    required this.agencyId,
    required this.pilgrimId,
    required this.type,
    required this.status,
    this.payload,
    required this.createdAt,
    this.resolvedAt,
  });

  AlertModel copyWith({
    String? id,
    String? agencyId,
    String? pilgrimId,
    String? type,
    String? status,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return AlertModel(
      id: id ?? this.id,
      agencyId: agencyId ?? this.agencyId,
      pilgrimId: pilgrimId ?? this.pilgrimId,
      type: type ?? this.type,
      status: status ?? this.status,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'agencyId': agencyId,
      'pilgrimId': pilgrimId,
      'type': type,
      'status': status,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  factory AlertModel.fromMap(Map<String, dynamic> map) {
    return AlertModel(
      id: map['id'] ?? '',
      agencyId: map['agencyId'] ?? '',
      pilgrimId: map['pilgrimId'] ?? '',
      type: map['type'] ?? '',
      status: map['status'] ?? '',
      payload: map['payload'],
      createdAt: DateTime.parse(map['createdAt']),
      resolvedAt: map['resolvedAt'] != null 
          ? DateTime.parse(map['resolvedAt']) 
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AlertModel.fromJson(String source) => 
      AlertModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AlertModel(id: $id, agencyId: $agencyId, pilgrimId: $pilgrimId, type: $type, status: $status, payload: $payload, createdAt: $createdAt, resolvedAt: $resolvedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is AlertModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class PositionModel {
  final String id;
  final String pilgrimId;
  final double lat;
  final double lng;
  final double? accuracy;
  final int? battery;
  final DateTime timestamp;

  PositionModel({
    required this.id,
    required this.pilgrimId,
    required this.lat,
    required this.lng,
    this.accuracy,
    this.battery,
    required this.timestamp,
  });

  PositionModel copyWith({
    String? id,
    String? pilgrimId,
    double? lat,
    double? lng,
    double? accuracy,
    int? battery,
    DateTime? timestamp,
  }) {
    return PositionModel(
      id: id ?? this.id,
      pilgrimId: pilgrimId ?? this.pilgrimId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      accuracy: accuracy ?? this.accuracy,
      battery: battery ?? this.battery,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pilgrimId': pilgrimId,
      'lat': lat,
      'lng': lng,
      'accuracy': accuracy,
      'battery': battery,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PositionModel.fromMap(Map<String, dynamic> map) {
    return PositionModel(
      id: map['id'] ?? '',
      pilgrimId: map['pilgrimId'] ?? '',
      lat: map['lat']?.toDouble() ?? 0.0,
      lng: map['lng']?.toDouble() ?? 0.0,
      accuracy: map['accuracy']?.toDouble(),
      battery: map['battery'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  String toJson() => json.encode(toMap());

  factory PositionModel.fromJson(String source) => 
      PositionModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PositionModel(id: $id, pilgrimId: $pilgrimId, lat: $lat, lng: $lng, accuracy: $accuracy, battery: $battery, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is PositionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class HealthProfileModel {
  final String id;
  final String pilgrimId;
  final String? bloodGroup;
  final List<String> allergies;
  final List<String> conditions;
  final List<String> treatments;
  final String? notes;

  HealthProfileModel({
    required this.id,
    required this.pilgrimId,
    this.bloodGroup,
    this.allergies = const [],
    this.conditions = const [],
    this.treatments = const [],
    this.notes,
  });

  HealthProfileModel copyWith({
    String? id,
    String? pilgrimId,
    String? bloodGroup,
    List<String>? allergies,
    List<String>? conditions,
    List<String>? treatments,
    String? notes,
  }) {
    return HealthProfileModel(
      id: id ?? this.id,
      pilgrimId: pilgrimId ?? this.pilgrimId,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      conditions: conditions ?? this.conditions,
      treatments: treatments ?? this.treatments,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pilgrimId': pilgrimId,
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'conditions': conditions,
      'treatments': treatments,
      'notes': notes,
    };
  }

  factory HealthProfileModel.fromMap(Map<String, dynamic> map) {
    return HealthProfileModel(
      id: map['id'] ?? '',
      pilgrimId: map['pilgrimId'] ?? '',
      bloodGroup: map['bloodGroup'],
      allergies: List<String>.from(map['allergies'] ?? []),
      conditions: List<String>.from(map['conditions'] ?? []),
      treatments: List<String>.from(map['treatments'] ?? []),
      notes: map['notes'],
    );
  }

  String toJson() => json.encode(toMap());

  factory HealthProfileModel.fromJson(String source) => 
      HealthProfileModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'HealthProfileModel(id: $id, pilgrimId: $pilgrimId, bloodGroup: $bloodGroup, allergies: $allergies, conditions: $conditions, treatments: $treatments, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is HealthProfileModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
