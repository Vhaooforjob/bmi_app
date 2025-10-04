import 'package:dio/dio.dart';
import 'chat_models.dart';

class ChatApi {
  final Dio dio;
  ChatApi(this.dio);

  Future<List<Conversation>> listConversations({String? userId}) async {
    final res = await dio.get(
      '/api/chat/conversations',
      queryParameters: {if (userId != null) 'userId': userId},
    );
    final data = res.data['data'] as List? ?? [];
    return data.map((e) => Conversation.fromJson(e)).toList();
  }

  Future<Conversation> createConversation({
    String? userId,
    String? title,
  }) async {
    final res = await dio.post(
      '/api/chat/conversations',
      data: {
        if (userId != null) 'userId': userId,
        if (title != null) 'title': title,
      },
    );
    return Conversation.fromJson(res.data['data']);
  }

  Future<List<ChatMessageModel>> listMessages(
    String conversationId, {
    int limit = 100,
    int skip = 0,
    String? userId,
  }) async {
    final res = await dio.get(
      '/api/chat/conversations/$conversationId/messages',
      queryParameters: {
        'limit': limit,
        'skip': skip,
        if (userId != null) 'userId': userId,
      },
    );
    final data = res.data['data'] as List? ?? [];
    return data.map((e) => ChatMessageModel.fromJson(e)).toList();
  }

  Future<String> sendMessage(
    String conversationId,
    String message, {
    String? userId,
  }) async {
    final res = await dio.post(
      '/api/chat/conversations/$conversationId/messages',
      data: {'message': message, if (userId != null) 'userId': userId},
    );
    return res.data['answer'] as String;
  }

  Future<void> renameConversation(
    String id,
    String title, {
    String? userId,
  }) async {
    await dio.put(
      '/api/chat/conversations/$id',
      data: {'title': title, if (userId != null) 'userId': userId},
    );
  }

  Future<void> deleteConversation(String id, {String? userId}) async {
    await dio.delete(
      '/api/chat/conversations/$id',
      data: {if (userId != null) 'userId': userId},
      options: Options(
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
        },
      ),
    );
  }
}
