import 'package:chat_app/components/app_progress_indicator.dart';
import 'package:chat_app/components/circular_image.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/users_provider.dart';
import '../services/chat_service.dart';
import '../services/follow_service.dart';
import '/models/user.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final _auth = FirebaseAuth.instance;

  final _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    context.read<UsersProvider>().getUsers(_chatService);
  }

  @override
  Widget build(BuildContext context) {
    final UsersProvider usersProvider = context.watch<UsersProvider>();
    return Scaffold(
        appBar: AppBar(
          title: const Text("Find people"),
        ),
        body: RefreshIndicator.adaptive(
            onRefresh: () => usersProvider.getUsers(_chatService),
            child: UserListView(auth: _auth, usersProvider: usersProvider)));
  }
}

class UserListView extends StatelessWidget {
  UserListView({
    super.key,
    required this.auth,
    required this.usersProvider,
  });

  final FirebaseAuth auth;
  final UsersProvider usersProvider;

  final FollowService _followService = FollowService();

  @override
  Widget build(BuildContext context) {
    final String? error = usersProvider.error;
    final bool loading = usersProvider.loading;
    final List<AppUser> users = usersProvider.users;

    if (error != null) {
      return Center(
        child: Text(error),
      );
    }
    if (loading && users.isEmpty) {
      return Center(
        child: AppProgressIndicator(),
      );
    }

    if (users.isEmpty) {
      return Center(
        child: Text("No users to show"),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final AppUser user = users[index];
        final username = "${user.firstName} ${user.lastName}";
        final bio = user.bio;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
                  title: Text(username),
                  subtitle: bio != null
                      ? Text(
                          bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  trailing: StreamBuilder(
                      stream: _followService.isFollowing(user.id),
                      builder: (context, snapshot) {
                        return OutlinedButton.icon(
                          onPressed: () =>
                              snapshot.hasData && snapshot.data!.exists
                                  ? _followService.unfollowUser(user.id)
                                  : _followService.followUser(user.id),
                          label: Text(snapshot.hasData && snapshot.data!.exists
                              ? "Unfollow"
                              : "Follow"),
                          icon: const Icon(Icons.rss_feed_rounded),
                        );
                      }),
                  leading: CircularImage(
                    url: user.profilePhotoUrl,
                    size: 23,
                  ),
                  onTap: () => navigatorkey.currentState
                      ?.push(MaterialPageRoute(builder:(context) => ProfilePage(userArg: user,),)),
                ),
        );
      },
    );
  }
}
