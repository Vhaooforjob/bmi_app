import 'package:dio/dio.dart';
import './profile_model.dart';

class UserApi {
  final Dio dio;
  UserApi(this.dio);

  Future<UserData> getUser(String userId, String token) async {
    final res = await dio.get(
      '/api/user/user/$userId',
      options: Options(
        headers: {'accept': 'application/json', 'Authorization': token},
      ),
    );
    return UserData.fromJson(res.data);
  }

  Future<UserData> updateUser({
    required String userId,
    required String token,
    required Map<String, dynamic> body,
  }) async {
    final res = await dio.put(
      '/api/user/$userId',
      data: body,
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      ),
    );
    return UserData.fromJson(res.data);
  }
}
