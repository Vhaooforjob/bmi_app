import 'package:flutter/material.dart';

class HeaderCard extends StatelessWidget {
  final String? name;
  final String? email;
  final bool isPlaceholder;

  const HeaderCard({
    super.key,
    this.name,
    this.email,
    this.isPlaceholder = false,
  });

  const HeaderCard.placeholder({super.key})
    : name = null,
      email = null,
      isPlaceholder = true;

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
