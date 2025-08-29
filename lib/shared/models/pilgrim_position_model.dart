import 'dart:convert';
import 'package:sahabi_guide/core/types/types.dart';

class PilgrimPositionModel {
  final String id;
  final String pilgrimId;
  final double lat;
  final double lng;
  final double accuracy;
  final double battery;
  final DateTime ts;

  PilgrimPositionModel({
    required this.id,
    required this.pilgrimId,
    required this.lat,
    required this.lng,
    required this.accuracy,
    required this.battery,
    required this.ts,
  });

  PilgrimPositionModel copyWith({
    String? id,
    String? pilgrimId,
    double? lat,
    double? lng,
    double? accuracy,
    double? battery,
    DateTime? ts,
  }) {
    return PilgrimPositionModel(
      id: id ?? this.id,
      pilgrimId: pilgrimId ?? this.pilgrimId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      accuracy: accuracy ?? this.accuracy,
      battery: battery ?? this.battery,
      ts: ts ?? this.ts,
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
      'ts': ts.toIso8601String(),
    };
  }

  factory PilgrimPositionModel.fromMap(Map<String, dynamic> map) {
    return PilgrimPositionModel(
      id: map['id'] ?? '',
      pilgrimId: map['pilgrimId'] ?? '',
      lat: (map['lat'] ?? 0.0).toDouble(),
      lng: (map['lng'] ?? 0.0).toDouble(),
      accuracy: (map['accuracy'] ?? 0.0).toDouble(),
      battery: (map['battery'] ?? 0.0).toDouble(),
      ts: DateTime.parse(map['ts']),
    );
  }

  String toJson() => json.encode(toMap());

  factory PilgrimPositionModel.fromJson(String source) => 
      PilgrimPositionModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PilgrimPositionModel(id: $id, pilgrimId: $pilgrimId, lat: $lat, lng: $lng, accuracy: $accuracy, battery: $battery, ts: $ts)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is PilgrimPositionModel &&
      other.id == id &&
      other.pilgrimId == pilgrimId &&
      other.lat == lat &&
      other.lng == lng &&
      other.accuracy == accuracy &&
      other.battery == battery &&
      other.ts == ts;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      pilgrimId.hashCode ^
      lat.hashCode ^
      lng.hashCode ^
      accuracy.hashCode ^
      battery.hashCode ^
      ts.hashCode;
  }
}
