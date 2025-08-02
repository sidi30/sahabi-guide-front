import 'dart:convert';

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;
  final DateTime? dateOfBirth;
  final String? phoneNumber;
  final String? address;
  final String? medicalInfo;
  final String? emergencyContact;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
    this.dateOfBirth,
    this.phoneNumber,
    this.address,
    this.medicalInfo,
    this.emergencyContact,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    String? phoneNumber,
    String? address,
    String? medicalInfo,
    String? emergencyContact,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      medicalInfo: medicalInfo ?? this.medicalInfo,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImageUrl': profileImageUrl,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'phoneNumber': phoneNumber,
      'address': address,
      'medicalInfo': medicalInfo,
      'emergencyContact': emergencyContact,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      dateOfBirth: map['dateOfBirth'] != null 
          ? DateTime.parse(map['dateOfBirth']) 
          : null,
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      medicalInfo: map['medicalInfo'],
      emergencyContact: map['emergencyContact'],
      isVerified: map['isVerified'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => 
      UserModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, firstName: $firstName, lastName: $lastName, profileImageUrl: $profileImageUrl, dateOfBirth: $dateOfBirth, phoneNumber: $phoneNumber, address: $address, medicalInfo: $medicalInfo, emergencyContact: $emergencyContact, isVerified: $isVerified, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserModel &&
      other.id == id &&
      other.email == email &&
      other.firstName == firstName &&
      other.lastName == lastName &&
      other.profileImageUrl == profileImageUrl &&
      other.dateOfBirth == dateOfBirth &&
      other.phoneNumber == phoneNumber &&
      other.address == address &&
      other.medicalInfo == medicalInfo &&
      other.emergencyContact == emergencyContact &&
      other.isVerified == isVerified &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      email.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      profileImageUrl.hashCode ^
      dateOfBirth.hashCode ^
      phoneNumber.hashCode ^
      address.hashCode ^
      medicalInfo.hashCode ^
      emergencyContact.hashCode ^
      isVerified.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
}
