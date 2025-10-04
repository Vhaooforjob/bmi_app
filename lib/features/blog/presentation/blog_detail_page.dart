import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application/blog_controller.dart';
import '../data/blog_post.dart';

class BlogDetailPage extends StatefulWidget {
  final String id;
  const BlogDetailPage({super.key, required this.id});

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  BlogPost? post;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final api = context.read<BlogController>().api;
      post = await api.detail(widget.id);
    } catch (e) {
      error = 'Không tải được bài viết';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String _vnDate(DateTime? dt) {
    if (dt == null) return '';
    final vn = dt.toUtc().add(const Duration(hours: 7));
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(vn.day)}/${two(vn.month)}/${vn.year}';
  }

  String _formatDescription(String text) {
    final withBreaks = text.replaceAllMapped(
      RegExp(r'([\.!\?…])\s*'),
      (m) => '${m[1]}\n',
    );
    return withBreaks.replaceAll(RegExp(r'\n{2,}'), '\n');
  }

  Widget _buildFormattedBody(BuildContext context, String text) {
    final t = Theme.of(context).textTheme;
    final paras = _formatDescription(text).split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          paras.map((raw) {
            final p = raw.trim();
            if (p.isEmpty) {
              return const SizedBox(height: 8);
            }
            const indent = '    ';
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '$indent$p',
                style: t.bodyLarge?.copyWith(height: 1.6),
                textAlign: TextAlign.justify,
              ),
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text(error!))
              : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((post!.image ?? '').isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            post!.image!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Container(
                                  color: cs.surfaceContainerHighest,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.image_not_supported_outlined,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      post!.title,
                      style: t.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if ((post!.authorName ?? '').isNotEmpty) ...[
                          Icon(
                            Icons.person,
                            size: 16,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              post!.authorName!,
                              style: t.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Icon(Icons.event, size: 16, color: cs.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          _vnDate(post!.createdAt),
                          style: t.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    _buildFormattedBody(context, post!.description),
                  ],
                ),
              ),
    );
  }
}
