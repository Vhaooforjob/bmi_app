import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/token_storage.dart';
import '../../../core/theme/theme_controller.dart';
import '../application/profile_controller.dart';
import '../../auth/application/auth_controller.dart'; // để dùng logout chung

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final storage = TokenStorage();
    final userId = await storage.getUserId();
    final token = await storage.getToken();
    if (userId != null && token != null && mounted) {
      // fetchUser nên return true/false để biết token hợp lệ
      final ok = await context.read<UserController>().fetchUser(userId, token);
      if (!ok && mounted) {
        await storage.clear();
        context.go('/login');
      }
    }
  }

  Future<void> _logout() async {
    // Nếu bạn có API logout thì gọi tại đây; hiện tại clear local là đủ
    await context.read<AuthController>().logout();
    if (mounted) context.go('/login');
  }

  String _formatVn(DateTime dt) {
    // Quy đổi UTC -> VN (UTC+7)
    final vn = dt.toUtc().add(const Duration(hours: 7));
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(vn.day)}/${two(vn.month)}/${vn.year} ${two(vn.hour)}:${two(vn.minute)}';
  }

  String _modeLabel(ThemeMode m) => switch (m) {
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
    _ => 'System',
  };

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<UserController>();
    final themeController = context.watch<ThemeController>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Trang cá nhân")),
      body:
          ctrl.loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (ctrl.current == null)
                      _HeaderCard.placeholder()
                    else
                      _HeaderCard(
                        name: ctrl.current!.fullName,
                        email: ctrl.current!.email,
                      ),

                    const SizedBox(height: 16),
                    if (ctrl.current != null)
                      Card(
                        color: cs.surface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: cs.outlineVariant),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(
                                Icons.badge_outlined,
                                color: cs.primary,
                              ),
                              title: const Text("Username"),
                              subtitle: Text(ctrl.current!.username),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: Icon(
                                Icons.verified_user_outlined,
                                color: cs.primary,
                              ),
                              title: const Text("Xác minh"),
                              subtitle: Text(
                                ctrl.current!.verified ? "Đã xác minh" : "Chưa",
                              ),
                              trailing: Icon(
                                ctrl.current!.verified
                                    ? Icons.verified
                                    : Icons.verified_outlined,
                                color:
                                    ctrl.current!.verified
                                        ? cs.primary
                                        : cs.outline,
                              ),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: Icon(
                                Icons.event_available_outlined,
                                color: cs.primary,
                              ),
                              title: const Text("Ngày tham gia"),
                              subtitle: Text(_formatVn(ctrl.current!.joinDate)),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      )
                    else
                      Center(child: Text(ctrl.error ?? "Không có dữ liệu")),
                    const SizedBox(height: 16),
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
                        backgroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          final selected = states.contains(
                            WidgetState.selected,
                          );
                          return selected ? cs.primary : cs.surface;
                        }),
                        foregroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          final selected = states.contains(
                            WidgetState.selected,
                          );
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
                            content: Text(
                              'Đã chuyển giao diện: ${_modeLabel(m)}',
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    const Spacer(),

                    _LogoutButton(onLogout: _logout),
                  ],
                ),
              ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String? name;
  final String? email;
  final bool isPlaceholder;

  const _HeaderCard({this.name, this.email, this.isPlaceholder = false});

  factory _HeaderCard.placeholder() => const _HeaderCard(isPlaceholder: true);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: cs.primary,
              child: const Icon(Icons.person, size: 34, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child:
                  isPlaceholder
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            width: 140,
                            decoration: BoxDecoration(
                              color: cs.outlineVariant.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 14,
                            width: 180,
                            decoration: BoxDecoration(
                              color: cs.outlineVariant.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name ?? '—',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 16,
                                color: cs.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  email ?? '—',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;
  const _LogoutButton({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.error,
          foregroundColor: cs.onError,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onLogout,
        icon: const Icon(Icons.logout),
        label: const Text("Đăng xuất"),
      ),
    );
  }
}
