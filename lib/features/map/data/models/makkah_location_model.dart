import 'dart:convert';
import 'package:latlong2/latlong.dart';

class MakkahLocationModel {
  final String id;
  final String name;
  final String nameArabic;
  final LatLng coordinates;
  final String type;
  final String description;
  final bool isImportant;

  const MakkahLocationModel({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.coordinates,
    required this.type,
    required this.description,
    this.isImportant = false,
  });

  MakkahLocationModel copyWith({
    String? id,
    String? name,
    String? nameArabic,
    LatLng? coordinates,
    String? type,
    String? description,
    bool? isImportant,
  }) {
    return MakkahLocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      coordinates: coordinates ?? this.coordinates,
      type: type ?? this.type,
      description: description ?? this.description,
      isImportant: isImportant ?? this.isImportant,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameArabic': nameArabic,
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'type': type,
      'description': description,
      'isImportant': isImportant,
    };
  }

  factory MakkahLocationModel.fromMap(Map<String, dynamic> map) {
    return MakkahLocationModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      nameArabic: map['nameArabic'] ?? '',
      coordinates: LatLng(
        (map['latitude'] ?? 0.0).toDouble(),
        (map['longitude'] ?? 0.0).toDouble(),
      ),
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      isImportant: map['isImportant'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory MakkahLocationModel.fromJson(String source) =>
      MakkahLocationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MakkahLocationModel(id: $id, name: $name, nameArabic: $nameArabic, coordinates: $coordinates, type: $type, description: $description, isImportant: $isImportant)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MakkahLocationModel &&
        other.id == id &&
        other.name == name &&
        other.nameArabic == nameArabic &&
        other.coordinates == coordinates &&
        other.type == type &&
        other.description == description &&
        other.isImportant == isImportant;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        nameArabic.hashCode ^
        coordinates.hashCode ^
        type.hashCode ^
        description.hashCode ^
        isImportant.hashCode;
  }
}