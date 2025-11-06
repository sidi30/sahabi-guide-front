import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import '../models/hajj_step_model.dart';
import '../models/faq_model.dart';

/// Service de gestion de la base de connaissances Hajj
/// Charge depuis assets/data/hajj_knowledge_base.json
class KnowledgeBaseService {
  final Logger logger;
  
  List<HajjStepModel> _steps = [];
  List<FAQModel> _faqs = [];
  Map<String, List<String>> _urgentReminders = {};
  Map<String, dynamic> _locationHints = {};
  
  bool _initialized = false;

  KnowledgeBaseService({required this.logger});

  /// Initialise le service en chargeant le JSON
  Future<void> initialize() async {
    if (_initialized) {
      logger.d('KnowledgeBase already initialized');
      return;
    }

    try {
      logger.d('Loading hajj_knowledge_base.json...');
      
      final jsonString = await rootBundle.loadString(
        'assets/data/hajj_knowledge_base.json',
      );
      
      final data = json.decode(jsonString) as Map<String, dynamic>;
      
      // Parse les étapes Hajj
      final stepsJson = data['hajj_steps'] as List<dynamic>;
      _steps = stepsJson
          .map((e) => HajjStepModel.fromJson(e as Map<String, dynamic>))
          .toList();
      
      // Parse les FAQs
      final faqsJson = data['faqs'] as List<dynamic>;
      _faqs = faqsJson
          .map((e) => FAQModel.fromJson(e as Map<String, dynamic>))
          .toList();
      
      // Parse les rappels urgents
      _urgentReminders = Map<String, List<String>>.from(
        (data['urgent_reminders'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            key,
            (value as List<dynamic>).map((e) => e as String).toList(),
          ),
        ),
      );
      
      // Parse les indices de localisation
      _locationHints = data['location_hints'] as Map<String, dynamic>;
      
      _initialized = true;
      
      logger.i('✅ KnowledgeBase initialized: ${_steps.length} steps, ${_faqs.length} FAQs');
    } catch (e, stackTrace) {
      logger.e('❌ Error initializing KnowledgeBase: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Récupère toutes les étapes Hajj triées par ordre
  List<HajjStepModel> getAllSteps() {
    _ensureInitialized();
    return List.unmodifiable(_steps);
  }

  /// Récupère une étape par son ID
  HajjStepModel? getStepById(String stepId) {
    _ensureInitialized();
    try {
      return _steps.firstWhere((step) => step.id == stepId);
    } catch (e) {
      logger.w('Step not found: $stepId');
      return null;
    }
  }

  /// Récupère la première étape (Ihram)
  HajjStepModel? getFirstStep() {
    _ensureInitialized();
    if (_steps.isEmpty) return null;
    return _steps.first;
  }

  /// Récupère l'étape suivante basée sur la réponse
  HajjStepModel? getNextStep(String currentStepId, String userAnswer) {
    _ensureInitialized();
    
    final currentStep = getStepById(currentStepId);
    if (currentStep == null) return null;
    
    // Si étape finale
    if (currentStep.isFinal == true) {
      return null;
    }
    
    // Détermine l'étape suivante selon la réponse
    String? nextStepId;
    
    // Normalise la réponse
    final normalizedAnswer = _normalizeAnswer(userAnswer);
    
    if (normalizedAnswer == 'OUI' || normalizedAnswer == 'YES') {
      nextStepId = currentStep.nextStepYes;
    } else if (normalizedAnswer == 'NON' || normalizedAnswer == 'NO') {
      nextStepId = currentStep.nextStepNo;
    } else {
      // Par défaut, avance à l'étape suivante
      nextStepId = currentStep.nextStepYes;
    }
    
    if (nextStepId == null) return null;
    
    return getStepById(nextStepId);
  }

  /// Recherche dans les FAQs
  List<FAQModel> searchFAQs(String query, {int limit = 5}) {
    _ensureInitialized();
    
    if (query.trim().isEmpty) return [];
    
    // Filtre les FAQs qui correspondent
    final matchingFAQs = _faqs
        .where((faq) => faq.matchesQuery(query))
        .toList();
    
    // Trie par score de pertinence
    matchingFAQs.sort((a, b) => 
      b.getRelevanceScore(query).compareTo(a.getRelevanceScore(query))
    );
    
    // Limite les résultats
    return matchingFAQs.take(limit).toList();
  }

  /// Récupère la meilleure FAQ pour une requête
  FAQModel? getBestFAQ(String query) {
    final results = searchFAQs(query, limit: 1);
    return results.isNotEmpty ? results.first : null;
  }

  /// Récupère les rappels urgents pour une étape
  List<String> getUrgentReminders(String stepId) {
    _ensureInitialized();
    return _urgentReminders[stepId] ?? [];
  }

  /// Récupère les indices de localisation
  Map<String, dynamic> getLocationHints() {
    _ensureInitialized();
    return Map.unmodifiable(_locationHints);
  }

  /// Récupère un indice de localisation spécifique
  Map<String, dynamic>? getLocationHint(String locationKey) {
    _ensureInitialized();
    return _locationHints[locationKey] as Map<String, dynamic>?;
  }

  /// Vérifie si le service est initialisé
  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('KnowledgeBaseService not initialized. Call initialize() first.');
    }
  }

  /// Normalise une réponse pour la comparaison
  String _normalizeAnswer(String answer) {
    String normalized = answer.toUpperCase().trim();
    
    // Enlève les accents français
    normalized = normalized
        .replaceAll('É', 'E')
        .replaceAll('È', 'E')
        .replaceAll('Ê', 'E')
        .replaceAll('Ë', 'E')
        .replaceAll('À', 'A')
        .replaceAll('Â', 'A')
        .replaceAll('Ù', 'U')
        .replaceAll('Û', 'U')
        .replaceAll('Ô', 'O')
        .replaceAll('Î', 'I')
        .replaceAll('Ï', 'I')
        .replaceAll('Ç', 'C');
    
    // Enlève la ponctuation
    normalized = normalized.replaceAll(RegExp(r'[^\w\s]'), '');
    
    return normalized;
  }

  /// Statistiques
  Map<String, int> getStats() {
    return {
      'total_steps': _steps.length,
      'total_faqs': _faqs.length,
      'urgent_reminders': _urgentReminders.length,
      'location_hints': _locationHints.length,
    };
  }

  /// Dispose
  void dispose() {
    _steps = [];
    _faqs = [];
    _urgentReminders = {};
    _locationHints = {};
    _initialized = false;
    logger.d('KnowledgeBaseService disposed');
  }
}

