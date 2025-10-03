import 'package:flutter/material.dart';
import '../data/bmi_model.dart';
import '../data/bmi_api.dart';

class BmiController extends ChangeNotifier {
  final BmiApi api;
  BmiController(this.api);

  bool loading = false;
  String? error;
  List<BmiData> history = [];
  BmiData? current;

  Future<void> fetchHistory(String userId) async {
    loading = true;
    notifyListeners();
    try {
      history = await api.getBmi(userId);
      if (history.isNotEmpty) current = history.last;
    } catch (e) {
      error = 'Lỗi khi tải dữ liệu';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> calculate(String userId, int h, int w) async {
    loading = true;
    notifyListeners();
    try {
      current = await api.calculateBmi(userId, h, w);
      history.add(current!);
    } catch (e) {
      error = 'Tính toán thất bại';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> calculateAdvanced({
    required String userId,
    required int height,
    required int weight,
    required String sex,
    required String activity,
    required List<Map<String, dynamic>> mealSplit,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      current = await api.calculateAdvanced(
        userId: userId,
        height: height,
        weight: weight,
        sex: sex,
        activity: activity,
        mealSplit: mealSplit,
      );
      history.add(current!);
    } catch (e) {
      error = 'Tính toán thất bại';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
