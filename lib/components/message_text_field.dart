import 'package:flutter/material.dart';

class MessageTextField extends StatelessWidget {
  const MessageTextField({
    super.key,
    required this.messageTextController, required this.focusNode, this.hintText,
  });

  final TextEditingController messageTextController;
  final FocusNode focusNode;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        constraints: BoxConstraints(maxHeight: 200),
        child: TextField(
          controller: messageTextController,
          focusNode: focusNode,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.unspecified,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: InputDecoration(
              hintText: hintText ?? "Type something...",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50))),
        ),
      ),
    );
  }
}
