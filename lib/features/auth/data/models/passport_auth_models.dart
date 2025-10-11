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
  final String passportNo;
  final String firstName;
  final String lastName;
  final String? nationality;
  final String? phoneNumber;
  final String? email;
  final String? emergencyContact;
  final String? medicalInfo;
  final String? groupId;
  final String? guideId;

  PilgrimProfile({
    required this.passportNo,
    required this.firstName,
    required this.lastName,
    this.nationality,
    this.phoneNumber,
    this.email,
    this.emergencyContact,
    this.medicalInfo,
    this.groupId,
    this.guideId,
  });

  factory PilgrimProfile.fromJson(Map<String, dynamic> json) {
    return PilgrimProfile(
      passportNo: json['passportNo'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      nationality: json['nationality'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      emergencyContact: json['emergencyContact'],
      medicalInfo: json['medicalInfo'],
      groupId: json['groupId'],
      guideId: json['guideId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passportNo': passportNo,
      'firstName': firstName,
      'lastName': lastName,
      'nationality': nationality,
      'phoneNumber': phoneNumber,
      'email': email,
      'emergencyContact': emergencyContact,
      'medicalInfo': medicalInfo,
      'groupId': groupId,
      'guideId': guideId,
    };
  }
}

