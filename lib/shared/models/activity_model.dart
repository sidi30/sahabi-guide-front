class ActivityModel {
  final String id;
  final String userId;
  final ActivityType type;
  final String title;
  final String? description;
  final double? latitude;
  final double? longitude;
  final Map<String, dynamic>? metadata;
  final DateTime occurredAt;
  final DateTime createdAt;

  ActivityModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.description,
    this.latitude,
    this.longitude,
    this.metadata,
    required this.occurredAt,
    required this.createdAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] ?? '',
      userId: json['pilgrimId'] ?? json['userId'] ?? '',
      type: ActivityType.fromString(json['type'] ?? 'OTHER'),
      title: json['title'] ?? 'Activité',
      description: json['description'],
      latitude: json['lat']?.toDouble(),
      longitude: json['lng']?.toDouble(),
      metadata: json['payload'] ?? json['meta'] ?? json['metadata'],
      occurredAt: DateTime.tryParse(json['occurredAt'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pilgrimId': userId,
      'type': type.name,
      'title': title,
      'description': description,
      'lat': latitude,
      'lng': longitude,
      'payload': metadata,
      'occurredAt': occurredAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ActivityModel copyWith({
    String? id,
    String? userId,
    ActivityType? type,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? metadata,
    DateTime? occurredAt,
    DateTime? createdAt,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      metadata: metadata ?? this.metadata,
      occurredAt: occurredAt ?? this.occurredAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get hasLocation => latitude != null && longitude != null;
  
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(occurredAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }
}

enum ActivityType {
  ritualCompleted,
  locationUpdate,
  duaRecited,
  healthCheck,
  groupMeeting,
  emergencyCall,
  prayer,
  other;

  static ActivityType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'RITUAL_COMPLETED':
        return ActivityType.ritualCompleted;
      case 'LOCATION_UPDATE':
        return ActivityType.locationUpdate;
      case 'DUA_RECITED':
        return ActivityType.duaRecited;
      case 'HEALTH_CHECK':
        return ActivityType.healthCheck;
      case 'GROUP_MEETING':
        return ActivityType.groupMeeting;
      case 'EMERGENCY_CALL':
        return ActivityType.emergencyCall;
      case 'PRAYER':
        return ActivityType.prayer;
      default:
        return ActivityType.other;
    }
  }

  String get displayName {
    switch (this) {
      case ActivityType.ritualCompleted:
        return 'Rituel complété';
      case ActivityType.locationUpdate:
        return 'Localisation';
      case ActivityType.duaRecited:
        return 'Doua récitée';
      case ActivityType.healthCheck:
        return 'Contrôle médical';
      case ActivityType.groupMeeting:
        return 'Réunion de groupe';
      case ActivityType.emergencyCall:
        return 'Appel d\'urgence';
      case ActivityType.prayer:
        return 'Prière';
      case ActivityType.other:
        return 'Autre';
    }
  }

  String get name {
    switch (this) {
      case ActivityType.ritualCompleted:
        return 'RITUAL_COMPLETED';
      case ActivityType.locationUpdate:
        return 'LOCATION_UPDATE';
      case ActivityType.duaRecited:
        return 'DUA_RECITED';
      case ActivityType.healthCheck:
        return 'HEALTH_CHECK';
      case ActivityType.groupMeeting:
        return 'GROUP_MEETING';
      case ActivityType.emergencyCall:
        return 'EMERGENCY_CALL';
      case ActivityType.prayer:
        return 'PRAYER';
      case ActivityType.other:
        return 'OTHER';
    }
  }
}




