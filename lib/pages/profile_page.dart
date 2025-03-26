import 'package:chat_app/components/app_progress_indicator.dart';
import 'package:chat_app/components/circular_image.dart';
import 'package:chat_app/components/posts_list.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/provider/profile_provider.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/follow_service.dart';
import 'package:chat_app/services/post_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/posts_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.userArg});
  final AppUser? userArg;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ScrollController _scrollController = ScrollController();
  final PostService postService = PostService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    context.read<ProfileProvider>().getCurrentUser(_auth, _authService);
    getPosts();
    super.initState();
  }

  void getPosts() {
    final AppUser? currentUser = context.read<ProfileProvider>().currentUser;
    final AppUser? user = widget.userArg ?? currentUser;
    context.read<PostsProvider>().getUserPosts(user!, postService);
  }

  void signOut(BuildContext context) {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () async {
                final authService = AuthService();
                await authService.signOut();
                if (context.mounted) Navigator.pop(context);
              },
              style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.error)),
              child: const Text("Continue"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppUser? userArg = widget.userArg;
    final ThemeData theme = Theme.of(context);
    final ProfileProvider profileProvider = context.watch<ProfileProvider>();
    final String? error = profileProvider.error;
    final bool loading = profileProvider.loading;
    final AppUser? currentUser = profileProvider.currentUser;
    final AppUser? user = userArg ?? currentUser;

    final rowTextStyle = theme.textTheme.titleSmall!.copyWith(
        color: theme.colorScheme.onSurface.withAlpha(220),
        fontWeight: FontWeight.w500);

    return Scaffold(
        body: userArg == null && error != null
            ? Center(
                child: Text(error.toString()),
              )
            : userArg == null && currentUser == null && loading
                ? const Center(
                    child: AppProgressIndicator(),
                  )
                : user == null
                    ? Center(
                        child: const Text("Invalid User"),
                      )
                    : NestedScrollView(
                        controller: _scrollController,
                        headerSliverBuilder: (context, innerBoxIsScrolled) {
                          return [
                            SliverAppBar(
                              automaticallyImplyLeading: true,
                              scrolledUnderElevation: 0,
                              actions: [
                                if (user.id == _auth.currentUser!.uid)
                                  IconButton(
                                      onPressed: () => signOut(context),
                                      icon: Icon(Icons.logout_rounded))
                              ],
                              backgroundColor: theme.colorScheme.surface,
                              title: const Text(
                                "Profile",
                              ),
                              pinned: false,
                              floating: true,
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 16, left: 16, right: 16),
                                child: ProfileTopSection(
                                  theme: theme,
                                  user: user,
                                  rowTextStyle: rowTextStyle,
                                  postService: postService,
                                  auth: _auth,
                                ),
                              ),
                            ),
                            SliverAppBar(
                              automaticallyImplyLeading: false,
                              scrolledUnderElevation: 0,
                              backgroundColor: theme.colorScheme.surface,
                              title: const Text("Posts"),
                              pinned: true,
                            )
                          ];
                        },
                        body: PostsList(
                          shouldNavigateToProfile: false,
                          postService: postService,
                          user: user,
                        ),
                      ));
  }
}

class ProfileTopSection extends StatelessWidget {
  ProfileTopSection(
      {super.key,
      required this.theme,
      required this.user,
      required this.rowTextStyle,
      required this.postService,
      required this.auth});

  final ThemeData theme;
  final AppUser user;
  final TextStyle rowTextStyle;
  final PostService postService;
  final FirebaseAuth auth;

  final FollowService _followService = FollowService();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16,
      children: [
        CircularImage(url: user.profilePhotoUrl),
        Column(
          spacing: 20,
          children: [
            Column(
              children: [
                Text(
                  user.fullName,
                  style: theme.textTheme.titleLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  user.email,
                  style: theme.textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withAlpha(200)),
                ),
              ],
            ),
            Text(
              user.bio ?? "",
              style: theme.textTheme.bodyMedium!.copyWith(
                  fontSize: 15,
                  color: theme.colorScheme.onSurface.withAlpha(230)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder(
                      stream: _followService.getFollowersCount(user.id),
                      builder: (context, snapshot) {
                        return Column(
                          children: [
                            Text(
                              "${snapshot.data ?? 0}",
                            ),
                            Text(
                              snapshot.data == 1 ? "Follower" : "Followers",
                              style: rowTextStyle,
                            ),
                          ],
                        );
                      }),
                  DotSeperator(),
                  StreamBuilder(
                      stream: _followService.getFollowingCount(user.id),
                      builder: (context, snapshot) {
                        return Column(
                          children: [
                            Text("${snapshot.data ?? 0}"),
                            Text(
                              "Following",
                              style: rowTextStyle,
                            ),
                          ],
                        );
                      }),
                  DotSeperator(),
                  StreamBuilder(
                      stream: postService.getPostsCount(user.id),
                      builder: (context, snapshot) {
                        return Column(
                          children: [
                            Text((snapshot.data ?? 0).toString()),
                            Text(
                              snapshot.data == 1 ? "Post" : "Posts",
                              style: rowTextStyle,
                            ),
                          ],
                        );
                      }),
                ],
              ),
            ),
            user.id != auth.currentUser?.uid
                ? StreamBuilder(
                    stream: _followService.isFollowing(user.id),
                    builder: (context, snapshot) {
                      final bool isFollowing =
                          snapshot.hasData && snapshot.data!.exists;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 20,
                        children: [
                          Expanded(
                              child: FilledButton.icon(
                            onPressed: () => isFollowing
                                ? _followService.unfollowUser(user.id)
                                : _followService.followUser(user.id),
                            label: Text(isFollowing ? "Unfollow" : "Follow"),
                            icon: const Icon(Icons.rss_feed_rounded),
                          )),
                          if (isFollowing)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => navigatorkey.currentState
                                    ?.pushNamed("/chat", arguments: user),
                                label: const Text("Message"),
                                icon: const Icon(Icons.message_rounded),
                              ),
                            )
                        ],
                      );
                    })
                : OutlinedButton.icon(
                    onPressed: () => navigatorkey.currentState
                        ?.pushNamed("/edit_profile", arguments: user),
                    label: const Text("Edit profile"),
                    icon: const Icon(Icons.edit),
                    style: ButtonStyle(
                      minimumSize:
                          WidgetStatePropertyAll(Size(double.infinity, 45)),
                    ))
          ],
        ),
      ],
    );
  }
}

class DotSeperator extends StatelessWidget {
  const DotSeperator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 15,
      width: 1,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100), color: Colors.white54),
    );
  }
}
