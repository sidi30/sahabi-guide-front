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
    };
  }
}

