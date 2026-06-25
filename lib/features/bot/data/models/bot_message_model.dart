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

  /// Texte tel que produit la PREMIÈRE fois (langue d'origine). Sert de SOURCE
  /// pour la traduction au changement de langue : on traduit toujours depuis
  /// [originalContent] -> nouvelle langue (jamais la traduction d'une
  /// traduction), pour qu'un re-switch reste fidèle. `null` => égal à [content].
  final String? originalContent;

  /// Code 2 lettres (`fr|en|ar|ha`) de la langue de [originalContent].
  final String? originalLang;

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
    this.originalContent,
    this.originalLang,
  });

  /// Texte source pour la traduction (retombe sur [content] si non renseigné).
  String get sourceContent => originalContent ?? content;

  // Factory constructeur pour message du bot
  factory BotMessageModel.bot({
    required String id,
    required String content,
    String? contentAr,
    List<String>? quickReplies,
    String? relatedStepId,
    String? relatedRitualId,
    String? originalContent,
    String? originalLang,
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
      originalContent: originalContent ?? content,
      originalLang: originalLang,
    );
  }

  // Factory constructeur pour message utilisateur
  factory BotMessageModel.user({
    required String id,
    required String content,
    String? originalContent,
    String? originalLang,
  }) {
    return BotMessageModel(
      id: id,
      content: content,
      isBot: false,
      timestamp: DateTime.now(),
      originalContent: originalContent ?? content,
      originalLang: originalLang,
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
    String? originalContent,
    String? originalLang,
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
      originalContent: originalContent ?? this.originalContent,
      originalLang: originalLang ?? this.originalLang,
    );
  }
}
