import 'package:bmi_app/app/navigation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/auth/auth_guard.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/profile/presentation/profile_page.dart';

GoRouter createRouter(AuthGuard guard) => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const AppNavigation()),
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
  ],
  redirect: guard.redirect,
  debugLogDiagnostics: false,
);
