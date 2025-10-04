import 'package:flutter/material.dart';

class EditFormCard extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController usernameCtrl;
  final TextEditingController emailCtrl;
  final DateTime? birthdate;
  final String sex;

  final VoidCallback? onSave;
  final VoidCallback onCancel;
  final VoidCallback onPickBirthdate;
  final ValueChanged<String> onSexChanged;
  final bool saving;

  const EditFormCard({
    super.key,
    required this.nameCtrl,
    required this.usernameCtrl,
    required this.emailCtrl,
    required this.birthdate,
    required this.sex,
    required this.onPickBirthdate,
    required this.onSexChanged,
    required this.onSave,
    required this.onCancel,
    required this.saving,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    InputDecoration _dec(String label, IconData icon) => InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );

    return Card(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: _dec('Họ tên', Icons.person_outline),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: usernameCtrl,
              decoration: _dec('Username', Icons.badge_outlined),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: _dec('Email', Icons.email_outlined),
            ),
            const SizedBox(height: 12),

            InkWell(
              onTap: onPickBirthdate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: _dec('Ngày sinh', Icons.cake_outlined),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    birthdate == null
                        ? 'Chưa đặt'
                        : '${birthdate!.day.toString().padLeft(2, '0')}/${birthdate!.month.toString().padLeft(2, '0')}/${birthdate!.year}',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: sex,
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Nam')),
                DropdownMenuItem(value: 'Female', child: Text('Nữ')),
                DropdownMenuItem(value: 'Other', child: Text('Khác')),
              ],
              onChanged: (v) {
                if (v != null) onSexChanged(v);
              },
              decoration: _dec('Giới tính', Icons.wc_outlined),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: saving ? null : onCancel,
                    icon: const Icon(Icons.close),
                    label: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: saving ? null : onSave,
                    icon:
                        saving
                            ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(Icons.save_outlined),
                    label: Text(saving ? 'Đang lưu...' : 'Lưu'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
