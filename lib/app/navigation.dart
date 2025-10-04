import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../features/bmi/presentation/bmi_home_page.dart';
import '../features/blog/presentation/blog_page.dart';
import '../features/chat/presentation/chat_page.dart';
import '../features/profile/presentation/profile_page.dart';
import 'widgets/glass_nav_bar.dart';

class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int index = 0;

  final pages = const [BmiHomePage(), BlogPage(), ChatPage(), ProfilePage()];

  bool get _shouldUseGlass {
    if (kIsWeb) return false;
    try {
      return !Platform.isAndroid;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: GlassBottomNavBar(
            currentIndex: index,
            onTap: (i) => setState(() => index = i),
            useGlass: _shouldUseGlass,
            items: const [
              NavItem(icon: Icons.monitor_weight_outlined, label: 'BMI'),
              NavItem(icon: Icons.article_outlined, label: 'Bài viết'),
              NavItem(icon: Icons.chat_bubble_outline, label: 'Chat'),
              NavItem(icon: Icons.settings_outlined, label: 'Cá nhân'),
            ],
          ),
        ),
      ),
    );
  }
}
