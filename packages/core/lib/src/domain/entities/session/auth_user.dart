class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.emailVerification,
    this.photoUrl,
  });

  final String id;
  final String email;
  final String displayName;
  final bool emailVerification;
  final String? photoUrl;
}
