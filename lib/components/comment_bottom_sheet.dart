import 'package:flutter/material.dart';

import '../models/comment.dart';
import '../models/post.dart';
import '../models/reply.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import 'app_progress_indicator.dart';
import 'circular_image.dart';
import 'message_text_field.dart';
import 'post_item.dart';
import 'rotated_send_button.dart';

class CommentBottomSheet extends StatefulWidget {
  const CommentBottomSheet(
      {super.key,
      required this.authService,
      required this.post,
      this.comment,
      this.reply,
      required this.theme,
      required this.postService,
      required this.shouldNavigateToProfile,
      required this.currentUserId});

  final AuthService authService;
  final Post post;
  final Comment? comment;
  final Reply? reply;
  final ThemeData theme;
  final PostService postService;
  final bool shouldNavigateToProfile;
  final String currentUserId;

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _textEditingController = TextEditingController();

  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      showDragHandle: true,
      enableDrag: true,
      backgroundColor: widget.theme.colorScheme.surface,
      onClosing: () {},
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Comments",
                style: widget.theme.textTheme.titleMedium,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: StreamBuilder(
                  stream: widget.postService.getComments(widget.post.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: const AppProgressIndicator(),
                      );
                    }
                    if (snapshot.data == null ||
                        snapshot.data?.isEmpty == true) {
                      return Center(
                        child: Text("No comments to show."),
                      );
                    }
                    return SizedBox(
                      height: _focusNode.hasFocus ? 0 : 400,
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          Comment comment = snapshot.data![index];
                          return PostItem(
                              authService: widget.authService,
                              post: widget.post,
                              comment: comment,
                              theme: widget.theme,
                              postService: widget.postService);
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  spacing: 8,
                  children: [
                    FutureBuilder(
                      future: widget.authService.getUser(widget.currentUserId),
                      builder: (context, snapshot) {
                        return CircularImage(
                          url: snapshot.data?.profilePhotoUrl,
                          size: 20,
                        );
                      },
                    ),
                    MessageTextField(
                      messageTextController: _textEditingController,
                      focusNode: _focusNode,
                      hintText: "Write a comment...",
                    ),
                    IconButton(
                        onPressed: () {
                          if (_textEditingController.text.isNotEmpty) {
                            widget.postService.sendComment(
                                widget.post.id, _textEditingController.text);
                            _textEditingController.clear();
                            _focusNode.unfocus();
                          }
                        },
                        icon: const RotatedSendButton())
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
