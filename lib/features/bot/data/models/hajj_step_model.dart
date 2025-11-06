/// Modèle d'une étape du Hajj
class HajjStepModel {
  final String id;
  final int order;
  final String name;
  final String nameAr;
  final String question;
  final String questionAr;
  final String description;
  final List<String> quickReplies;
  final String? nextStepYes;
  final String? nextStepNo;
  final String? relatedRitualId;
  final bool? isCritical;
  final bool? isFinal;
  final String? urgentReminder;
  final Map<String, dynamic>? locationContext;

  const HajjStepModel({
    required this.id,
    required this.order,
    required this.name,
    required this.nameAr,
    required this.question,
    required this.questionAr,
    required this.description,
    required this.quickReplies,
    this.nextStepYes,
    this.nextStepNo,
    this.relatedRitualId,
    this.isCritical,
    this.isFinal,
    this.urgentReminder,
    this.locationContext,
  });

  factory HajjStepModel.fromJson(Map<String, dynamic> json) {
    return HajjStepModel(
      id: json['id'] as String,
      order: json['order'] as int,
      name: json['name'] as String,
      nameAr: json['name_ar'] as String,
      question: json['question'] as String,
      questionAr: json['question_ar'] as String,
      description: json['description'] as String,
      quickReplies: (json['quick_replies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      nextStepYes: json['next_step_yes'] as String?,
      nextStepNo: json['next_step_no'] as String?,
      relatedRitualId: json['related_ritual_id'] as String?,
      isCritical: json['is_critical'] as bool?,
      isFinal: json['is_final'] as bool?,
      urgentReminder: json['urgent_reminder'] as String?,
      locationContext: json['location_context'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      'name': name,
      'name_ar': nameAr,
      'question': question,
      'question_ar': questionAr,
      'description': description,
      'quick_replies': quickReplies,
      'next_step_yes': nextStepYes,
      'next_step_no': nextStepNo,
      'related_ritual_id': relatedRitualId,
      'is_critical': isCritical,
      'is_final': isFinal,
      'urgent_reminder': urgentReminder,
      'location_context': locationContext,
    };
  }

  /// Récupère la question localisée
  String getLocalizedQuestion(String locale) {
    if (locale == 'ar') return questionAr;
    return question;
  }

  /// Récupère le nom localisé
  String getLocalizedName(String locale) {
    if (locale == 'ar') return nameAr;
    return name;
  }
}

