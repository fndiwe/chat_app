import 'package:chat_app/models/message.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.isUserMessage,
    required this.theme,
    required this.message,
  });

  final bool isUserMessage;
  final ThemeData theme;
  final Message message;

  @override
  Widget build(BuildContext context) {
    final DateTime date = message.timestamp.toDate();
    final int hour = date.hour;
    final int minute = date.minute;
    return Row(
      mainAxisAlignment:
          isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(
                right: isUserMessage ? 16 : 46,
                top: 2,
                bottom: 2,
                left: isUserMessage ? 46 : 16),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: isUserMessage
                      ? theme.colorScheme.inversePrimary
                      : theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 12,
                children: [
                  Text(message.text, style: theme.textTheme.bodyLarge),
                  Text(
                    "${(hour % 12) == 0 ? 12 : hour % 12}:${minute.toString().padLeft(2, "0")} ${hour >= 12 ? "PM" : "AM"}",
                    style: theme.textTheme.bodySmall!.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(200)),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
