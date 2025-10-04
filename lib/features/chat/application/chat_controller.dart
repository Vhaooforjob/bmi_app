import 'package:flutter/material.dart';
import '../../../core/auth/token_storage.dart';
import '../data/chat_api.dart';
import '../data/chat_models.dart';

class ChatController extends ChangeNotifier {
  final ChatApi api;
  final TokenStorage storage;
  ChatController(this.api, this.storage);

  bool loading = false;
  bool sending = false;

  List<Conversation> conversations = [];
  String? currentId;

  List<ChatMessageModel> messages = [];
  String? error;

  Future<String?> _userId() async => await storage.getUserId();

  Future<void> initEnsureConversation() async {
    loading = true;
    notifyListeners();
    try {
      final uid = await _userId();
      conversations = await api.listConversations(userId: uid);

      final last = await storage.getLastConversationId();
      if (last != null && conversations.any((c) => c.id == last)) {
        currentId = last;
      } else if (conversations.isNotEmpty) {
        currentId = conversations.first.id;
        await storage.setLastConversationId(currentId);
      } else {
        final conv = await api.createConversation(userId: uid);
        conversations = [conv];
        currentId = conv.id;
        await storage.setLastConversationId(currentId);
      }

      await loadMessages();
    } catch (e) {
      error = 'Không tải được hội thoại';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadConversations() async {
    try {
      final uid = await _userId();
      conversations = await api.listConversations(userId: uid);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> newConversation({String? title}) async {
    loading = true;
    notifyListeners();
    try {
      final uid = await _userId();
      final conv = await api.createConversation(userId: uid, title: title);
      conversations.insert(0, conv);
      currentId = conv.id;
      await storage.setLastConversationId(currentId);
      messages = [];
      await loadMessages();
    } catch (e) {
      error = 'Tạo hội thoại thất bại';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> selectConversation(String id) async {
    if (currentId == id) return;
    currentId = id;
    await storage.setLastConversationId(currentId);
    messages = [];
    notifyListeners();
    await loadMessages();
  }

  Future<void> loadMessages() async {
    final id = currentId;
    if (id == null) return;
    try {
      final uid = await _userId();
      messages = await api.listMessages(id, userId: uid);
      // bỏ message 'system' nếu API có
      messages = messages.where((m) => m.role != 'system').toList();
      notifyListeners();
    } catch (e) {
      error = 'Không tải được tin nhắn';
      notifyListeners();
    }
  }

  /// Trả về **botText** để view render typing
  Future<String> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || currentId == null) return '';

    final now = DateTime.now();
    messages.add(
      ChatMessageModel(
        id: 'local-${now.microsecondsSinceEpoch}',
        role: 'user',
        text: trimmed,
        createdAt: now,
      ),
    );
    sending = true;
    notifyListeners();

    try {
      final uid = await _userId();
      final botText = await api.sendMessage(currentId!, trimmed, userId: uid);

      messages.add(
        ChatMessageModel(
          id: 'local-model-${DateTime.now().microsecondsSinceEpoch}',
          role: 'model',
          text: botText,
          createdAt: DateTime.now(),
        ),
      );
      await loadConversations();
      await storage.setLastConversationId(currentId);
      return botText;
    } catch (e) {
      messages.add(
        ChatMessageModel(
          id: 'local-error-${DateTime.now().microsecondsSinceEpoch}',
          role: 'system',
          text: 'Gửi thất bại, vui lòng thử lại.',
          createdAt: DateTime.now(),
        ),
      );
      return '';
    } finally {
      sending = false;
      notifyListeners();
    }
  }

  Future<void> deleteCurrent() async {
    final id = currentId;
    if (id == null) return;
    loading = true;
    notifyListeners();
    try {
      final uid = await _userId();
      await api.deleteConversation(id, userId: uid);
      conversations.removeWhere((c) => c.id == id);

      final last = await storage.getLastConversationId();
      if (last == id) await storage.setLastConversationId(null);

      currentId = conversations.isNotEmpty ? conversations.first.id : null;
      if (currentId != null) {
        await storage.setLastConversationId(currentId);
        await loadMessages();
      } else {
        messages = [];
      }
    } catch (_) {
      error = 'Xóa hội thoại thất bại';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteById(String id) async {
    try {
      final uid = await _userId();

      debugPrint('Start deleting conversation');
      debugPrint('→ conversationId: $id');
      debugPrint('→ userId: $uid');
      debugPrint('→ API endpoint: /api/chat/conversations/$id');
      debugPrint('→ Body: { "userId": "$uid" }');

      await api.deleteConversation(id, userId: uid);

      debugPrint('[DELETE Chat] Delete successful for ID: $id');

      conversations.removeWhere((c) => c.id == id);

      if (currentId == id) {
        if (conversations.isNotEmpty) {
          currentId = conversations.first.id;
          await storage.setLastConversationId(currentId);
          await loadMessages();
        } else {
          currentId = null;
          await storage.setLastConversationId(null);
          messages = [];
          notifyListeners();
        }
      } else {
        notifyListeners();
      }
      return true;
    } catch (e) {
      error = 'Xóa hội thoại thất bại';
      debugPrint('[DELETE Chat] Failed to delete conversation: $e');
      notifyListeners();
      return false;
    }
  }
}
