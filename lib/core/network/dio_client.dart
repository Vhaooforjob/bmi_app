import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../config/constants.dart';
import '../config/env.dart';
import '../auth/token_storage.dart';
import '../navigation/navigation_service.dart';

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
          // Nếu backend KHÔNG cần "Bearer " (token trần),
          // đặt Constants.bearer = '' trong Constants
          options.headers[Constants.authHeader] = '${Constants.bearer}$token';
        }
        handler.next(options);
      },
    ),
  );

  var loggingOut = false; // tránh redirect nhiều lần
  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (DioException err, handler) async {
        final status = err.response?.statusCode ?? 0;
        final data = err.response?.data;
        final msg =
            (data is Map && data['message'] is String)
                ? (data['message'] as String).toLowerCase()
                : '';

        final path = err.requestOptions.path;
        final isAuthPath =
            path.contains('/api/user/login') ||
            path.contains('/api/user/registration');

        final isAuthError =
            status == 401 ||
            status == 403 ||
            msg.contains('invalid or expired token') ||
            (msg.contains('token') && msg.contains('expired'));

        if (!isAuthPath && isAuthError && !loggingOut) {
          loggingOut = true;
          await tokenStorage.clear();

          final ctx = rootNavigatorKey.currentContext;
          if (ctx != null) {
            ctx.go('/login');
          }

          return handler.resolve(
            Response(
              requestOptions: err.requestOptions,
              statusCode: 401,
              data: {'message': 'Unauthorized - redirected to login'},
            ),
          );
        }

        handler.next(err);
      },
    ),
  );

  return dio;
}
