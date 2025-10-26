import 'dart:convert';

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
  
    return other is HealthProfileModel &&
      other.id == id &&
      other.pilgrimId == pilgrimId &&
      other.bloodGroup == bloodGroup &&
      listEquals(other.allergies, allergies) &&
      listEquals(other.conditions, conditions) &&
      listEquals(other.treatments, treatments) &&
      other.notes == notes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      pilgrimId.hashCode ^
      bloodGroup.hashCode ^
      allergies.hashCode ^
      conditions.hashCode ^
      treatments.hashCode ^
      notes.hashCode;
  }
}

bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) return false;
  }
  return true;
}