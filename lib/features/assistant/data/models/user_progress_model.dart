import 'package:hive/hive.dart';

part 'user_progress_model.g.dart';

@HiveType(typeId: 11)
class UserProgressModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String stepId;

  @HiveField(3)
  final String stepCode;

  @HiveField(4)
  final String answer;

  @HiveField(5)
  final DateTime answeredAt;

  @HiveField(6)
  final DateTime? syncedAt;

  @HiveField(7)
  final bool isOffline;

  @HiveField(8)
  final String? deviceId;

  UserProgressModel({
    required this.id,
    required this.userId,
    required this.stepId,
    required this.stepCode,
    required this.answer,
    required this.answeredAt,
    this.syncedAt,
    this.isOffline = false,
    this.deviceId,
  });

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      stepId: json['stepId'] as String,
      stepCode: json['stepCode'] as String,
      answer: json['answer'] as String,
      answeredAt: DateTime.parse(json['answeredAt'] as String),
      syncedAt: json['syncedAt'] != null 
          ? DateTime.parse(json['syncedAt'] as String) 
          : null,
      isOffline: json['isOffline'] as bool? ?? false,
      deviceId: json['deviceId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'stepId': stepId,
      'stepCode': stepCode,
      'answer': answer,
      'answeredAt': answeredAt.toUtc().toIso8601String(),
      'syncedAt': syncedAt?.toUtc().toIso8601String(),
      'isOffline': isOffline,
      'deviceId': deviceId,
    };
  }

  bool get isSynced => syncedAt != null;

  UserProgressModel copyWith({
    String? id,
    String? userId,
    String? stepId,
    String? stepCode,
    String? answer,
    DateTime? answeredAt,
    DateTime? syncedAt,
    bool? isOffline,
    String? deviceId,
  }) {
    return UserProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      stepId: stepId ?? this.stepId,
      stepCode: stepCode ?? this.stepCode,
      answer: answer ?? this.answer,
      answeredAt: answeredAt ?? this.answeredAt,
      syncedAt: syncedAt ?? this.syncedAt,
      isOffline: isOffline ?? this.isOffline,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}

