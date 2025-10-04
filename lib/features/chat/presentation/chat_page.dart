import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../profile/application/profile_controller.dart';
import '../../../core/auth/token_storage.dart';
import '../application/chat_controller.dart';
import '../data/chat_models.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  Timer? _typingTimer;
  String _typingBuffer = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _ensureUserLoaded();
      await context.read<ChatController>().initEnsureConversation();
    });
  }

  Future<void> _ensureUserLoaded() async {
    final profile = context.read<UserController?>();
    if (profile == null) return;
    if (profile.current == null && !profile.loading) {
      final storage = TokenStorage();
      final uid = await storage.getUserId();
      final token = await storage.getToken();
      if (uid != null && token != null) {
        await profile.fetchUser(uid, token);
      }
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent + 160,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _simulateTyping(String full) {
    _typingTimer?.cancel();
    if (full.isEmpty) return;
    setState(() => _typingBuffer = "");
    int i = 0;
    _typingTimer = Timer.periodic(const Duration(milliseconds: 20), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (i >= full.length) {
        t.cancel();
      } else {
        setState(() => _typingBuffer += full[i]);
        i++;
      }
      _scrollToBottom();
    });
  }

  String _vnDateTime(DateTime dt) {
    final vn = dt.toUtc().add(const Duration(hours: 7));
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(vn.day)}/${two(vn.month)}/${vn.year} ${two(vn.hour)}:${two(vn.minute)}';
  }

  Future<void> _onSendTap() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    final ctrl = context.read<ChatController>();
    _textCtrl.clear();

    setState(() => _typingBuffer = "");
    await ctrl.send(text);

    final modelMsgs = ctrl.messages.where((m) => m.role == 'model');
    if (modelMsgs.isNotEmpty) {
      final lastModel = modelMsgs.last;
      _simulateTyping(lastModel.text);
    }

    _scrollToBottom();
  }

  Future<void> _confirmDeleteCurrent(ChatController ctrl) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Xóa đoạn chat?'),
            content: const Text(
              'Bạn có chắc muốn xóa đoạn chat hiện tại không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );
    if (ok == true) {
      await ctrl.deleteCurrent();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa đoạn chat')));
    }
  }

  void _openHistorySheet(ChatController ctrl) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final items = ctrl.conversations;
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text("Chưa có lịch sử")),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final it = items[i];
            return Dismissible(
              key: ValueKey(it.id),
              direction: DismissDirection.endToStart,
              background: Container(
                decoration: BoxDecoration(
                  color: cs.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.delete, color: cs.onError),
              ),
              confirmDismiss: (_) async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: const Text('Xóa đoạn chat?'),
                        content: Text(
                          'Bạn có chắc muốn xóa đoạn "${it.title}" không?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Hủy'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Xóa'),
                          ),
                        ],
                      ),
                );

                if (confirm != true) return false;

                try {
                  final ok = await ctrl.deleteById(it.id);
                  if (!context.mounted) return false;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? 'Đã xóa đoạn chat' : 'Xóa thất bại'),
                    ),
                  );
                  return ok;
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Lỗi xoá: $e')));
                  }
                  return false;
                }
              },
              child: ListTile(
                leading: const Icon(Icons.chat_outlined),
                title: Text(
                  it.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('Cập nhật: ${_vnDateTime(it.updatedAt)}'),
                onTap: () {
                  Navigator.pop(context);
                  ctrl.selectConversation(it.id);
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ChatController>();
    final cs = Theme.of(context).colorScheme;

    final user = context.watch<UserController?>()?.current;
    final userAvatarUrl = null;
    final userFullName = (user?.fullName ?? user?.email ?? 'Bạn').trim();
    final userInitial =
        userFullName.isNotEmpty
            ? userFullName.characters.first.toUpperCase()
            : 'B';

    _scrollToBottom();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat với Chuyên Gia"),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "Lịch sử chat",
            icon: const Icon(Icons.history),
            onPressed: () => _openHistorySheet(ctrl),
          ),
          IconButton(
            tooltip: "Đoạn chat mới",
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              await ctrl.newConversation();
              _simulateTyping(
                "Xin chào, tôi là chuyên gia dinh dưỡng của Green Bite. Tôi có thể giúp gì cho bạn về dinh dưỡng và lối sống lành mạnh?",
              );
            },
          ),
        ],
      ),
      body:
          ctrl.loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      itemCount:
                          ctrl.messages.length +
                          (_typingBuffer.isNotEmpty ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (_typingBuffer.isNotEmpty &&
                            i == ctrl.messages.length) {
                          return _Bubble(
                            role: 'model',
                            text: _typingBuffer,
                            userInitial: userInitial,
                            userAvatarUrl: userAvatarUrl,
                          );
                        }
                        final ChatMessageModel m = ctrl.messages[i];
                        return _Bubble(
                          role: m.role,
                          text: m.text,
                          userInitial: userInitial,
                          userAvatarUrl: userAvatarUrl,
                        );
                      },
                    ),
                  ),
                  _Composer(
                    controller: _textCtrl,
                    sending: ctrl.sending,
                    onSend: _onSendTap,
                  ),
                ],
              ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String role;
  final String text;
  final String userInitial;
  final String? userAvatarUrl;

  const _Bubble({
    required this.role,
    required this.text,
    required this.userInitial,
    required this.userAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isUser = role == "user";

    Widget userAvatar() {
      if (userAvatarUrl != null && userAvatarUrl!.startsWith('http')) {
        return CircleAvatar(backgroundImage: NetworkImage(userAvatarUrl!));
      }
      return CircleAvatar(
        backgroundColor: cs.primary,
        child: Text(userInitial, style: TextStyle(color: cs.onPrimary)),
      );
    }

    final botAvatar = const CircleAvatar(
      backgroundImage: AssetImage("assets/robot.png"),
    );

    final avatar = isUser ? userAvatar() : botAvatar;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser) avatar,
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? cs.primary : cs.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: _FormattedText(
              text,
              style: TextStyle(color: isUser ? Colors.white : cs.onSurface),
            ),
          ),
        ),
        if (isUser) ...[const SizedBox(width: 8), avatar],
      ],
    );
  }
}

class _FormattedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const _FormattedText(this.text, {this.style});

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final parts = text.split(
      RegExp(r'(\*\*.*?\*\*|\*.*?\*|```.*?```)', dotAll: true),
    );

    for (final part in parts) {
      if (part.startsWith("**") && part.endsWith("**")) {
        spans.add(
          TextSpan(
            text: part.substring(2, part.length - 2),
            style: style?.copyWith(fontWeight: FontWeight.bold),
          ),
        );
      } else if (part.startsWith("*") && part.endsWith("*")) {
        spans.add(
          TextSpan(
            text: part.substring(1, part.length - 1),
            style: style?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        );
      } else if (part.startsWith("```") && part.endsWith("```")) {
        spans.add(
          TextSpan(
            text: part.substring(3, part.length - 3),
            style: style?.copyWith(
              fontFamily: "monospace",
              backgroundColor: Colors.black12,
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: part, style: style));
      }
    }

    return RichText(text: TextSpan(children: spans));
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => sending ? null : onSend(),
              decoration: InputDecoration(
                hintText: "Nhập tin nhắn…",
                filled: true,
                isDense: true,
                fillColor: cs.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: cs.outlineVariant),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: sending ? null : onSend,
            icon:
                sending
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
