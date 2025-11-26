enum UserRole { admin, user }

class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final bool isEmailVerified;
  final String? verificationCode;
  final DateTime? verificationCodeExpiry;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.isEmailVerified,
    this.verificationCode,
    this.verificationCodeExpiry,
    required this.createdAt,
    this.lastLogin,
  });

  /// Convert UserModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
      'isEmailVerified': isEmailVerified,
      'verificationCode': verificationCode,
      'verificationCodeExpiry': verificationCodeExpiry?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  /// Create UserModel from Firestore JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] == 'admin' ? UserRole.admin : UserRole.user,
      isEmailVerified: json['isEmailVerified'] ?? false,
      verificationCode: json['verificationCode'],
      verificationCodeExpiry: json['verificationCodeExpiry'] != null
          ? DateTime.parse(json['verificationCodeExpiry'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'])
          : null,
    );
  }

  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    UserRole? role,
    bool? isEmailVerified,
    String? verificationCode,
    DateTime? verificationCodeExpiry,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      verificationCode: verificationCode ?? this.verificationCode,
      verificationCodeExpiry:
          verificationCodeExpiry ?? this.verificationCodeExpiry,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
