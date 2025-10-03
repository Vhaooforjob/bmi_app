import 'package:flutter/material.dart';
import '../data/profile_model.dart';
import '../data/profile_api.dart';

class UserController extends ChangeNotifier {
  final UserApi api;
  UserController(this.api);

  bool loading = false;
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
}
