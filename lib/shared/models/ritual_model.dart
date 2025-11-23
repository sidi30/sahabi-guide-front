import 'package:flutter/material.dart';
import 'package:sahabi_guide/shared/utils/language_utils.dart';

enum RitualType {
  hajj,
  umrah,
  daily,
  special,
}

enum RitualStatus {
  pending,
  active,
  completed,
  overdue,
}

class RitualModel {
  final String id;
  final String name;
  final int order;
  final String description;
  final RitualType type;
  final RitualStatus status;
  final DateTime? scheduledTime;
  final DateTime? completedAt;
  final Duration? estimatedDuration;
  final List<String> audioPaths;
  final String? videoPath;
  final Map<String, String> audioSources;
  final Map<String, String> videoSources;
  // Nouveaux champs consommés depuis l'API enrichie
  final List<String> steps;
  final Map<String, String> practicalTips;
  final int? contentVersion;
  final Map<String, String> translations;
  final List<String> tags;
  final bool isActive;
  final String? nextRitualId;
  final String? previousRitualId;

  const RitualModel({
    required this.id,
    required this.name,
    required this.order,
    required this.description,
    this.type = RitualType.hajj,
    this.status = RitualStatus.pending,
    this.scheduledTime,
    this.completedAt,
    this.estimatedDuration,
    this.audioPaths = const [],
    this.videoPath,
    this.audioSources = const {},
    this.videoSources = const {},
    this.steps = const [],
    this.practicalTips = const {},
    this.contentVersion,
    this.translations = const {},
    this.tags = const [],
    this.isActive = false,
    this.nextRitualId,
    this.previousRitualId,
  });

  factory RitualModel.fromJson(Map<String, dynamic> json) {
    final rawAudio = json['audioPaths'];
    List<String> legacyAudio = const [];
    Map<String, String> audioSources = {};
    if (rawAudio is Map) {
      audioSources = _extractMediaMap(rawAudio);
    } else if (rawAudio is List) {
      legacyAudio = List<String>.from(rawAudio.map((e) => e.toString()));
    }

    final rawVideo = json['videoPaths'] ?? json['videoSources'];
    Map<String, String> videoSources = {};
    if (rawVideo is Map) {
      videoSources = _extractMediaMap(rawVideo);
    }

    final resolvedVideoPath = json['videoPath'] ??
        videoSources[LanguageUtils.defaultLanguage] ??
        (videoSources.isNotEmpty ? videoSources.values.first : null);

    return RitualModel(
      id: json['id'] as String,
      name: json['name'] as String,
      order: json['order'] as int,
      description: json['description'] as String,
      type: _parseRitualType(json['type']),
      status: _parseRitualStatus(json['status']),
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      estimatedDuration: json['estimatedDuration'] != null
          ? Duration(minutes: json['estimatedDuration'])
          : null,
      audioPaths: legacyAudio,
      videoPath: resolvedVideoPath,
      audioSources: audioSources,
      videoSources: videoSources,
      steps: List<String>.from(json['steps'] ?? json['stepsList'] ?? const []),
      practicalTips:
          Map<String, String>.from(json['practicalTips'] ?? const {}),
      contentVersion: json['contentVersion'],
      translations: Map<String, String>.from(json['translations'] ?? {}),
      tags: List<String>.from(json['tags'] ?? []),
      isActive: json['isActive'] ?? false,
      nextRitualId: json['nextRitualId'],
      previousRitualId: json['previousRitualId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'order': order,
      'description': description,
      'type': type.name,
      'status': status.name,
      'scheduledTime': scheduledTime?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'estimatedDuration': estimatedDuration?.inMinutes,
      'audioPaths': audioPaths,
      'videoPath': videoPath,
      'audioSources': audioSources,
      'videoSources': videoSources,
      'steps': steps,
      'practicalTips': practicalTips,
      'contentVersion': contentVersion,
      'translations': translations,
      'tags': tags,
      'isActive': isActive,
      'nextRitualId': nextRitualId,
      'previousRitualId': previousRitualId,
    };
  }

  RitualModel copyWith({
    String? id,
    String? name,
    int? order,
    String? description,
    RitualType? type,
    RitualStatus? status,
    DateTime? scheduledTime,
    DateTime? completedAt,
    Duration? estimatedDuration,
    List<String>? audioPaths,
    String? videoPath,
    Map<String, String>? audioSources,
    Map<String, String>? videoSources,
    Map<String, String>? translations,
    List<String>? tags,
    bool? isActive,
    String? nextRitualId,
    String? previousRitualId,
  }) {
    return RitualModel(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      completedAt: completedAt ?? this.completedAt,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      audioPaths: audioPaths ?? this.audioPaths,
      videoPath: videoPath ?? this.videoPath,
      audioSources: audioSources ?? this.audioSources,
      videoSources: videoSources ?? this.videoSources,
      translations: translations ?? this.translations,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      nextRitualId: nextRitualId ?? this.nextRitualId,
      previousRitualId: previousRitualId ?? this.previousRitualId,
    );
  }

  // Helper methods
  bool get isCompleted => status == RitualStatus.completed;
  bool get isPending => status == RitualStatus.pending;
  bool get isOverdue => status == RitualStatus.overdue;

  String getTranslation(String language) {
    return translations[language] ?? name;
  }

  bool get hasAudio =>
      audioSources.values.any((path) => path.isNotEmpty) ||
      audioPaths.isNotEmpty;

  bool get hasVideo =>
      videoSources.values.any((path) => path.isNotEmpty) ||
      (videoPath != null && videoPath!.isNotEmpty);

  String? getAudioPath(String language) {
    for (final code in LanguageUtils.fallbackOrder(language)) {
      final candidate = audioSources[code];
      if (candidate != null && candidate.isNotEmpty) {
        return candidate;
      }
    }
    return audioPaths.isNotEmpty ? audioPaths.first : null;
  }

  String? getVideoUrl(String language) {
    for (final code in LanguageUtils.fallbackOrder(language)) {
      final candidate = videoSources[code];
      if (candidate != null && candidate.isNotEmpty) {
        return candidate;
      }
    }
    return videoPath;
  }

  Color getStatusColor() {
    switch (status) {
      case RitualStatus.completed:
        return Colors.green;
      case RitualStatus.active:
        return Colors.blue;
      case RitualStatus.overdue:
        return Colors.red;
      case RitualStatus.pending:
        return Colors.grey;
    }
  }

  IconData getStatusIcon() {
    switch (status) {
      case RitualStatus.completed:
        return Icons.check_circle;
      case RitualStatus.active:
        return Icons.access_time;
      case RitualStatus.overdue:
        return Icons.warning;
      case RitualStatus.pending:
        return Icons.circle_outlined;
    }
  }

  static RitualType _parseRitualType(String? type) {
    switch (type?.toLowerCase()) {
      case 'hajj':
        return RitualType.hajj;
      case 'umrah':
        return RitualType.umrah;
      case 'daily':
        return RitualType.daily;
      case 'special':
        return RitualType.special;
      default:
        return RitualType.hajj;
    }
  }

  static RitualStatus _parseRitualStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return RitualStatus.completed;
      case 'active':
        return RitualStatus.active;
      case 'overdue':
        return RitualStatus.overdue;
      case 'pending':
      default:
        return RitualStatus.pending;
    }
  }

  @override
  String toString() {
    return 'RitualModel(id: $id, name: $name, order: $order, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RitualModel &&
        other.id == id &&
        other.name == name &&
        other.order == order &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ order.hashCode ^ status.hashCode;
  }
}

Map<String, String> _extractMediaMap(dynamic source) {
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
