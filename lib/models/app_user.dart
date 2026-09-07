class AppUser {
  final String id; // may be empty — login's response omits it, only get-me is expected to include it
  final String username;
  final String email;
  final bool verified;

  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    this.verified = false,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    // Handles both `{ user: {...} }` (login/register) and a flat user
    // object (assumed for get-me, unconfirmed — adjust if it differs).
    final map = json['user'] is Map ? Map<String, dynamic>.from(json['user'] as Map) : json;
    return AppUser(
      id: (map['_id'] ?? map['id'] ?? '').toString(),
      username: (map['username'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      verified: map['verified'] == true,
    );
  }
}
