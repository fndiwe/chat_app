import 'package:chat_app/components/circular_image.dart';
import 'package:chat_app/components/comment_bottom_sheet.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/comment.dart';
import 'package:chat_app/models/post.dart';
import 'package:chat_app/models/reply.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/pages/profile_page.dart';
import 'package:chat_app/provider/posts_provider.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/post_service.dart';
import 'package:chat_app/utils/timestamp_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';

class PostItem extends StatefulWidget {
  const PostItem({
    super.key,
    required this.authService,
    required this.post,
    required this.theme,
    required this.postService,
    this.comment,
    this.reply,
    this.shouldNavigateToProfile = true,
  });

  final AuthService authService;
  final Post post;
  final Comment? comment;
  final Reply? reply;
  final ThemeData theme;
  final PostService postService;
  final bool shouldNavigateToProfile;

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void showComments(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => CommentBottomSheet(
            authService: widget.authService,
            post: widget.post,
            theme: widget.theme,
            postService: widget.postService,
            shouldNavigateToProfile: widget.shouldNavigateToProfile,
            currentUserId: _auth.currentUser!.uid));
  }

  void showDeleteDialog() {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        content: Text(
            "Do you want to delete this ${widget.reply != null ? "reply" : widget.comment != null ? "comment" : "post"}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.reply != null
                    ? widget.postService.deleteReply(
                        widget.post.id, widget.comment!.id, widget.reply!.id)
                    : widget.comment != null
                        ? widget.postService
                            .deleteComment(widget.post.id, widget.comment!.id)
                        : {
                            widget.postService.deletePost(widget.post.id),
                            // Remove from posts list
                            context
                                .read<PostsProvider>()
                                .deletePost(widget.post.id)
                          }; // Delete either post, comment or reply as the case may be.
              },
              child: const Text("Delete")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String postDuration = TimestampUtil().calculateDuration(
        widget.comment?.timestamp ??
            widget.reply?.timestamp ??
            widget.post.timestamp);
    return FutureBuilder(
        future: widget.authService.getUser(widget.reply?.authorId ??
            widget.comment?.authorId ??
            widget.post.authorId),
        // Get the user id based on the content type
        // Reply is first, so if reply is not null that means that it's reply we want to show the content for.
        builder: (context, snapshot) {
          AppUser? user = snapshot.data;
          final WidgetStatePropertyAll<Color> onSurfaceColor =
              WidgetStatePropertyAll(widget.theme.colorScheme.onSurface);
          return user != null
              ? ListTile(
                  titleAlignment: ListTileTitleAlignment.top,
                  titleTextStyle: widget.theme.textTheme.titleMedium
                      ?.copyWith(fontSize: 16),
                  subtitleTextStyle:
                      widget.theme.textTheme.bodyMedium!.copyWith(fontSize: 15),
                  leading: GestureDetector(
                    onTap: () => widget.shouldNavigateToProfile == false
                        ? navigatorkey.currentState?.push(MaterialPageRoute(
                            builder: (context) => ProfilePage(userArg: user),
                          ))
                        : null,
                    child: CircularImage(
                      url: user.profilePhotoUrl,
                      size: 20,
                    ),
                  ), // Author image
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                                onTap: () => widget.shouldNavigateToProfile
                                    ? navigatorkey.currentState?.pushNamed(
                                        "/profile",
                                        arguments: widget.reply?.authorId ??
                                            widget.comment?.authorId ??
                                            widget.post.authorId)
                                    : null,
                                child: Text(user.fullName)),
                            Text(
                              postDuration,
                              style: widget.theme.textTheme.labelMedium!
                                  .copyWith(
                                      color: widget.theme.colorScheme.onSurface
                                          .withAlpha(200)),
                            ) // Post timestamp
                          ],
                        ),
                        if (user.id == _auth.currentUser!.uid)
                          Builder(builder: (context) {
                            return IconButton(
                                onPressed: () => showPopover(
                                    direction: PopoverDirection.top,
                                    barrierColor: Colors.transparent,
                                    context: context,
                                    bodyBuilder: (context) => Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextButton(
                                              style: ButtonStyle(
                                                  shape: WidgetStatePropertyAll(
                                                      RoundedRectangleBorder()),
                                                  foregroundColor:
                                                      WidgetStatePropertyAll(
                                                          widget
                                                              .theme
                                                              .colorScheme
                                                              .onSurface)),
                                              onPressed: () =>
                                                  showDeleteDialog(),
                                              child: Text("Delete"),
                                            ),
                                          ],
                                        ),
                                    backgroundColor: widget.theme.colorScheme
                                        .surfaceContainerHigh),
                                icon: Icon(
                                  Icons.more_horiz,
                                  size: 20,
                                ));
                          }) // Options for a post
                      ],
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Text(widget.reply?.content ??
                          widget.comment?.content ??
                          widget.post
                              .content), // Show the content of the current object: [Reply, Comment or Post]
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 60,
                        children: [
                          Expanded(
                            flex: widget.comment == null && widget.reply == null
                                ? 1
                                : 0,
                            child: StreamBuilder(
                                // For realtime like-unlike event
                                stream: widget.comment != null
                                    ? widget.postService.isCommentLiked(
                                        widget.post.id, widget.comment!.id)
                                    : widget.reply != null
                                        ? widget.postService.isReplyLiked(
                                            widget.post.id,
                                            widget.comment!.id,
                                            widget.reply!.id)
                                        : widget.postService.isPostLiked(widget
                                            .post
                                            .id), // Check if the [Reply, Comment or Post] is liked based on the requested object: See above.
                                builder: (context, snapshot) {
                                  bool liked = snapshot.data?.exists == true;
                                  return ElevatedButton.icon(
                                    style: ButtonStyle(
                                        elevation: WidgetStatePropertyAll(0),
                                        iconColor: onSurfaceColor,
                                        foregroundColor: onSurfaceColor,
                                        backgroundColor: WidgetStatePropertyAll(
                                            widget.theme.colorScheme.surface)),
                                    onPressed: () => liked
                                        ? widget.reply !=
                                                null // Check for reply first since it's the least
                                            ? widget.postService.unlikeReply(
                                                widget.post.id,
                                                widget.comment!.id,
                                                widget.reply!.id)
                                            // Unlike reply if liked
                                            : widget.comment !=
                                                    null // Check for comment secondly

                                                ? widget.postService.unlikeComment(
                                                    widget.post.id,
                                                    widget.comment!
                                                        .id) // Unlike comment if liked
                                                : widget.postService.unlikePost(
                                                    widget.post
                                                        .id) // Else unlike post
                                        : widget.reply != null
                                            ? widget.postService.likeReply(
                                                widget.post.id,
                                                widget.comment!.id,
                                                widget.reply!.id) // Like reply
                                            : widget.comment != null
                                                ? widget.postService
                                                    .likeComment(
                                                        widget.post.id,
                                                        widget.comment!
                                                            .id) // Like comment
                                                : widget.postService.likePost(
                                                    widget
                                                        .post.id), // Like post
                                    icon: Icon(liked
                                        ? Icons.thumb_up_alt_rounded
                                        : Icons
                                            .thumb_up_alt_outlined), // Liked button
                                    label: StreamBuilder(
                                        stream: widget.reply != null
                                            ? widget.postService
                                                .getReplyLikesCount(
                                                    widget.post.id,
                                                    widget.comment!.id,
                                                    widget.reply!.id)
                                            : widget.comment != null
                                                ? widget.postService
                                                    .getCommentLikesCount(
                                                        widget.post.id,
                                                        widget.comment!.id)
                                                : widget.postService
                                                    .getPostLikesCount(
                                                        widget.post.id),
                                        builder: (context, snapshot) {
                                          return Text(
                                              "${snapshot.data ?? 0}"); // Like count
                                        }),
                                  );
                                }),
                          ),
                          if (widget.comment == null && widget.reply == null)
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ButtonStyle(
                                    elevation: WidgetStatePropertyAll(0),
                                    iconColor: onSurfaceColor,
                                    foregroundColor: onSurfaceColor,
                                    backgroundColor: WidgetStatePropertyAll(
                                        widget.theme.colorScheme.surface)),
                                onPressed: () => showComments(
                                    context), // TODO Add a functionality to reply
                                label: widget.reply == null
                                    ? StreamBuilder(
                                        stream: widget.comment != null
                                            ? widget.postService
                                                .getRepliesCount(widget.post.id,
                                                    widget.comment!.id)
                                            : widget.postService
                                                .getCommentsCount(
                                                    widget.post.id),
                                        builder: (context, snapshot) {
                                          return Text("${snapshot.data ?? 0}");
                                        })
                                    : Container(),
                                icon: Icon(widget.comment != null
                                    ? Icons.reply
                                    : Icons.comment_rounded),
                              ),
                            )
                        ],
                      )
                    ],
                  ),
                )
              : Container();
        });
  }
}
