class User {
  final String? id;
  final String fullName;
  final String email;
  final String role;
  final String? token;

  User({
    this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role,
      'token': token,
    };
  }

  bool get isUploader => true; // All users can upload
  bool get isStudent => role.toLowerCase() == 'student';
}
