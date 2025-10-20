class EmergencyContactModel {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String? relation;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmergencyContactModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    this.relation,
    required this.isPrimary,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      id: json['id'] ?? '',
      userId: json['pilgrimId'] ?? json['userId'] ?? '', // API utilise 'pilgrimId'
      name: json['fullName'] ?? json['name'] ?? '',
      phone: json['phone'] ?? '',
      relation: json['relationship'] ?? json['relation'],
      isPrimary: json['isPrimary'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pilgrimId': userId,
      'fullName': name,
      'phone': phone,
      'relationship': relation,
      'isPrimary': isPrimary,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  EmergencyContactModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? relation,
    bool? isPrimary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmergencyContactModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relation: relation ?? this.relation,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayRelation => relation ?? 'Contact';
  
  String get formattedPhone {
    // Formatage simple du numéro de téléphone
    if (phone.startsWith('+')) return phone;
    return '+33 $phone'; // Par défaut français
  }
}



