import 'package:flutter/material.dart';

class ViewInfoCard extends StatelessWidget {
  final DateTime? joinDate;
  final bool verified;
  final String activeStatus;
  final DateTime? birthdate;
  final String? sex;
  final String Function(DateTime) formatVn;

  const ViewInfoCard({
    super.key,
    required this.joinDate,
    required this.verified,
    required this.activeStatus,
    required this.birthdate,
    required this.sex,
    required this.formatVn,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    String? birthLabel() {
      if (birthdate == null) return null;
      final d = birthdate!;
      final dd = d.day.toString().padLeft(2, '0');
      final mm = d.month.toString().padLeft(2, '0');
      return '$dd/$mm/${d.year}';
    }

    return Card(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.event_available_outlined, color: cs.primary),
            title: const Text("Ngày tham gia"),
            subtitle:
                joinDate == null ? const Text('—') : Text(formatVn(joinDate!)),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.cake_outlined, color: cs.primary),
            title: const Text("Ngày sinh"),
            subtitle: Text(birthLabel() ?? '—'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.wc_outlined, color: cs.primary),
            title: const Text("Giới tính"),
            subtitle: Text(
              sex == null
                  ? '—'
                  : sex?.toLowerCase() == 'male'
                  ? 'Nam'
                  : sex?.toLowerCase() == 'female'
                  ? 'Nữ'
                  : 'Khác',
            ),
          ),
          // const Divider(height: 1),
          // ListTile(
          //   leading: Icon(Icons.info_outline, color: cs.primary),
          //   title: const Text("Trạng thái"),
          //   subtitle: Text(activeStatus),
          //   trailing: Chip(
          //     label: Text(
          //       activeStatus,
          //       style: TextStyle(
          //         color: cs.onPrimary,
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //     backgroundColor: cs.primary,
          //   ),
          // ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.verified_user_outlined, color: cs.primary),
            title: const Text("Xác minh"),
            subtitle: Text(verified ? "Đã xác minh" : "Chưa xác minh"),
            trailing: Icon(
              verified ? Icons.verified : Icons.verified_outlined,
              color: verified ? cs.primary : cs.outline,
            ),
          ),
        ],
      ),
    );
  }
}
