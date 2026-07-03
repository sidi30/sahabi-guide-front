class PassportLoginRequest {
  final String passportNo;

  PassportLoginRequest({
    required this.passportNo,
  });

  Map<String, dynamic> toJson() {
    return {
      'passportNo': passportNo,
    };
  }
}

class PassportVerifyRequest {
  final String passportNo;
  final String otpCode;

  PassportVerifyRequest({
    required this.passportNo,
    required this.otpCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'passportNo': passportNo,
      'otpCode': otpCode,
    };
  }
}

class PassportValidateRequest {
  final String token;

  PassportValidateRequest({
    required this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }
}

class PassportResendRequest {
  final String passportNo;

  PassportResendRequest({
    required this.passportNo,
  });

  Map<String, dynamic> toJson() {
    return {
      'passportNo': passportNo,
    };
  }
}

class PassportAuthResponse {
  final bool success;
  final String message;
  final String? token;
  final int timestamp;

  PassportAuthResponse({
    required this.success,
    required this.message,
    this.token,
    required this.timestamp,
  });

  factory PassportAuthResponse.fromJson(Map<String, dynamic> json) {
    return PassportAuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'],
      timestamp: json['timestamp'] ?? 0,
    );
  }
}

class PilgrimProfile {
  final String? id;
  final String? passportNo;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final String? role;
  final bool? enabled;
  final String? pilgrimageType; // HAJJ ou OMRA
  final String? gender; // MALE | FEMALE | UNSPECIFIED (axe de personnalisation des rites)
  final String? madhhab; // ecole juridique (dormant)
  final String? city;
  final String? nationality;
  final String? dateOfBirth; // ISO yyyy-MM-dd
  final String? address;
  final String? emergencyPhone;

  PilgrimProfile({
    this.id,
    this.passportNo,
    this.fullName,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.role,
    this.enabled,
    this.pilgrimageType,
    this.gender,
    this.madhhab,
    this.city,
    this.nationality,
    this.dateOfBirth,
    this.address,
    this.emergencyPhone,
  });

  factory PilgrimProfile.fromJson(Map<String, dynamic> json) {
    return PilgrimProfile(
      id: json['id']?.toString(),
      passportNo: json['passportNo']?.toString(),
      fullName: json['fullName']?.toString(),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      role: json['role']?.toString(),
      enabled: json['enabled'] as bool?,
      pilgrimageType: json['pilgrimageType']?.toString(),
      gender: json['gender']?.toString(),
      madhhab: json['madhhab']?.toString(),
      city: json['city']?.toString(),
      nationality: json['nationality']?.toString(),
      dateOfBirth: json['dateOfBirth']?.toString(),
      address: json['address']?.toString(),
      emergencyPhone: json['emergencyPhone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passportNo': passportNo,
      'fullName': fullName,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'role': role,
      'enabled': enabled,
      'pilgrimageType': pilgrimageType,
      'gender': gender,
      'madhhab': madhhab,
      'city': city,
      'nationality': nationality,
      'dateOfBirth': dateOfBirth,
      'address': address,
      'emergencyPhone': emergencyPhone,
    };
  }
}

