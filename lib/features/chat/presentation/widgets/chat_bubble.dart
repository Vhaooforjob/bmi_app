import 'package:flutter/material.dart';
import 'formatted_text.dart';

class ChatBubble extends StatelessWidget {
  final String role;
  final String text;
  final String userInitial;
  final String? userAvatarUrl;

  const ChatBubble._({
    required this.role,
    required this.text,
    required this.userInitial,
    required this.userAvatarUrl,
    super.key,
  });

  factory ChatBubble.user({
    required String text,
    required String userInitial,
    String? userAvatarUrl,
  }) {
    return ChatBubble._(
      role: 'user',
      text: text,
      userInitial: userInitial,
      userAvatarUrl: userAvatarUrl,
    );
  }

  factory ChatBubble.model({
    required String text,
    required String userInitial,
    String? userAvatarUrl,
  }) {
    return ChatBubble._(
      role: 'model',
      text: text,
      userInitial: userInitial,
      userAvatarUrl: userAvatarUrl,
    );
  }

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
            child: FormattedText(
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
