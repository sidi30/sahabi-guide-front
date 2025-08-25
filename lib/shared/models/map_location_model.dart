import 'dart:convert';

class MapLocationModel {
  final String id;
  final String name;
  final String type; // e.g., mosque, clinic, center, landmark
  final double latitude;
  final double longitude;
  final String? address;
  final String? phone;
  final double? distanceKm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MapLocationModel({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.address,
    this.phone,
    this.distanceKm,
    this.createdAt,
    this.updatedAt,
  });

  MapLocationModel copyWith({
    String? id,
    String? name,
    String? type,
    double? latitude,
    double? longitude,
    String? address,
    String? phone,
    double? distanceKm,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MapLocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      distanceKm: distanceKm ?? this.distanceKm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'phone': phone,
      'distanceKm': distanceKm,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory MapLocationModel.fromMap(Map<String, dynamic> map) {
    return MapLocationModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      type: map['type']?.toString() ?? 'unknown',
      latitude: (map['latitude'] is num)
          ? (map['latitude'] as num).toDouble()
          : double.tryParse(map['latitude']?.toString() ?? '0') ?? 0,
      longitude: (map['longitude'] is num)
          ? (map['longitude'] as num).toDouble()
          : double.tryParse(map['longitude']?.toString() ?? '0') ?? 0,
      address: map['address']?.toString(),
      phone: map['phone']?.toString(),
      distanceKm: map['distanceKm'] != null
          ? (map['distanceKm'] is num)
              ? (map['distanceKm'] as num).toDouble()
              : double.tryParse(map['distanceKm'].toString())
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory MapLocationModel.fromJson(String source) =>
      MapLocationModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
