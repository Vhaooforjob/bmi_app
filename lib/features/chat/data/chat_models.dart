class Conversation {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> j) => Conversation(
    id: j['_id'],
    title: j['title'] ?? 'Tư vấn sức khỏe',
    createdAt: DateTime.parse(j['createdAt']),
    updatedAt: DateTime.parse(j['updatedAt']),
  );
}

class ChatMessageModel {
  final String id;
  final String role;
  final String text;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> j) => ChatMessageModel(
    id: j['_id'],
    role: j['role'],
    text: j['text'],
    createdAt: DateTime.parse(j['createdAt']),
  );
}
