/// Modèle de message du bot Hajj
/// Support FR/AR, réponses rapides, métadonnées
class BotMessageModel {
  final String id;
  final String content;
  final String? contentAr;
  final bool isBot;
  final DateTime timestamp;
  final List<String>? quickReplies;
  final String? relatedStepId;
  final String? relatedRitualId;
  final Map<String, dynamic>? metadata;

  const BotMessageModel({
    required this.id,
    required this.content,
    this.contentAr,
    required this.isBot,
    required this.timestamp,
    this.quickReplies,
    this.relatedStepId,
    this.relatedRitualId,
    this.metadata,
  });

  // Factory constructeur pour message du bot
  factory BotMessageModel.bot({
    required String id,
    required String content,
    String? contentAr,
    List<String>? quickReplies,
    String? relatedStepId,
    String? relatedRitualId,
  }) {
    return BotMessageModel(
      id: id,
      content: content,
      contentAr: contentAr,
      isBot: true,
      timestamp: DateTime.now(),
      quickReplies: quickReplies,
      relatedStepId: relatedStepId,
      relatedRitualId: relatedRitualId,
    );
  }

  // Factory constructeur pour message utilisateur
  factory BotMessageModel.user({
    required String id,
    required String content,
  }) {
    return BotMessageModel(
      id: id,
      content: content,
      isBot: false,
      timestamp: DateTime.now(),
    );
  }

  // Copie avec modifications
  BotMessageModel copyWith({
    String? id,
    String? content,
    String? contentAr,
    bool? isBot,
    DateTime? timestamp,
    List<String>? quickReplies,
    String? relatedStepId,
    String? relatedRitualId,
    Map<String, dynamic>? metadata,
  }) {
    return BotMessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      contentAr: contentAr ?? this.contentAr,
      isBot: isBot ?? this.isBot,
      timestamp: timestamp ?? this.timestamp,
      quickReplies: quickReplies ?? this.quickReplies,
      relatedStepId: relatedStepId ?? this.relatedStepId,
      relatedRitualId: relatedRitualId ?? this.relatedRitualId,
      metadata: metadata ?? this.metadata,
    );
  }
}

