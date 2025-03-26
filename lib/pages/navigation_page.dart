import 'package:chat_app/services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/nav_bar_destination.dart';
import 'home_page.dart';
import 'messages_page.dart';
import 'profile_page.dart';
import 'users_page.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final List<NavBarDestination> _navBarDestinations = [
    NavBarDestination(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: "Home"),
    NavBarDestination(
        icon: Icons.message_outlined,
        selectedIcon: Icons.message_rounded,
        label: "Messages"),
    NavBarDestination(
        icon: Icons.people_outline_rounded,
        selectedIcon: Icons.people_rounded,
        label: "People"),
    NavBarDestination(
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: "Profile"),
  ];

  final List<Widget> _screens = [
    HomePage(),
    MessagesPage(),
    UsersPage(),
    ProfilePage()
  ];

  int currentIndex = 0;
  final ChatService _chatService = ChatService();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  void changeIndex(int index) => setState(() {
        currentIndex = index;
      });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        backgroundColor: theme.colorScheme.surface,
        selectedIndex: currentIndex,
        onDestinationSelected: changeIndex,
        destinations: _navBarDestinations
            .map(
              (e) => StreamBuilder(
                  stream: e.label == "Messages"
                      ? _chatService.getAllUnreadMessagesCount(_currentUserId)
                      : null,
                  builder: (context, snapshot) {
                    return Stack(alignment: Alignment.topRight, children: [
                      NavigationDestination(
                          icon: Icon(e.icon),
                          selectedIcon: Icon(e.selectedIcon),
                          label: e.label),
                      if (e.label == "Messages" &&
                          snapshot.hasData &&
                          snapshot.data! > 0)
                        Positioned(
                          right: 35,
                          top: 12,
                          child: Badge.count(
                            count: snapshot.data!,
                            textStyle:
                                theme.textTheme.bodySmall!.copyWith(fontSize: 9),
                          ),
                        )
                    ]);
                  }),
            )
            .toList(),
      ),
      body: _screens[currentIndex],
    );
  }
}
