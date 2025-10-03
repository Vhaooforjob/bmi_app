import 'package:flutter/material.dart';
import '../../../core/auth/token_storage.dart';
import '../data/auth_api.dart';
import '../data/auth_tokens.dart';

class AuthController extends ChangeNotifier {
  final AuthApi api;
  final TokenStorage storage;
  bool loading = false;
  String? error;

  AuthController({required this.api, required this.storage});

  Future<bool> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final AuthTokens tk = await api.login(email, password);
      await storage.saveTokens(
        accessToken: tk.token,
        refreshToken: tk.refreshToken,
        expiresAt: tk.expiresAt,
      );
      final savedToken = await storage.getToken();
      final savedUserId = await storage.getUserId();
      print("AccessToken: $savedToken");
      print("UserId: $savedUserId");
      return true;
    } catch (e) {
      error = 'Đăng nhập thất bại';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await api.register(
        fullName: fullName,
        username: username,
        email: email,
        password: password,
      );
      return true;
    } catch (_) {
      error = 'Đăng ký thất bại';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await storage.clear();
    notifyListeners();
  }
}
