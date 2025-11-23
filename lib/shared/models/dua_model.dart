import 'package:flutter/material.dart';
import 'package:sahabi_guide/shared/utils/language_utils.dart';

enum DuaType {
  daily,
  hajj,
  umrah,
  special,
  protection,
  gratitude,
}

class DuaModel {
  final String id;
  final String title;
  final String description;
  final String arabicText;
  final String transliteration;
  final String translation;
  final DuaType type;
  final String audioPath;
  final Duration duration;
  final int priority;
  final List<String> tags;
  final bool isActive;
  final bool isFavorite;
  final Map<String, String> translations;
  final Map<String, String> audioPaths; // langue -> chemin audio
  final String? ritualId; // Rituel associé
  final DateTime? lastPlayedAt;
  final int playCount;

  const DuaModel({
    required this.id,
    required this.title,
    required this.description,
    required this.arabicText,
    required this.transliteration,
    required this.translation,
    this.type = DuaType.daily,
    required this.audioPath,
    this.duration = const Duration(minutes: 1),
    this.priority = 1,
    this.tags = const [],
    this.isActive = true,
    this.isFavorite = false,
    this.translations = const {},
    this.audioPaths = const {},
    this.ritualId,
    this.lastPlayedAt,
    this.playCount = 0,
  });

  factory DuaModel.fromJson(Map<String, dynamic> json) {
    // L'API backend retourne: id, arabicText, frenchTranslation, englishTranslation, audioUrl, ritualId, orderIndex
    // On adapte pour correspondre au modèle Flutter

    final arabicText = json['arabicText'] ?? json['text'] ?? '';
    final frenchTranslation =
        json['frenchTranslation'] ?? json['translation'] ?? '';
    final englishTranslation = json['englishTranslation'] ?? '';
    final audioUrl = json['audioUrl'] ?? json['audioPath'] ?? '';

    // Construire les maps de traductions et d'audio
    final Map<String, String> translations = {
      'fr': frenchTranslation,
      'ar': arabicText,
      if (englishTranslation.isNotEmpty) 'en': englishTranslation,
      ..._extractLanguageMap(json['translations']),
    };

    final Map<String, String> audioPaths = {
      ..._extractLanguageMap(json['audioPaths']),
    };
    if (audioUrl.isNotEmpty) {
      final defaultLang = LanguageUtils.normalize(json['audioLanguage']);
      audioPaths.putIfAbsent(defaultLang, () => audioUrl);
    }

    return DuaModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ??
          frenchTranslation
              .split(' ')
              .take(5)
              .join(' '), // Première phrase comme titre
      description: json['description'] ?? frenchTranslation,
      arabicText: arabicText,
      transliteration:
          json['transliteration'] ?? '', // Pas disponible dans l'API actuelle
      translation: frenchTranslation,
      type: _parseDuaType(json['type']),
      audioPath: audioUrl,
      duration: Duration(seconds: json['duration'] ?? 60),
      priority: json['priority'] ?? json['orderIndex'] ?? 1,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      isActive: json['isActive'] ?? true,
      isFavorite: json['isFavorite'] ?? false,
      translations: translations,
      audioPaths: audioPaths,
      ritualId: json['ritualId']?.toString(),
      lastPlayedAt: json['lastPlayedAt'] != null
          ? DateTime.parse(json['lastPlayedAt'])
          : null,
      playCount: json['playCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'arabicText': arabicText,
      'transliteration': transliteration,
      'translation': translation,
      'type': type.name,
      'audioPath': audioPath,
      'duration': duration.inSeconds,
      'priority': priority,
      'tags': tags,
      'isActive': isActive,
      'isFavorite': isFavorite,
      'translations': translations,
      'audioPaths': audioPaths,
      'ritualId': ritualId,
      'lastPlayedAt': lastPlayedAt?.toIso8601String(),
      'playCount': playCount,
    };
  }

  DuaModel copyWith({
    String? id,
    String? title,
    String? description,
    String? arabicText,
    String? transliteration,
    String? translation,
    DuaType? type,
    String? audioPath,
    Duration? duration,
    int? priority,
    List<String>? tags,
    bool? isActive,
    bool? isFavorite,
    Map<String, String>? translations,
    Map<String, String>? audioPaths,
    String? ritualId,
    DateTime? lastPlayedAt,
    int? playCount,
  }) {
    return DuaModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      type: type ?? this.type,
      audioPath: audioPath ?? this.audioPath,
      duration: duration ?? this.duration,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      isFavorite: isFavorite ?? this.isFavorite,
      translations: translations ?? this.translations,
      audioPaths: audioPaths ?? this.audioPaths,
      ritualId: ritualId ?? this.ritualId,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      playCount: playCount ?? this.playCount,
    );
  }

  // Helper methods
  String getTranslation(String language) {
    return translations[language] ?? translation;
  }

  String getAudioPath(String language) {
    for (final code in LanguageUtils.fallbackOrder(language)) {
      final candidate = audioPaths[code];
      if (candidate != null && candidate.isNotEmpty) {
        return candidate;
      }
    }
    return audioPath;
  }

  Color getTypeColor() {
    switch (type) {
      case DuaType.hajj:
        return Colors.green;
      case DuaType.umrah:
        return Colors.blue;
      case DuaType.daily:
        return Colors.orange;
      case DuaType.special:
        return Colors.purple;
      case DuaType.protection:
        return Colors.red;
      case DuaType.gratitude:
        return Colors.teal;
    }
  }

  IconData getTypeIcon() {
    switch (type) {
      case DuaType.hajj:
        return Icons.location_on; // Logo pin pour Hajj
      case DuaType.umrah:
        return Icons.location_on;
      case DuaType.daily:
        return Icons.schedule;
      case DuaType.special:
        return Icons.star;
      case DuaType.protection:
        return Icons.shield;
      case DuaType.gratitude:
        return Icons.favorite;
    }
  }

  String getFormattedDuration() {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  static DuaType _parseDuaType(String? type) {
    switch (type?.toLowerCase()) {
      case 'hajj':
        return DuaType.hajj;
      case 'umrah':
        return DuaType.umrah;
      case 'daily':
        return DuaType.daily;
      case 'special':
        return DuaType.special;
      case 'protection':
        return DuaType.protection;
      case 'gratitude':
        return DuaType.gratitude;
      default:
        return DuaType.daily;
    }
  }

  @override
  String toString() {
    return 'DuaModel(id: $id, title: $title, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DuaModel &&
        other.id == id &&
        other.title == title &&
        other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ type.hashCode;
  }
}

Map<String, String> _extractLanguageMap(dynamic source) {
  if (source is Map) {
    final normalized = <String, String>{};
    source.forEach((key, value) {
      if (value == null) return;
      final normalizedKey = LanguageUtils.normalize(key.toString());
      normalized[normalizedKey] = value.toString();
    });
    return normalized;
  }
  return {};
}
