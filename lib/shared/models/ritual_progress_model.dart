import 'dart:convert';

enum RitualStatus {
  pending,
  started,
  completed,
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
      'status': status.name.toUpperCase(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory RitualProgressModel.fromMap(Map<String, dynamic> map) {
    return RitualProgressModel(
      ritualId: map['ritualId'] ?? '',
      status: _parseStatus(map['status']),
      startedAt: map['startedAt'] != null 
          ? DateTime.parse(map['startedAt']) 
          : null,
      completedAt: map['completedAt'] != null 
          ? DateTime.parse(map['completedAt']) 
          : null,
    );
  }

  static RitualStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'COMPLETED':
        return RitualStatus.completed;
      case 'STARTED':
        return RitualStatus.started;
      case 'PENDING':
      default:
        return RitualStatus.pending;
    }
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