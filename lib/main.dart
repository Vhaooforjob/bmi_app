import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_controller.dart';
import 'core/auth/token_storage.dart';
import 'core/network/dio_client.dart';
import 'core/auth/auth_guard.dart';
import 'app/app.dart';
import 'features/auth/data/auth_api.dart';
import 'features/auth/application/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeController = ThemeController();
  await themeController.load();

  final storage = TokenStorage();
  final dio = createDio(storage);
  final authApi = AuthApi(dio);
  final authController = AuthController(api: authApi, storage: storage);
  final guard = AuthGuard(storage);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeController),
        ChangeNotifierProvider.value(value: authController),
      ],
      child: App(themeController: themeController, guard: guard),
    ),
  );
}
