import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../data/profile_model.dart';
import '../data/profile_api.dart';

class UserController extends ChangeNotifier {
  final UserApi api;
  UserController(this.api);

  bool loading = false;
  bool saving = false;
  String? error;
  UserData? current;

  Future<bool> fetchUser(String userId, String token) async {
    loading = true;
    notifyListeners();
    try {
      current = await api.getUser(userId, token);
      error = null;
      return true;
    } catch (e) {
      error = "Token hết hạn hoặc không hợp lệ";
      current = null;
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser({
    required String userId,
    required String token,
    required String username,
    required String email,
    required String fullName,
    DateTime? birthdate,
    required String sex,
  }) async {
    saving = true;
    notifyListeners();
    try {
      final body = {
        'username': username.trim(),
        'email': email.trim(),
        'full_name': fullName.trim(),
        if (birthdate != null) 'birthdate': birthdate.toUtc().toIso8601String(),
        'sex': sex,
      };
      final updated = await api.updateUser(
        userId: userId,
        token: token,
        body: body,
      );
      current = updated;
      error = null;
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        error = "Token hết hạn hoặc không hợp lệ";
      } else {
        error = "Cập nhật thất bại";
      }
      return false;
    } catch (_) {
      error = "Cập nhật thất bại";
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }
}
