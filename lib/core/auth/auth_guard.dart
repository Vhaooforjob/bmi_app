import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'token_storage.dart';

class AuthGuard {
  final TokenStorage storage;
  AuthGuard(this.storage);

  Future<String?> redirect(BuildContext context, GoRouterState state) async {
    final token = await storage.getToken();
    final loggingIn =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';
    if (token == null && !loggingIn) return '/login';
    if (token != null && loggingIn) return '/';
    return null;
  }
}
