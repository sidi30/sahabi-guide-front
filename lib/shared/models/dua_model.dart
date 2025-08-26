import 'dart:convert';

class DuaModel {
  final String id;
  final String title;
  final String description;
  final String type;
  final String frequency;
  final String arabicText;
  final String transliteration;
  final String translation;
  final String? audioPath;
  final int duration;
  final int priority;
  final List<String> tags;
  final bool isActive;

  DuaModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.frequency,
    required this.arabicText,
    required this.transliteration,
    required this.translation,
    this.audioPath,
    required this.duration,
    required this.priority,
    required this.tags,
    required this.isActive,
  });

  DuaModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? frequency,
    String? arabicText,
    String? transliteration,
    String? translation,
    String? audioPath,
    int? duration,
    int? priority,
    List<String>? tags,
    bool? isActive,
  }) {
    return DuaModel(
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
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'frequency': frequency,
      'arabicText': arabicText,
      'transliteration': transliteration,
      'translation': translation,
      'audioPath': audioPath,
      'duration': duration,
      'priority': priority,
      'tags': tags,
      'isActive': isActive,
    };
  }

  factory DuaModel.fromMap(Map<String, dynamic> map) {
    return DuaModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? '',
      frequency: map['frequency'] ?? '',
      arabicText: map['arabicText'] ?? '',
      transliteration: map['transliteration'] ?? '',
      translation: map['translation'] ?? '',
      audioPath: map['audioPath'],
      duration: map['duration'] ?? 0,
      priority: map['priority'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      isActive: map['isActive'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory DuaModel.fromJson(String source) => 
      DuaModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'DuaModel(id: $id, title: $title, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is DuaModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}