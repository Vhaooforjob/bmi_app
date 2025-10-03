import 'package:bmi_app/features/bmi/data/bmi_model.dart';
import 'package:dio/dio.dart';

class BmiApi {
  final Dio dio;
  BmiApi(this.dio);

  Future<List<BmiData>> getBmi(String userId) async {
    final res = await dio.get(
      '/api/kcal/',
      queryParameters: {'userId': userId},
    );
    final list = res.data as List;
    return list.map((e) => BmiData.fromJson(e)).toList();
  }

  Future<BmiData> calculateBmi(String userId, int height, int weight) async {
    final res = await dio.post(
      '/api/kcal',
      data: {'userId': userId, 'height_cm': height, 'weight_kg': weight},
    );
    final data = res.data['data'] as Map<String, dynamic>;
    return BmiData.fromJson(data);
  }

  Future<BmiData> calculateAdvanced({
    required String userId,
    required int height,
    required int weight,
    required String sex,
    required String activity,
    required List<Map<String, dynamic>> mealSplit,
  }) async {
    final res = await dio.post(
      '/api/kcal',
      data: {
        'userId': userId,
        'height_cm': height,
        'weight_kg': weight,
        'sex': sex,
        'activity': activity,
        'meal_split': mealSplit,
      },
    );
    final data = res.data['data'] as Map<String, dynamic>;
    return BmiData.fromJson(data);
  }
}
