import 'package:hive/hive.dart';

part 'chat_message_model.g.dart';

@HiveType(typeId: 12)
class ChatMessageModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final bool isBot;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String? stepId;

  @HiveField(5)
  final String? stepCode;

  @HiveField(6)
  final List<String>? quickReplies;

  @HiveField(7)
  final String? answerType;

  ChatMessageModel({
    required this.id,
    required this.content,
    required this.isBot,
    required this.timestamp,
    this.stepId,
    this.stepCode,
    this.quickReplies,
    this.answerType,
  });

  factory ChatMessageModel.botMessage({
    required String id,
    required String content,
    String? stepId,
    String? stepCode,
    List<String>? quickReplies,
    String? answerType,
  }) {
    return ChatMessageModel(
      id: id,
      content: content,
      isBot: true,
      timestamp: DateTime.now(),
      stepId: stepId,
      stepCode: stepCode,
      quickReplies: quickReplies,
      answerType: answerType,
    );
  }

  factory ChatMessageModel.userMessage({
    required String id,
    required String content,
    String? stepId,
    String? stepCode,
  }) {
    return ChatMessageModel(
      id: id,
      content: content,
      isBot: false,
      timestamp: DateTime.now(),
      stepId: stepId,
      stepCode: stepCode,
    );
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      content: json['content'] as String,
      isBot: json['isBot'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      stepId: json['stepId'] as String?,
      stepCode: json['stepCode'] as String?,
      quickReplies: (json['quickReplies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      answerType: json['answerType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isBot': isBot,
      'timestamp': timestamp.toIso8601String(),
      'stepId': stepId,
      'stepCode': stepCode,
      'quickReplies': quickReplies,
      'answerType': answerType,
    };
  }

  ChatMessageModel copyWith({
    String? id,
    String? content,
    bool? isBot,
    DateTime? timestamp,
    String? stepId,
    String? stepCode,
    List<String>? quickReplies,
    String? answerType,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      isBot: isBot ?? this.isBot,
      timestamp: timestamp ?? this.timestamp,
      stepId: stepId ?? this.stepId,
      stepCode: stepCode ?? this.stepCode,
      quickReplies: quickReplies ?? this.quickReplies,
      answerType: answerType ?? this.answerType,
    );
  }
}

