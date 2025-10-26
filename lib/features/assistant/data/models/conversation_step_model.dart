import 'package:hive/hive.dart';

part 'conversation_step_model.g.dart';

@HiveType(typeId: 10)
class ConversationStepModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String stepCode;

  @HiveField(2)
  final int stepOrder;

  @HiveField(3)
  final String question;

  @HiveField(4)
  final String? questionAr;

  @HiveField(5)
  final String? questionEn;

  @HiveField(6)
  final String answerType; // YES_NO, MULTIPLE_CHOICE, TEXT, DATE, TIME

  @HiveField(7)
  final List<String>? answerOptions;

  @HiveField(8)
  final String? helpText;

  @HiveField(9)
  final String? relatedRitualId;

  @HiveField(10)
  final bool? isCritical;

  @HiveField(11)
  final int? reminderAfterHours;

  @HiveField(12)
  final String? nextStepCode;

  @HiveField(13)
  final Map<String, String>? navigationRules;

  ConversationStepModel({
    required this.id,
    required this.stepCode,
    required this.stepOrder,
    required this.question,
    this.questionAr,
    this.questionEn,
    required this.answerType,
    this.answerOptions,
    this.helpText,
    this.relatedRitualId,
    this.isCritical,
    this.reminderAfterHours,
    this.nextStepCode,
    this.navigationRules,
  });

  factory ConversationStepModel.fromJson(Map<String, dynamic> json) {
    return ConversationStepModel(
      id: json['id'] as String,
      stepCode: json['stepCode'] as String,
      stepOrder: json['stepOrder'] as int,
      question: json['question'] as String,
      questionAr: json['questionAr'] as String?,
      questionEn: json['questionEn'] as String?,
      answerType: json['answerType'] as String,
      answerOptions: (json['answerOptions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      helpText: json['helpText'] as String?,
      relatedRitualId: json['relatedRitualId'] as String?,
      isCritical: json['isCritical'] as bool?,
      reminderAfterHours: json['reminderAfterHours'] as int?,
      nextStepCode: json['nextStepCode'] as String?,
      navigationRules: (json['navigationRules'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as String)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stepCode': stepCode,
      'stepOrder': stepOrder,
      'question': question,
      'questionAr': questionAr,
      'questionEn': questionEn,
      'answerType': answerType,
      'answerOptions': answerOptions,
      'helpText': helpText,
      'relatedRitualId': relatedRitualId,
      'isCritical': isCritical,
      'reminderAfterHours': reminderAfterHours,
      'nextStepCode': nextStepCode,
      'navigationRules': navigationRules,
    };
  }

  String getLocalizedQuestion(String locale) {
    switch (locale) {
      case 'ar':
        return questionAr ?? question;
      case 'en':
        return questionEn ?? question;
      default:
        return question;
    }
  }

  ConversationStepModel copyWith({
    String? id,
    String? stepCode,
    int? stepOrder,
    String? question,
    String? questionAr,
    String? questionEn,
    String? answerType,
    List<String>? answerOptions,
    String? helpText,
    String? relatedRitualId,
    bool? isCritical,
    int? reminderAfterHours,
    String? nextStepCode,
    Map<String, String>? navigationRules,
  }) {
    return ConversationStepModel(
      id: id ?? this.id,
      stepCode: stepCode ?? this.stepCode,
      stepOrder: stepOrder ?? this.stepOrder,
      question: question ?? this.question,
      questionAr: questionAr ?? this.questionAr,
      questionEn: questionEn ?? this.questionEn,
      answerType: answerType ?? this.answerType,
      answerOptions: answerOptions ?? this.answerOptions,
      helpText: helpText ?? this.helpText,
      relatedRitualId: relatedRitualId ?? this.relatedRitualId,
      isCritical: isCritical ?? this.isCritical,
      reminderAfterHours: reminderAfterHours ?? this.reminderAfterHours,
      nextStepCode: nextStepCode ?? this.nextStepCode,
      navigationRules: navigationRules ?? this.navigationRules,
    );
  }
}

