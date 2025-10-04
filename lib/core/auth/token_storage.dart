import 'package:bmi_app/core/auth/jwt_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _kAccess = 'auth_token';
  static const _kRefresh = 'refresh_token';
  static const _kExpiresAt = 'expires_at_ms';
  static const _kUserId = 'user_id';
  static const _kLastConvId = 'last_conversation_id';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kAccess, accessToken);
    await p.setString(_kRefresh, refreshToken);
    await p.setInt(_kExpiresAt, expiresAt.millisecondsSinceEpoch);

    final userId = JwtUtils.getUserId(accessToken);
    if (userId != null) {
      await p.setString(_kUserId, userId);
      print("Saved userId: $userId");
    }
  }

  Future<String?> getToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kAccess);
  }

  Future<String?> getRefreshToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kRefresh);
  }

  Future<DateTime?> getExpiresAt() async {
    final p = await SharedPreferences.getInstance();
    final ms = p.getInt(_kExpiresAt);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<String?> getUserId() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kUserId);
  }

  Future<void> setLastConversationId(String? id) async {
    final sp = await SharedPreferences.getInstance();
    if (id == null || id.isEmpty) {
      await sp.remove(_kLastConvId);
    } else {
      await sp.setString(_kLastConvId, id);
    }
  }

  Future<String?> getLastConversationId() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kLastConvId);
  }

  Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kAccess);
    await p.remove(_kRefresh);
    await p.remove(_kExpiresAt);
    await p.remove(_kUserId);
    await p.remove(_kLastConvId);
  }
}
