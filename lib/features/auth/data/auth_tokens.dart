class AuthTokens {
  final String token;
  final String refreshToken;
  final DateTime expiresAt;

  AuthTokens({
    required this.token,
    required this.refreshToken,
    required this.expiresAt,
  });

  static Duration _parseExpiresIn(String s) {
    final m = RegExp(r'^(\d+)([smhd])$').firstMatch(s.trim());
    if (m == null) return const Duration(minutes: 5);
    final value = int.parse(m.group(1)!);
    switch (m.group(2)) {
      case 's':
        return Duration(seconds: value);
      case 'm':
        return Duration(minutes: value);
      case 'h':
        return Duration(hours: value);
      case 'd':
        return Duration(days: value);
    }
    return const Duration(minutes: 5);
  }

  factory AuthTokens.fromLoginResponse(Map<String, dynamic> json) {
    final token = json['token'] as String? ?? '';
    final refresh = json['refreshToken'] as String? ?? '';
    final expiresIn = json['expiresIn'] as String? ?? '5m';
    final expiresAt = DateTime.now().add(_parseExpiresIn(expiresIn));
    return AuthTokens(
      token: token,
      refreshToken: refresh,
      expiresAt: expiresAt,
    );
  }
}
