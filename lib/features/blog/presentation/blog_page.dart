import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../application/blog_controller.dart';
import '../data/blog_post.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<BlogController>().load());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _vnDate(DateTime? dt) {
    if (dt == null) return '';
    final vn = dt.toUtc().add(const Duration(hours: 7));
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(vn.day)}/${two(vn.month)}/${vn.year}';
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<BlogController>();
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kiến Thức Sống Xanh',
          style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              onChanged: ctrl.search,
              decoration: InputDecoration(
                hintText: 'Tìm bài viết, chủ đề…',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: cs.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide(color: cs.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide(color: cs.primary, width: 1.2),
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: cs.primary,
              onRefresh: ctrl.load,
              child:
                  ctrl.loading
                      ? const Center(child: CircularProgressIndicator())
                      : ctrl.items.isEmpty
                      ? ListView(
                        children: [
                          const SizedBox(height: 120),
                          Icon(
                            Icons.menu_book_outlined,
                            size: 44,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(height: 6),
                          Center(
                            child: Text(
                              'Chưa có bài viết',
                              style: t.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      )
                      : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                        itemCount: ctrl.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final p = ctrl.items[i];
                          return _CompactHeroCard(
                            post: p,
                            dateText: _vnDate(p.createdAt),
                            onTap: () => context.push('/blog/${p.id}'),
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactHeroCard extends StatefulWidget {
  final BlogPost post;
  final String dateText;
  final VoidCallback onTap;

  const _CompactHeroCard({
    required this.post,
    required this.dateText,
    required this.onTap,
  });

  @override
  State<_CompactHeroCard> createState() => _CompactHeroCardState();
}

class _CompactHeroCardState extends State<_CompactHeroCard> {
  bool _pressed = false;

  static const _imageHeight = 140.0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final hasImage = (widget.post.image ?? '').isNotEmpty;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: Card(
          elevation: 0,
          color: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: cs.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hasImage)
                SizedBox(
                  height: _imageHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.post.image!,
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
                      IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.04),
                                Colors.black.withOpacity(0.35),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 10,
                        child: Text(
                          widget.post.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: t.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            shadows: const [
                              Shadow(blurRadius: 6, color: Colors.black38),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!hasImage)
                      Text(
                        widget.post.title,
                        style: t.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
                          height: 1.15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (!hasImage) const SizedBox(height: 6),
                    Text(
                      widget.post.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodySmall?.copyWith(height: 1.3),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: cs.primary.withOpacity(0.15),
                          child: Text(
                            (widget.post.authorName ?? 'A')
                                .trim()
                                .characters
                                .first
                                .toUpperCase(),
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.post.authorName ?? '—',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.dateText,
                          style: t.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
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
      ),
    );
  }
}
