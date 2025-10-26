class ContactMessageModel {
  final String? id;
  final String? userId;
  final String fullName;
  final String email;
  final String category;  // GENERAL, TECHNIQUE, COMPTE, RITUELS, SANTE, GROUPE, AUTRE
  final String subject;
  final String message;
  final String? status;  // NEW, IN_PROGRESS, RESOLVED, CLOSED
  final String? priority;  // LOW, NORMAL, HIGH, URGENT
  final String? assignedTo;
  final String? response;
  final DateTime? respondedAt;
  final DateTime? createdAt;

  ContactMessageModel({
    this.id,
    this.userId,
    required this.fullName,
    required this.email,
    required this.category,
    required this.subject,
    required this.message,
    this.status,
    this.priority,
    this.assignedTo,
    this.response,
    this.respondedAt,
    this.createdAt,
  });

  factory ContactMessageModel.fromJson(Map<String, dynamic> json) {
    return ContactMessageModel(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      category: json['category']?.toString() ?? 'GENERAL',
      subject: json['subject']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString(),
      priority: json['priority']?.toString(),
      assignedTo: json['assignedTo']?.toString(),
      response: json['response']?.toString(),
      respondedAt: json['respondedAt'] != null 
          ? DateTime.parse(json['respondedAt']) 
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      'fullName': fullName,
      'email': email,
      'category': category,
      'subject': subject,
      'message': message,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (assignedTo != null) 'assignedTo': assignedTo,
      if (response != null) 'response': response,
    };
  }

  ContactMessageModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? email,
    String? category,
    String? subject,
    String? message,
    String? status,
    String? priority,
    String? assignedTo,
    String? response,
    DateTime? respondedAt,
    DateTime? createdAt,
  }) {
    return ContactMessageModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
      response: response ?? this.response,
      respondedAt: respondedAt ?? this.respondedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ContactMessageModel(id: $id, subject: $subject, category: $category, status: $status)';
  }
}

// Enum helpers pour les catégories
class ContactCategory {
  static const String general = 'GENERAL';
  static const String technique = 'TECHNIQUE';
  static const String compte = 'COMPTE';
  static const String rituels = 'RITUELS';
  static const String sante = 'SANTE';
  static const String groupe = 'GROUPE';
  static const String autre = 'AUTRE';

  static String toFrench(String category) {
    switch (category) {
      case general:
        return 'Général';
      case technique:
        return 'Problème technique';
      case compte:
        return 'Mon compte';
      case rituels:
        return 'Rituels du Hajj';
      case sante:
        return 'Santé & Urgence';
      case groupe:
        return 'Mon groupe';
      case autre:
        return 'Autre';
      default:
        return category;
    }
  }

  static String fromFrench(String french) {
    switch (french) {
      case 'Général':
        return general;
      case 'Problème technique':
        return technique;
      case 'Mon compte':
        return compte;
      case 'Rituels du Hajj':
        return rituels;
      case 'Santé & Urgence':
        return sante;
      case 'Mon groupe':
        return groupe;
      case 'Autre':
        return autre;
      default:
        return general;
    }
  }
}




