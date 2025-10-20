import 'dart:convert';

/// Modèle pour un lien de partage de localisation
class SharingLinkModel {
  final String id;
  final String userId;
  final String shareToken;
  final String shareUrl;
  final DateTime expiresAt;
  final bool isActive;
  final String? familyMemberName;
  final String? description;
  final DateTime createdAt;
  final int daysUntilExpiration;
  final bool expired;

  SharingLinkModel({
    required this.id,
    required this.userId,
    required this.shareToken,
    required this.shareUrl,
    required this.expiresAt,
    required this.isActive,
    this.familyMemberName,
    this.description,
    required this.createdAt,
    required this.daysUntilExpiration,
    required this.expired,
  });

  factory SharingLinkModel.fromMap(Map<String, dynamic> map) {
    return SharingLinkModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      shareToken: map['shareToken'] ?? '',
      shareUrl: map['shareUrl'] ?? '',
      expiresAt: DateTime.parse(map['expiresAt']),
      isActive: map['isActive'] ?? false,
      familyMemberName: map['familyMemberName'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      daysUntilExpiration: map['daysUntilExpiration'] ?? 0,
      expired: map['expired'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'shareToken': shareToken,
      'shareUrl': shareUrl,
      'expiresAt': expiresAt.toIso8601String(),
      'isActive': isActive,
      if (familyMemberName != null) 'familyMemberName': familyMemberName,
      if (description != null) 'description': description,
      'createdAt': createdAt.toIso8601String(),
      'daysUntilExpiration': daysUntilExpiration,
      'expired': expired,
    };
  }

  String toJson() => json.encode(toMap());

  factory SharingLinkModel.fromJson(String source) =>
      SharingLinkModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SharingLinkModel(id: $id, shareUrl: $shareUrl, expiresAt: $expiresAt, isActive: $isActive)';
  }
}


