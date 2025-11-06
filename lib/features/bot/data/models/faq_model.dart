/// Modèle FAQ (Foire Aux Questions)
class FAQModel {
  final String id;
  final String question;
  final String questionAr;
  final String answer;
  final List<String> keywords;
  final List<String> relatedSteps;
  final bool? isCritical;

  const FAQModel({
    required this.id,
    required this.question,
    required this.questionAr,
    required this.answer,
    required this.keywords,
    required this.relatedSteps,
    this.isCritical,
  });

  factory FAQModel.fromJson(Map<String, dynamic> json) {
    return FAQModel(
      id: json['id'] as String,
      question: json['question'] as String,
      questionAr: json['question_ar'] as String,
      answer: json['answer'] as String,
      keywords: (json['keywords'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      relatedSteps: (json['related_steps'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isCritical: json['is_critical'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'question_ar': questionAr,
      'answer': answer,
      'keywords': keywords,
      'related_steps': relatedSteps,
      'is_critical': isCritical,
    };
  }

  /// Vérifie si une requête utilisateur correspond à cette FAQ
  bool matchesQuery(String query) {
    final lowerQuery = query.toLowerCase();
    
    // Recherche dans les mots-clés
    for (final keyword in keywords) {
      if (lowerQuery.contains(keyword.toLowerCase())) {
        return true;
      }
    }
    
    // Recherche dans la question
    if (question.toLowerCase().contains(lowerQuery) ||
        lowerQuery.contains(question.toLowerCase())) {
      return true;
    }
    
    return false;
  }

  /// Score de pertinence (0-100)
  int getRelevanceScore(String query) {
    final lowerQuery = query.toLowerCase();
    int score = 0;
    
    // Points pour chaque mot-clé trouvé
    for (final keyword in keywords) {
      if (lowerQuery.contains(keyword.toLowerCase())) {
        score += 20;
      }
    }
    
    // Points si question correspond exactement
    if (question.toLowerCase() == lowerQuery) {
      score += 50;
    }
    
    // Bonus si critique
    if (isCritical == true) {
      score += 10;
    }
    
    return score > 100 ? 100 : score;
  }
}

