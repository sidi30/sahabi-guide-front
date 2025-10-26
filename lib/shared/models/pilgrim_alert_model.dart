import 'dart:convert';

class PilgrimAlertModel {
  final String id;
  final String agencyId;
  final String pilgrimId;
  final String type;
  final String status;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  PilgrimAlertModel({
    required this.id,
    required this.agencyId,
    required this.pilgrimId,
    required this.type,
    required this.status,
    required this.payload,
    required this.createdAt,
    this.resolvedAt,
  });

  PilgrimAlertModel copyWith({
    String? id,
    String? agencyId,
    String? pilgrimId,
    String? type,
    String? status,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return PilgrimAlertModel(
      id: id ?? this.id,
      agencyId: agencyId ?? this.agencyId,
      pilgrimId: pilgrimId ?? this.pilgrimId,
      type: type ?? this.type,
      status: status ?? this.status,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'agencyId': agencyId,
      'pilgrimId': pilgrimId,
      'type': type,
      'status': status,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  factory PilgrimAlertModel.fromMap(Map<String, dynamic> map) {
    return PilgrimAlertModel(
      id: map['id'] ?? '',
      agencyId: map['agencyId'] ?? '',
      pilgrimId: map['pilgrimId'] ?? '',
      type: map['type'] ?? '',
      status: map['status'] ?? '',
      payload: Map<String, dynamic>.from(map['payload'] ?? {}),
      createdAt: DateTime.parse(map['createdAt']),
      resolvedAt: map['resolvedAt'] != null 
          ? DateTime.parse(map['resolvedAt']) 
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PilgrimAlertModel.fromJson(String source) => 
      PilgrimAlertModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PilgrimAlertModel(id: $id, agencyId: $agencyId, pilgrimId: $pilgrimId, type: $type, status: $status, payload: $payload, createdAt: $createdAt, resolvedAt: $resolvedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is PilgrimAlertModel &&
      other.id == id &&
      other.agencyId == agencyId &&
      other.pilgrimId == pilgrimId &&
      other.type == type &&
      other.status == status &&
      mapEquals(other.payload, payload) &&
      other.createdAt == createdAt &&
      other.resolvedAt == resolvedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      agencyId.hashCode ^
      pilgrimId.hashCode ^
      type.hashCode ^
      status.hashCode ^
      payload.hashCode ^
      createdAt.hashCode ^
      resolvedAt.hashCode;
  }
}

bool mapEquals<T, U>(Map<T, U>? a, Map<T, U>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (final T key in a.keys) {
    if (!b.containsKey(key) || b[key] != a[key]) return false;
  }
  return true;
}