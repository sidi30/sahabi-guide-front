import 'dart:convert';

enum RitualType {
  prayer,
  dua,
  dhikr,
  reading,
  charity,
  fasting,
}

enum RitualFrequency {
  daily,
  weekly,
  monthly,
  yearly,
  occasional,
}

class RitualModel {
  final String id;
  final String title;
  final String description;
  final RitualType type;
  final RitualFrequency frequency;
  final String? arabicText;
  final String? transliteration;
  final String? translation;
  final String? audioPath;
  final Duration? duration;
  final List<String> tags;
  final DateTime? scheduledTime;
  final bool isCompleted;
  final bool isActive;
  final int priority;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  RitualModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.frequency,
    this.arabicText,
    this.transliteration,
    this.translation,
    this.audioPath,
    this.duration,
    this.tags = const [],
    this.scheduledTime,
    this.isCompleted = false,
    this.isActive = true,
    this.priority = 0,
    this.imageUrl,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  RitualModel copyWith({
    String? id,
    String? title,
    String? description,
    RitualType? type,
    RitualFrequency? frequency,
    String? arabicText,
    String? transliteration,
    String? translation,
    String? audioPath,
    Duration? duration,
    List<String>? tags,
    DateTime? scheduledTime,
    bool? isCompleted,
    bool? isActive,
    int? priority,
    String? imageUrl,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RitualModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      audioPath: audioPath ?? this.audioPath,
      duration: duration ?? this.duration,
      tags: tags ?? this.tags,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isCompleted: isCompleted ?? this.isCompleted,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'frequency': frequency.name,
      'arabicText': arabicText,
      'transliteration': transliteration,
      'translation': translation,
      'audioPath': audioPath,
      'duration': duration?.inSeconds,
      'tags': tags,
      'scheduledTime': scheduledTime?.toIso8601String(),
      'isCompleted': isCompleted,
      'isActive': isActive,
      'priority': priority,
      'imageUrl': imageUrl,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory RitualModel.fromMap(Map<String, dynamic> map) {
    return RitualModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: RitualType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => RitualType.dua,
      ),
      frequency: RitualFrequency.values.firstWhere(
        (e) => e.name == map['frequency'],
        orElse: () => RitualFrequency.daily,
      ),
      arabicText: map['arabicText'],
      transliteration: map['transliteration'],
      translation: map['translation'],
      audioPath: map['audioPath'],
      duration: map['duration'] != null 
          ? Duration(seconds: map['duration']) 
          : null,
      tags: List<String>.from(map['tags'] ?? []),
      scheduledTime: map['scheduledTime'] != null 
          ? DateTime.parse(map['scheduledTime']) 
          : null,
      isCompleted: map['isCompleted'] ?? false,
      isActive: map['isActive'] ?? true,
      priority: map['priority'] ?? 0,
      imageUrl: map['imageUrl'],
      metadata: map['metadata'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory RitualModel.fromJson(String source) => 
      RitualModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'RitualModel(id: $id, title: $title, description: $description, type: $type, frequency: $frequency, arabicText: $arabicText, transliteration: $transliteration, translation: $translation, audioPath: $audioPath, duration: $duration, tags: $tags, scheduledTime: $scheduledTime, isCompleted: $isCompleted, isActive: $isActive, priority: $priority, imageUrl: $imageUrl, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is RitualModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
