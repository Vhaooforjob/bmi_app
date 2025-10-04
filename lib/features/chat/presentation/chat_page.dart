import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../profile/application/profile_controller.dart';
import '../../../core/auth/token_storage.dart';
import '../application/chat_controller.dart';
import '../data/chat_models.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/composer.dart';

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
  String? _typingMsgId;

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
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  void _simulateTyping(String msgId, String full) {
    _typingTimer?.cancel();
    if (full.isEmpty) return;

    setState(() {
      _typingMsgId = msgId;
      _typingBuffer = "";
    });

    final iter = full.characters.iterator;
    _typingTimer = Timer.periodic(const Duration(milliseconds: 20), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (!iter.moveNext()) {
        t.cancel();
        setState(() {
          _typingBuffer = "";
          _typingMsgId = null;
        });
      } else {
        setState(() => _typingBuffer += iter.current);
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

    setState(() {
      _typingBuffer = "";
      _typingMsgId = null;
    });

    await ctrl.send(text);

    final modelMsgs = ctrl.messages.where((m) => m.role == 'model');
    if (modelMsgs.isNotEmpty) {
      final lastModel = modelMsgs.last;
      final id = _safeId(lastModel, modelMsgs.length - 1);
      _simulateTyping(id, lastModel.text);
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

                  setState(() {
                    _typingBuffer = "";
                    _typingMsgId = null;
                  });

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
                  setState(() {
                    _typingBuffer = "";
                    _typingMsgId = null;
                  });
                  ctrl.selectConversation(it.id);
                  _scrollToBottom();
                },
              ),
            );
          },
        );
      },
    );
  }

  String _safeId(ChatMessageModel m, int indexFallback) {
    try {
      final idField = (m as dynamic).id;
      if (idField is String && idField.isNotEmpty) return idField;
    } catch (_) {}
    return 'auto-$indexFallback-${m.role}-${m.text.hashCode}';
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ChatController>();
    final user = context.watch<UserController?>()?.current;
    final userAvatarUrl = null;
    final userFullName = (user?.fullName ?? user?.email ?? 'Bạn').trim();
    final userInitial =
        userFullName.isNotEmpty
            ? userFullName.characters.first.toUpperCase()
            : 'B';

    final cs = Theme.of(context).colorScheme;

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
              setState(() {
                _typingBuffer = "";
                _typingMsgId = null;
              });
              await ctrl.newConversation();
              _simulateTyping(
                'welcome-${DateTime.now().millisecondsSinceEpoch}',
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
                    child:
                        (ctrl.messages.isEmpty && _typingBuffer.isEmpty)
                            ? const Center(
                              child: Text(
                                "Hãy gửi tin nhắn để bắt đầu cuộc trò chuyện.",
                                textAlign: TextAlign.center,
                              ),
                            )
                            : ListView.builder(
                              controller: _scrollCtrl,
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                              itemCount:
                                  ctrl.messages.length +
                                  (_typingBuffer.isNotEmpty ? 1 : 0),
                              itemBuilder: (_, i) {
                                if (_typingBuffer.isNotEmpty &&
                                    i == ctrl.messages.length) {
                                  return ChatBubble.model(
                                    text: _typingBuffer,
                                    userInitial: userInitial,
                                    userAvatarUrl: userAvatarUrl,
                                  );
                                }

                                final ChatMessageModel m = ctrl.messages[i];

                                final id = _safeId(m, i);
                                if (_typingMsgId != null &&
                                    id == _typingMsgId) {
                                  return const SizedBox.shrink();
                                }

                                return m.role == 'user'
                                    ? ChatBubble.user(
                                      text: m.text,
                                      userInitial: userInitial,
                                      userAvatarUrl: userAvatarUrl,
                                    )
                                    : ChatBubble.model(
                                      text: m.text,
                                      userInitial: userInitial,
                                      userAvatarUrl: userAvatarUrl,
                                    );
                              },
                            ),
                  ),
                  Composer(
                    controller: _textCtrl,
                    sending: ctrl.sending,
                    onSend: _onSendTap,
                    fillColor: cs.surfaceContainerHighest,
                  ),
                ],
              ),
    );
  }
}
