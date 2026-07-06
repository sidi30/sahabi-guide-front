/// Citation RAG renvoyée par le backend sous `sources`.
/// `score` = pertinence (0..1) ; `ritualId` peut être null (source hors rituel).
class BotSource {
  final String title;
  final String? ritualId;
  final double score;

  const BotSource({
    required this.title,
    this.ritualId,
    this.score = 0.0,
  });

  factory BotSource.fromJson(Map<String, dynamic> json) {
    final raw = json['score'];
    return BotSource(
      title: (json['title'] as String?)?.trim() ?? '',
      ritualId: json['ritualId'] as String?,
      score: raw is num ? raw.toDouble() : 0.0,
    );
  }
}

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

  /// Libellés d'AFFICHAGE (localisés) des réponses rapides DYNAMIQUES : map
  /// `valeur FR canonique -> libellé traduit`. Le rendu affiche le libellé
  /// traduit tandis que la valeur ENVOYÉE au bot reste la clé (FR canonique),
  /// pour que le matching des étapes (Oui/Non/…) reste correct quelle que soit
  /// la langue affichée. `null` => on affiche la valeur brute (déjà en langue
  /// d'origine). Transitoire : recalculé à chaque traduction, non persisté.
  final Map<String, String>? quickReplyLabels;

  /// Citations RAG renvoyées par le backend (peut être vide / null pour les
  /// anciennes réponses ou les messages locaux).
  final List<BotSource>? sources;

  /// Confiance du backend : `high` (défaut) ou `low`.
  final String? confidence;

  /// Le backend a préféré s'abstenir (réponse incertaine).
  final bool abstained;

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
    this.quickReplyLabels,
    this.sources,
    this.confidence,
    this.abstained = false,
  });

  /// Vrai s'il faut afficher la note "réponse incertaine".
  bool get isLowConfidence => abstained || confidence == 'low';

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
    List<BotSource>? sources,
    String? confidence,
    bool abstained = false,
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
      sources: sources,
      confidence: confidence,
      abstained: abstained,
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
    Map<String, String>? quickReplyLabels,
    bool clearQuickReplyLabels = false,
    List<BotSource>? sources,
    String? confidence,
    bool? abstained,
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
      quickReplyLabels: clearQuickReplyLabels
          ? null
          : (quickReplyLabels ?? this.quickReplyLabels),
      sources: sources ?? this.sources,
      confidence: confidence ?? this.confidence,
      abstained: abstained ?? this.abstained,
    );
  }
}
