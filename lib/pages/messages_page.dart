import 'package:chat_app/components/app_progress_indicator.dart';
import 'package:chat_app/components/circular_image.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/chat_service.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final ChatService _chatService = ChatService();

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    final currentUserId = _auth.currentUser!.uid;
    return StreamBuilder(
        stream: _chatService.getChats(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const AppProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data?.isEmpty == true) {
            return const Center(
              child: Text("No messages yet."),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 8),
            itemCount: snapshot.data?.length,
            itemBuilder: (context, index) {
              final chatRoom = snapshot.data![index];
              final String recipientId = chatRoom.userIds.firstWhere(
                (element) => element != currentUserId,
              );
              return FutureBuilder(
                  future: _authService.getUser(recipientId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    final AppUser user = snapshot.data!;
                    return ListTile(
                      contentPadding: EdgeInsets.all(8),
                      title: Text(user.fullName),
                      titleAlignment: ListTileTitleAlignment.top,
                      subtitle: StreamBuilder<Message>(
                          stream: _chatService.getLatestMessage(
                              currentUserId, recipientId),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text(snapshot.error.toString());
                            }
                            Message? message = snapshot.data;
                            return message != null
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          message.text,
                                          style: TextStyle(
                                              fontWeight: message.recieverId ==
                                                          currentUserId &&
                                                      !message.read
                                                  ? FontWeight.bold
                                                  : FontWeight
                                                      .normal), // Make the font bold if the current displaying message is not unread
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Unread messages count
                                      if (message.recieverId == currentUserId &&
                                          !message.read)
                                        StreamBuilder(
                                            stream: _chatService
                                                .getUnreadMessagesCount(
                                                    _auth.currentUser!.uid,
                                                    chatRoom.userIds.firstWhere(
                                                        (id) =>
                                                            id !=
                                                            currentUserId)),
                                            builder: (context, snapshot) {
                                              return snapshot.hasData &&
                                                      snapshot.data! > 0
                                                  ? Badge.count(
                                                      count: snapshot
                                                          .data!) // Show a badge to display the number of unread messages
                                                  : Container();
                                            })
                                    ],
                                  )
                                : Container();
                          }),
                      // The user profile image
                      leading: CircularImage(
                        url: user.profilePhotoUrl,
                        size: 23,
                      ),
                      onTap: () => navigatorkey.currentState?.pushNamed("/chat",
                          arguments: user), // Navigate to the chat page
                    );
                  });
            },
          );
        });
  }
}
