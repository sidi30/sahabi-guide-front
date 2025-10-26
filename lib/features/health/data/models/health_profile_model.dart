class HealthProfileModel {
  final String? id;
  final String? userId;
  final String? bloodGroup;
  final List<String> allergies;
  final List<String> conditions;
  final List<String> treatments;
  final String? notes;
  final String? emergencyContact;
  final String? emergencyContactPhone;

  HealthProfileModel({
    this.id,
    this.userId,
    this.bloodGroup,
    this.allergies = const [],
    this.conditions = const [],
    this.treatments = const [],
    this.notes,
    this.emergencyContact,
    this.emergencyContactPhone,
  });

  factory HealthProfileModel.fromJson(Map<String, dynamic> json) {
    return HealthProfileModel(
      id: json['id']?.toString(),
      userId: json['pilgrimId']?.toString() ?? json['userId']?.toString(),
      bloodGroup: json['bloodGroup']?.toString(),
      allergies: json['allergies'] != null 
          ? List<String>.from(json['allergies']) 
          : [],
      conditions: json['conditions'] != null 
          ? List<String>.from(json['conditions']) 
          : [],
      treatments: json['treatments'] != null 
          ? List<String>.from(json['treatments']) 
          : [],
      notes: json['notes']?.toString(),
      emergencyContact: json['emergencyContact']?.toString(),
      emergencyContactPhone: json['emergencyContactPhone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'pilgrimId': userId,
      if (bloodGroup != null) 'bloodGroup': bloodGroup,
      'allergies': allergies,
      'conditions': conditions,
      'treatments': treatments,
      if (notes != null) 'notes': notes,
      if (emergencyContact != null) 'emergencyContact': emergencyContact,
      if (emergencyContactPhone != null) 'emergencyContactPhone': emergencyContactPhone,
    };
  }

  HealthProfileModel copyWith({
    String? id,
    String? userId,
    String? bloodGroup,
    List<String>? allergies,
    List<String>? conditions,
    List<String>? treatments,
    String? notes,
    String? emergencyContact,
    String? emergencyContactPhone,
  }) {
    return HealthProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      conditions: conditions ?? this.conditions,
      treatments: treatments ?? this.treatments,
      notes: notes ?? this.notes,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
    );
  }

  @override
  String toString() {
    return 'HealthProfileModel(id: $id, bloodGroup: $bloodGroup, allergies: ${allergies.length})';
  }
}

// Helper pour les groupes sanguins
class BloodGroup {
  static const String oPositive = 'O_POSITIVE';
  static const String oNegative = 'O_NEGATIVE';
  static const String aPositive = 'A_POSITIVE';
  static const String aNegative = 'A_NEGATIVE';
  static const String bPositive = 'B_POSITIVE';
  static const String bNegative = 'B_NEGATIVE';
  static const String abPositive = 'AB_POSITIVE';
  static const String abNegative = 'AB_NEGATIVE';

  static String toFrench(String bloodGroup) {
    switch (bloodGroup) {
      case oPositive:
        return 'O+';
      case oNegative:
        return 'O-';
      case aPositive:
        return 'A+';
      case aNegative:
        return 'A-';
      case bPositive:
        return 'B+';
      case bNegative:
        return 'B-';
      case abPositive:
        return 'AB+';
      case abNegative:
        return 'AB-';
      default:
        return bloodGroup;
    }
  }

  static String fromFrench(String french) {
    switch (french.toUpperCase().trim()) {
      case 'O+':
        return oPositive;
      case 'O-':
        return oNegative;
      case 'A+':
        return aPositive;
      case 'A-':
        return aNegative;
      case 'B+':
        return bPositive;
      case 'B-':
        return bNegative;
      case 'AB+':
        return abPositive;
      case 'AB-':
        return abNegative;
      default:
        return french;
    }
  }

  static List<String> allGroups() {
    return [
      'O+',
      'O-',
      'A+',
      'A-',
      'B+',
      'B-',
      'AB+',
      'AB-',
    ];
  }
}




