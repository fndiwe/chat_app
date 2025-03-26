import 'package:chat_app/components/app_progress_indicator.dart';
import 'package:chat_app/components/post_item.dart';
import 'package:chat_app/models/post.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/provider/posts_provider.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostsList extends StatefulWidget {
  const PostsList(
      {super.key,
      required this.postService,
      this.user,
      this.shouldNavigateToProfile});

  final PostService postService;
  final AppUser? user;
  final bool? shouldNavigateToProfile;

  @override
  State<PostsList> createState() => _PostsListState();
}

class _PostsListState extends State<PostsList> {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final PostsProvider postsProvider = context.watch<PostsProvider>();
    final String? error = postsProvider.error;
    final bool loading = postsProvider.loading;
    final List<Post> posts =
        widget.user == null ? postsProvider.posts : postsProvider.userPosts;

    if (error != null) {
      return Center(
        child: Text(error),
      );
    }
    if (loading && posts.isEmpty) {
      return Center(
        child: AppProgressIndicator(),
      );
    }

    if (posts.isEmpty) {
      return Center(
        child: Text("No posts yet"),
      );
    }

    return RefreshIndicator.adaptive(
      onRefresh: () => widget.user != null
          ? postsProvider.getUserPosts(widget.user!, widget.postService)
          : postsProvider.getPosts(widget.postService),
      child: ListView.separated(
        separatorBuilder: (context, index) => index < posts.length - 1
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Divider(
                  color: theme.colorScheme.surfaceContainerHighest,
                  thickness: 1,
                  height: 20,
                ),
              )
            : Container(),
        itemCount: posts.length,
        itemBuilder: (
          context,
          index,
        ) {
          final post = posts[index];
          return PostItem(
              authService: authService,
              post: post,
              theme: theme,
              postService: widget.postService);
        },
      ),
    );
  }
}
