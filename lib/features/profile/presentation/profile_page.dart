import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../auth/application/auth_controller.dart';
import '../../../core/theme/theme_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final themeController = context.watch<ThemeController>();

    String modeLabel(ThemeMode m) => switch (m) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      _ => 'System',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Trang cá nhân')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: cs.primary,
              child: const Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text('Xin chào!', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),

            // --- Đổi theme ---
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Giao diện',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.devices_other),
                  label: Text('System'),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text('Dark'),
                ),
              ],
              selected: {themeController.mode},
              style: ButtonStyle(
                // màu chủ đạo xanh + chữ trắng khi chọn
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return selected ? cs.primary : cs.surface;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return selected ? Colors.white : cs.onSurface;
                }),
                overlayColor: WidgetStatePropertyAll(
                  cs.primary.withOpacity(0.08),
                ),
                side: WidgetStatePropertyAll(
                  BorderSide(color: cs.outlineVariant),
                ),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              onSelectionChanged: (set) {
                final m = set.first;
                themeController.setMode(m);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã chuyển giao diện: ${modeLabel(m)}'),
                  ),
                );
              },
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await context.read<AuthController>().logout();
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Đăng xuất'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
