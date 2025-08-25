import 'dart:convert';

class MedicalProfileModel {
  final String? bloodType;
  final List<String> allergies;
  final List<String> medications;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? notes;
  final DateTime updatedAt;

  const MedicalProfileModel({
    this.bloodType,
    this.allergies = const [],
    this.medications = const [],
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.notes,
    required this.updatedAt,
  });

  MedicalProfileModel copyWith({
    String? bloodType,
    List<String>? allergies,
    List<String>? medications,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? notes,
    DateTime? updatedAt,
  }) {
    return MedicalProfileModel(
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bloodType': bloodType,
      'allergies': allergies,
      'medications': medications,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'notes': notes,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MedicalProfileModel.fromMap(Map<String, dynamic> map) {
    return MedicalProfileModel(
      bloodType: map['bloodType'],
      allergies: (map['allergies'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      medications: (map['medications'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      emergencyContactName: map['emergencyContactName'],
      emergencyContactPhone: map['emergencyContactPhone'],
      notes: map['notes'],
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory MedicalProfileModel.fromJson(String source) =>
      MedicalProfileModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'MedicalProfileModel(bloodType: $bloodType, allergies: $allergies, medications: $medications, emergencyContactName: $emergencyContactName, emergencyContactPhone: $emergencyContactPhone, notes: $notes, updatedAt: $updatedAt)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicalProfileModel &&
        other.bloodType == bloodType &&
        _listEquals(other.allergies, allergies) &&
        _listEquals(other.medications, medications) &&
        other.emergencyContactName == emergencyContactName &&
        other.emergencyContactPhone == emergencyContactPhone &&
        other.notes == notes &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => bloodType.hashCode ^
      allergies.hashCode ^
      medications.hashCode ^
      emergencyContactName.hashCode ^
      emergencyContactPhone.hashCode ^
      notes.hashCode ^
      updatedAt.hashCode;
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
