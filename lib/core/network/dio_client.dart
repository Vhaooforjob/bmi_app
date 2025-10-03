import 'package:dio/dio.dart';
import '../config/constants.dart';
import '../config/env.dart';
import '../auth/token_storage.dart';

Dio createDio(TokenStorage tokenStorage) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(milliseconds: Constants.connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: Constants.receiveTimeoutMs),
      contentType: 'application/json',
    ),
  );

  if (Env.logNetwork) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers[Constants.authHeader] = '${Constants.bearer}$token';
        }
        handler.next(options);
      },
    ),
  );

  // dio.interceptors.add(InterceptorsWrapper(
  //   onError: (err, handler) async {
  //     if (err.response?.statusCode == 401) { ... }
  //     handler.next(err);
  //   },
  // ));

  return dio;
}
