import 'package:dio/dio.dart';
import 'auth_tokens.dart';

class AuthApi {
  final Dio dio;
  AuthApi(this.dio);

  Future<AuthTokens> login(String email, String password) async {
    final res = await dio.post(
      '/api/user/login',
      data: {'email': email, 'password': password},
      options: Options(headers: {'accept': 'application/json'}),
    );
    final data = res.data as Map<String, dynamic>;
    return AuthTokens.fromLoginResponse(data);
  }

  Future<void> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
  }) async {
    await dio.post(
      '/api/user/registration',
      data: {
        'email': email,
        'username': username,
        'password': password,
        'full_name': fullName,
      },
      options: Options(headers: {'accept': 'application/json'}),
    );
  }
}
