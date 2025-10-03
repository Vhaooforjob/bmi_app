import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';
import 'router.dart';
import '../core/auth/auth_guard.dart';

class App extends StatelessWidget {
  final ThemeController themeController;
  final AuthGuard guard;
  const App({super.key, required this.themeController, required this.guard});

  @override
  Widget build(BuildContext context) {
    final router = createRouter(guard);
    return AnimatedBuilder(
      animation: themeController,
      builder:
          (_, __) => MaterialApp.router(
            title: 'BMI App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeController.mode,
            routerConfig: router,
          ),
    );
  }
}
