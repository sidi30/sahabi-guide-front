class AlertModel {
  final String id;
  final String? agencyId;
  final String? userId;
  final AlertType type;
  final AlertStatus status;
  final String title;
  final String message;
  final AlertPriority priority;
  final Map<String, dynamic>? payload;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final DateTime? readAt;

  AlertModel({
    required this.id,
    this.agencyId,
    this.userId,
    required this.type,
    required this.status,
    required this.title,
    required this.message,
    required this.priority,
    this.payload,
    required this.createdAt,
    this.resolvedAt,
    this.readAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] ?? '',
      agencyId: json['agencyId'],
      userId: json['pilgrimId'], // Note: API utilise 'pilgrimId'
      type: AlertType.fromString(json['type'] ?? 'OTHER'),
      status: AlertStatus.fromString(json['status'] ?? 'ACTIVE'),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      priority: AlertPriority.fromString(json['priority'] ?? 'MEDIUM'),
      payload: json['payload'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      resolvedAt: json['resolvedAt'] != null 
          ? DateTime.tryParse(json['resolvedAt']) 
          : null,
      readAt: json['readAt'] != null 
          ? DateTime.tryParse(json['readAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agencyId': agencyId,
      'pilgrimId': userId,
      'type': type.name,
      'status': status.name,
      'title': title,
      'message': message,
      'priority': priority.name,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  AlertModel copyWith({
    String? id,
    String? agencyId,
    String? userId,
    AlertType? type,
    AlertStatus? status,
    String? title,
    String? message,
    AlertPriority? priority,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    DateTime? resolvedAt,
    DateTime? readAt,
  }) {
    return AlertModel(
      id: id ?? this.id,
      agencyId: agencyId ?? this.agencyId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      title: title ?? this.title,
      message: message ?? this.message,
      priority: priority ?? this.priority,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      readAt: readAt ?? this.readAt,
    );
  }

  bool get isRead => readAt != null;
  bool get isResolved => status == AlertStatus.resolved;
  bool get isActive => status == AlertStatus.active;
}

enum AlertType {
  weather,
  health,
  schedule,
  emergency,
  security,
  other;

  static AlertType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'WEATHER':
        return AlertType.weather;
      case 'HEALTH':
        return AlertType.health;
      case 'SCHEDULE':
        return AlertType.schedule;
      case 'EMERGENCY':
        return AlertType.emergency;
      case 'SECURITY':
        return AlertType.security;
      default:
        return AlertType.other;
    }
  }

  String get displayName {
    switch (this) {
      case AlertType.weather:
        return 'Météo';
      case AlertType.health:
        return 'Santé';
      case AlertType.schedule:
        return 'Horaire';
      case AlertType.emergency:
        return 'Urgence';
      case AlertType.security:
        return 'Sécurité';
      case AlertType.other:
        return 'Autre';
    }
  }

  String get name {
    return toString().split('.').last.toUpperCase();
  }
}

enum AlertStatus {
  active,
  read,
  resolved,
  cancelled;

  static AlertStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ACTIVE':
        return AlertStatus.active;
      case 'READ':
        return AlertStatus.read;
      case 'RESOLVED':
        return AlertStatus.resolved;
      case 'CANCELLED':
        return AlertStatus.cancelled;
      default:
        return AlertStatus.active;
    }
  }

  String get displayName {
    switch (this) {
      case AlertStatus.active:
        return 'Active';
      case AlertStatus.read:
        return 'Lue';
      case AlertStatus.resolved:
        return 'Résolue';
      case AlertStatus.cancelled:
        return 'Annulée';
    }
  }

  String get name {
    return toString().split('.').last.toUpperCase();
  }
}

enum AlertPriority {
  low,
  medium,
  high,
  critical;

  static AlertPriority fromString(String value) {
    switch (value.toUpperCase()) {
      case 'LOW':
        return AlertPriority.low;
      case 'MEDIUM':
        return AlertPriority.medium;
      case 'HIGH':
        return AlertPriority.high;
      case 'CRITICAL':
        return AlertPriority.critical;
      default:
        return AlertPriority.medium;
    }
  }

  String get displayName {
    switch (this) {
      case AlertPriority.low:
        return 'Faible';
      case AlertPriority.medium:
        return 'Moyenne';
      case AlertPriority.high:
        return 'Élevée';
      case AlertPriority.critical:
        return 'Critique';
    }
  }

  String get name {
    return toString().split('.').last.toUpperCase();
  }
}




