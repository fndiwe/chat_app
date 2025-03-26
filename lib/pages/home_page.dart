import 'package:chat_app/components/circular_image.dart';
import 'package:chat_app/components/posts_list.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/provider/profile_provider.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/posts_provider.dart';
import '../services/post_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PostService postService = PostService();

  final FirebaseAuth auth = FirebaseAuth.instance;

  final AuthService authService = AuthService();

  @override
  void initState() {
    context.read<ProfileProvider>().getCurrentUser(auth, authService);
    context.read<PostsProvider>().getPosts(postService);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color faintColor = theme.colorScheme.onSurface.withAlpha(200);
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              snap: true,
              floating: true,
              titleSpacing: 20,
              centerTitle: true,
              leading: GestureDetector(
                  onTap: () => navigatorkey.currentState?.pushNamed("/profile"),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: CircularImage(
                      url: Provider.of<ProfileProvider>(context)
                          .currentUser
                          ?.profilePhotoUrl,
                      size: 23,
                    ),
                  )),
              title: GestureDetector(
                onTap: () => navigatorkey.currentState?.pushNamed("/create"),
                child: Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: faintColor)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        "What's on your mind?",
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: faintColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              scrolledUnderElevation: 0,
              actions: [
                IconButton(
                    onPressed: () =>
                        navigatorkey.currentState?.pushNamed("/settings"),
                    icon: Icon(Icons.settings_rounded))
              ],
            ),
          ];
        },
        floatHeaderSlivers: true,
        body: Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: PostsList(postService: postService),
        )),
      ),
    );
  }
}
