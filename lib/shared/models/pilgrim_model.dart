import 'dart:convert';

class PilgrimModel {
  final String id;
  final String agencyId;
  final String groupId;
  final String name;
  final String passportNo;
  final String photoUrl;
  final String qrCode;
  final String guideId;
  final DateTime createdAt;
  final DateTime updatedAt;

  PilgrimModel({
    required this.id,
    required this.agencyId,
    required this.groupId,
    required this.name,
    required this.passportNo,
    required this.photoUrl,
    required this.qrCode,
    required this.guideId,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => name;

  PilgrimModel copyWith({
    String? id,
    String? agencyId,
    String? groupId,
    String? name,
    String? passportNo,
    String? photoUrl,
    String? qrCode,
    String? guideId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PilgrimModel(
      id: id ?? this.id,
      agencyId: agencyId ?? this.agencyId,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      passportNo: passportNo ?? this.passportNo,
      photoUrl: photoUrl ?? this.photoUrl,
      qrCode: qrCode ?? this.qrCode,
      guideId: guideId ?? this.guideId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'agencyId': agencyId,
      'groupId': groupId,
      'name': name,
      'passportNo': passportNo,
      'photoUrl': photoUrl,
      'qrCode': qrCode,
      'guideId': guideId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PilgrimModel.fromMap(Map<String, dynamic> map) {
    return PilgrimModel(
      id: map['id'] ?? '',
      agencyId: map['agencyId'] ?? '',
      groupId: map['groupId'] ?? '',
      name: map['name'] ?? '',
      passportNo: map['passportNo'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      qrCode: map['qrCode'] ?? '',
      guideId: map['guideId'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory PilgrimModel.fromJson(String source) => 
      PilgrimModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PilgrimModel(id: $id, agencyId: $agencyId, groupId: $groupId, name: $name, passportNo: $passportNo, photoUrl: $photoUrl, qrCode: $qrCode, guideId: $guideId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is PilgrimModel &&
      other.id == id &&
      other.agencyId == agencyId &&
      other.groupId == groupId &&
      other.name == name &&
      other.passportNo == passportNo &&
      other.photoUrl == photoUrl &&
      other.qrCode == qrCode &&
      other.guideId == guideId &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      agencyId.hashCode ^
      groupId.hashCode ^
      name.hashCode ^
      passportNo.hashCode ^
      photoUrl.hashCode ^
      qrCode.hashCode ^
      guideId.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final PilgrimModel? pilgrim;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.pilgrim,
  });

  factory AuthResponse.fromMap(Map<String, dynamic> map) {
    return AuthResponse(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      token: map['token'],
      pilgrim: map['pilgrim'] != null ? PilgrimModel.fromMap(map['pilgrim']) : null,
    );
  }

  factory AuthResponse.fromJson(String source) => 
      AuthResponse.fromMap(json.decode(source));
}

class PassportLoginRequest {
  final String passportNo;

  PassportLoginRequest({required this.passportNo});

  Map<String, dynamic> toMap() {
    return {
      'passportNo': passportNo,
    };
  }

  String toJson() => json.encode(toMap());
}

class PassportVerifyRequest {
  final String passportNo;
  final String otpCode;

  PassportVerifyRequest({
    required this.passportNo,
    required this.otpCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'passportNo': passportNo,
      'otpCode': otpCode,
    };
  }

  String toJson() => json.encode(toMap());
}
