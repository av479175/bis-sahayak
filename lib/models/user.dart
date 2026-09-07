class AppUser {
  final String id;
  final String name;
  final String email;
  final bool isVerified;

  const AppUser({required this.id, required this.name, required this.email, required this.isVerified});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? json['fullName'] ?? json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      isVerified: json['isVerified'] == true || json['emailVerified'] == true || json['isEmailVerified'] == true,
    );
  }
}
