import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_controller.dart';
import 'core/auth/token_storage.dart';
import 'core/network/dio_client.dart';
import 'core/auth/auth_guard.dart';
import 'app/app.dart';

import 'features/auth/data/auth_api.dart';
import 'features/auth/application/auth_controller.dart';
import 'package:bmi_app/features/bmi/data/bmi_api.dart';
import 'features/bmi/application/bmi_controller.dart';
import 'package:bmi_app/features/profile/data/profile_api.dart';
import 'features/profile/application/profile_controller.dart';
import 'features/blog/data/blog_api.dart';
import 'features/blog/application/blog_controller.dart';
import 'features/chat/data/chat_api.dart';
import 'features/chat/application/chat_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeController = ThemeController();
  await themeController.load();

  final storage = TokenStorage();
  final dio = createDio(storage);
  final authApi = AuthApi(dio);
  final authController = AuthController(api: authApi, storage: storage);
  final guard = AuthGuard(storage);

  final bmiApi = BmiApi(dio);
  final bmiController = BmiController(bmiApi);

  final profileApi = UserApi(dio);
  final profileController = UserController(profileApi);

  final blogApi = BlogApi(dio);
  final blogController = BlogController(blogApi);

  final chatApi = ChatApi(dio);
  final chatController = ChatController(chatApi, storage);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeController),
        ChangeNotifierProvider.value(value: authController),
        ChangeNotifierProvider.value(value: bmiController),
        ChangeNotifierProvider.value(value: profileController),
        ChangeNotifierProvider.value(value: blogController),
        ChangeNotifierProvider.value(value: chatController),
      ],
      child: App(themeController: themeController, guard: guard),
    ),
  );
}
