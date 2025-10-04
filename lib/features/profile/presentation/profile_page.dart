import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/token_storage.dart';
import '../../../core/theme/theme_controller.dart';
import '../../auth/application/auth_controller.dart';
import '../application/profile_controller.dart';

import 'widgets/header_card.dart';
import 'widgets/view_info_card.dart';
import 'widgets/edit_form_card.dart';
import 'widgets/logout_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  DateTime? _birthdate;
  String _sex = 'Male';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final storage = TokenStorage();
    final userId = await storage.getUserId();
    final token = await storage.getToken();
    if (userId != null && token != null && mounted) {
      final ok = await context.read<UserController>().fetchUser(userId, token);
      if (!ok && mounted) {
        await storage.clear();
        context.go('/login');
        return;
      }
      _fillFormFromCurrent();
    }
  }

  void _fillFormFromCurrent() {
    final u = context.read<UserController>().current;
    if (u != null) {
      _nameCtrl.text = u.fullName;
      _emailCtrl.text = u.email;
      _usernameCtrl.text = u.username;
      _birthdate = u.birthdate;
      _sex = u.sex ?? 'Male';
      setState(() {});
    }
  }

  Future<void> _save() async {
    final storage = TokenStorage();
    final userId = await storage.getUserId();
    final token = await storage.getToken();
    if (userId == null || token == null) return;

    final ok = await context.read<UserController>().updateUser(
      userId: userId,
      token: token,
      username: _usernameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      fullName: _nameCtrl.text.trim(),
      birthdate: _birthdate,
      sex: _sex,
    );

    if (!mounted) return;

    if (!ok) {
      final err = context.read<UserController>().error;
      if (err == "Token hết hạn hoặc không hợp lệ") {
        await storage.clear();
        context.go('/login');
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(err ?? "Cập nhật thất bại")));
    } else {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cập nhật thành công')));
    }
  }

  Future<void> _logout() async {
    await context.read<AuthController>().logout();
    if (mounted) context.go('/login');
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = _birthdate ?? DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Chọn ngày sinh',
    );
    if (picked != null) setState(() => _birthdate = picked);
  }

  String _formatVn(DateTime dt) {
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
    final t = Theme.of(context).textTheme;
    final user = ctrl.current;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Trang cá nhân"),
        actions: [
          if (!_isEditing)
            IconButton(
              tooltip: _isEditing ? 'Hủy' : 'Sửa',
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              onPressed: () {
                if (_isEditing) {
                  _fillFormFromCurrent();
                  setState(() => _isEditing = false);
                } else {
                  setState(() => _isEditing = true);
                }
              },
            ),
        ],
      ),

      body:
          ctrl.loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (user == null)
                              const HeaderCard.placeholder()
                            else
                              HeaderCard(
                                name: user.fullName,
                                email: user.email,
                              ),

                            const SizedBox(height: 16),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              child:
                                  _isEditing
                                      ? EditFormCard(
                                        key: const ValueKey('edit'),
                                        nameCtrl: _nameCtrl,
                                        usernameCtrl: _usernameCtrl,
                                        emailCtrl: _emailCtrl,
                                        birthdate: _birthdate,
                                        sex: _sex,
                                        onPickBirthdate: _pickBirthDate,
                                        onSexChanged:
                                            (v) => setState(() => _sex = v),
                                        onSave: ctrl.saving ? null : _save,
                                        onCancel: () {
                                          _fillFormFromCurrent();
                                          setState(() => _isEditing = false);
                                        },
                                        saving: ctrl.saving,
                                      )
                                      : ViewInfoCard(
                                        key: const ValueKey('view'),
                                        joinDate: user?.joinDate,
                                        verified: user?.verified ?? false,
                                        activeStatus: user?.activeStatus ?? '',
                                        birthdate: user?.birthdate,
                                        sex: user?.sex,
                                        formatVn: _formatVn,
                                      ),
                            ),

                            // const SizedBox(height: 16),

                            // Align(
                            //   alignment: Alignment.centerLeft,
                            //   child: Text('Giao diện', style: t.titleMedium),
                            // ),
                            // const SizedBox(height: 8),
                            // SegmentedButton<ThemeMode>(
                            //   segments: const [
                            //     ButtonSegment(
                            //       value: ThemeMode.system,
                            //       icon: Icon(Icons.devices_other),
                            //       label: Text('Hệ thống'),
                            //     ),
                            //     ButtonSegment(
                            //       value: ThemeMode.light,
                            //       icon: Icon(Icons.light_mode_outlined),
                            //       label: Text('Sáng'),
                            //     ),
                            //     ButtonSegment(
                            //       value: ThemeMode.dark,
                            //       icon: Icon(Icons.dark_mode_outlined),
                            //       label: Text('Tối'),
                            //     ),
                            //   ],
                            //   selected: {themeController.mode},
                            //   style: ButtonStyle(
                            //     backgroundColor:
                            //         WidgetStateProperty.resolveWith(
                            //           (states) =>
                            //               states.contains(WidgetState.selected)
                            //                   ? cs.primary
                            //                   : cs.surface,
                            //         ),
                            //     foregroundColor:
                            //         WidgetStateProperty.resolveWith(
                            //           (states) =>
                            //               states.contains(WidgetState.selected)
                            //                   ? Colors.white
                            //                   : cs.onSurface,
                            //         ),
                            //     side: WidgetStatePropertyAll(
                            //       BorderSide(color: cs.outlineVariant),
                            //     ),
                            //   ),
                            //   onSelectionChanged: (set) {
                            //     final m = set.first;
                            //     themeController.setMode(m);
                            //     ScaffoldMessenger.of(context).showSnackBar(
                            //       SnackBar(
                            //         content: Text(
                            //           'Đã chuyển giao diện: ${_modeLabel(m)}',
                            //         ),
                            //       ),
                            //     );
                            //   },
                            // ),
                            const SizedBox(height: 24),
                            LogoutButton(onLogout: _logout),

                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
