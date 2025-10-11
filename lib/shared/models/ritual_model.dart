import 'dart:convert';

enum RitualStatus {
  notStarted,
  inProgress,
  completed,
}

class RitualModel {
  final String id;
  final String code;
  final String title;
  final int order;
  final String description;
  final List<String> mediaRefs;
  final DateTime createdAt;
  final DateTime updatedAt;

  RitualModel({
    required this.id,
    required this.code,
    required this.title,
    required this.order,
    required this.description,
    this.mediaRefs = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  RitualModel copyWith({
    String? id,
    String? code,
    String? title,
    int? order,
    String? description,
    List<String>? mediaRefs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RitualModel(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      order: order ?? this.order,
      description: description ?? this.description,
      mediaRefs: mediaRefs ?? this.mediaRefs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'order': order,
      'description': description,
      'mediaRefs': mediaRefs,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory RitualModel.fromMap(Map<String, dynamic> map) {
    return RitualModel(
      id: map['id'] ?? '',
      code: map['code'] ?? '',
      title: map['title'] ?? '',
      order: map['order'] ?? 0,
      description: map['description'] ?? '',
      mediaRefs: List<String>.from(map['mediaRefs'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory RitualModel.fromJson(String source) => 
      RitualModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'RitualModel(id: $id, code: $code, title: $title, order: $order, description: $description, mediaRefs: $mediaRefs, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is RitualModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class DuaModel {
  final String id;
  final String title;
  final String text;
  final String audioUrl;
  final List<String> tags;

  DuaModel({
    required this.id,
    required this.title,
    required this.text,
    required this.audioUrl,
    this.tags = const [],
  });

  DuaModel copyWith({
    String? id,
    String? title,
    String? text,
    String? audioUrl,
    List<String>? tags,
  }) {
    return DuaModel(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      audioUrl: audioUrl ?? this.audioUrl,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'audioUrl': audioUrl,
      'tags': tags,
    };
  }

  factory DuaModel.fromMap(Map<String, dynamic> map) {
    return DuaModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      text: map['text'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory DuaModel.fromJson(String source) => 
      DuaModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'DuaModel(id: $id, title: $title, text: $text, audioUrl: $audioUrl, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is DuaModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class RitualProgressModel {
  final String ritualId;
  final RitualStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;

  RitualProgressModel({
    required this.ritualId,
    required this.status,
    this.startedAt,
    this.completedAt,
  });

  RitualProgressModel copyWith({
    String? ritualId,
    RitualStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return RitualProgressModel(
      ritualId: ritualId ?? this.ritualId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ritualId': ritualId,
      'status': status.name,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory RitualProgressModel.fromMap(Map<String, dynamic> map) {
    return RitualProgressModel(
      ritualId: map['ritualId'] ?? '',
      status: RitualStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => RitualStatus.notStarted,
      ),
      startedAt: map['startedAt'] != null 
          ? DateTime.parse(map['startedAt']) 
          : null,
      completedAt: map['completedAt'] != null 
          ? DateTime.parse(map['completedAt']) 
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory RitualProgressModel.fromJson(String source) => 
      RitualProgressModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'RitualProgressModel(ritualId: $ritualId, status: $status, startedAt: $startedAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is RitualProgressModel && other.ritualId == ritualId;
  }

  @override
  int get hashCode => ritualId.hashCode;
}
