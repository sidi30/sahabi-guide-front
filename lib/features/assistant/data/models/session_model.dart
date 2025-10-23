import 'conversation_step_model.dart';

class SessionModel {
  final String id;
  final String userId;
  final ConversationStepModel? currentStep;
  final String status; // ACTIVE, PAUSED, COMPLETED, ABANDONED
  final DateTime startedAt;
  final DateTime? lastInteractionAt;
  final DateTime? completedAt;
  final int totalAnswers;

  SessionModel({
    required this.id,
    required this.userId,
    this.currentStep,
    required this.status,
    required this.startedAt,
    this.lastInteractionAt,
    this.completedAt,
    this.totalAnswers = 0,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      currentStep: json['currentStep'] != null
          ? ConversationStepModel.fromJson(json['currentStep'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      lastInteractionAt: json['lastInteractionAt'] != null
          ? DateTime.parse(json['lastInteractionAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      totalAnswers: json['totalAnswers'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'currentStep': currentStep?.toJson(),
      'status': status,
      'startedAt': startedAt.toIso8601String(),
      'lastInteractionAt': lastInteractionAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'totalAnswers': totalAnswers,
    };
  }

  bool get isActive => status == 'ACTIVE';
  bool get isCompleted => status == 'COMPLETED';

  SessionModel copyWith({
    String? id,
    String? userId,
    ConversationStepModel? currentStep,
    String? status,
    DateTime? startedAt,
    DateTime? lastInteractionAt,
    DateTime? completedAt,
    int? totalAnswers,
  }) {
    return SessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      completedAt: completedAt ?? this.completedAt,
      totalAnswers: totalAnswers ?? this.totalAnswers,
    );
  }
}

