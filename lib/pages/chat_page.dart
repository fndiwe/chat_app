import 'package:chat_app/components/circular_image.dart';
import 'package:chat_app/components/message_bubble.dart';
import 'package:chat_app/components/message_text_field.dart';
import 'package:chat_app/components/rotated_send_button.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/timestamp_util.dart';
import 'profile_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _messageTextController = TextEditingController();

  final FocusNode _focusNode = FocusNode();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(Duration(milliseconds: 500), _scrollToBottom);
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    final AppUser user = ModalRoute.of(context)?.settings.arguments as AppUser;
    await _chatService.setMessagesAsRead(_auth.currentUser!.uid, user.id);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _messageTextController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
  }

  void _sendMessage(String recieverId) {
    if (_messageTextController.text.isNotEmpty) {
      _chatService.sendMessage(recieverId, _messageTextController.text);
      _messageTextController.clear();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppUser user = ModalRoute.of(context)?.settings.arguments as AppUser;
    final String name = user.fullName;
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: null,
        title: ListTile(
          onTap: () =>
              navigatorkey.currentState
                    ?.push(MaterialPageRoute(builder:(context) => ProfilePage(userArg: user,),)),
          leading: CircularImage(
            url: user.profilePhotoUrl,
            size: 20,
          ),
          title: Text(
            name,
            style:
                Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 17),
          ),
          subtitle: user.bio != null
              ? Text(
                  user.bio!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
        ),
        titleSpacing: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMessageList(context, user.id),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              spacing: 8,
              children: [
                MessageTextField(
                  messageTextController: _messageTextController,
                  focusNode: _focusNode,
                ),
                IconButton.filled(
                    onPressed: () => _sendMessage(user.id),
                    icon: RotatedSendButton())
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMessageList(BuildContext context, String userId) {
    final User currentUser = _auth.currentUser!;
    final theme = Theme.of(context);
    return Expanded(
      child: StreamBuilder(
          stream: _chatService.getMessages(currentUser.uid, userId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            } else if (!snapshot.hasData &&
                snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: const CircularProgressIndicator.adaptive());
            } else {
              if (!snapshot.hasData || snapshot.data?.isEmpty == true) {
                return Center(child: const Text("No messages yet."));
              } else {
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final Message message = snapshot.data![index];
                    final isUserMessage = message.senderId == currentUser.uid;
                    final DateTime date = message.timestamp.toDate();
                    final int year = date.year;
                    final int month = date.month;
                    final int day = date.day;
                    final int dayOfWeek = date.weekday;
                    if (index == 0) {
                      return Column(
                        children: [
                          TimestampView(
                              dayOfWeek: dayOfWeek,
                              day: day,
                              month: month,
                              year: year,
                              theme: theme),
                          MessageBubble(
                              isUserMessage: isUserMessage,
                              theme: theme,
                              message: message)
                        ],
                      );
                    } else {
                      final Message previousMessage = snapshot.data![index - 1];
                      final DateTime previousDate =
                          previousMessage.timestamp.toDate();
                      final int previousYear = previousDate.year;
                      final int previousMonth = previousDate.month;
                      final int previousDay = previousDate.day;
                      if (year == previousYear &&
                          month == previousMonth &&
                          day == previousDay) {
                        return Padding(
                          padding: EdgeInsets.only(
                              top: index > 0 &&
                                      snapshot.data![index - 1].recieverId !=
                                          message.recieverId
                                  ? 8
                                  : 0),
                          child: MessageBubble(
                              isUserMessage: isUserMessage,
                              theme: theme,
                              message: message),
                        );
                      } else {
                        return Column(
                          children: [
                            TimestampView(
                                dayOfWeek: dayOfWeek,
                                day: day,
                                month: month,
                                year: year,
                                theme: theme),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: index > 0 &&
                                          snapshot.data![index - 1]
                                                  .recieverId !=
                                              message.recieverId
                                      ? 8
                                      : 0),
                              child: MessageBubble(
                                  isUserMessage: isUserMessage,
                                  theme: theme,
                                  message: message),
                            ),
                          ],
                        );
                      }
                    }
                  },
                );
              }
            }
          }),
    );
  }
}

class TimestampView extends StatelessWidget {
  const TimestampView({
    super.key,
    required this.dayOfWeek,
    required this.day,
    required this.month,
    required this.year,
    required this.theme,
  });

  final int dayOfWeek;
  final int day;
  final int month;
  final int year;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final DateTime todaysDate = DateTime.now();
    final int todayYear = todaysDate.year;
    final int todayMonth = todaysDate.month;
    final int todayDay = todaysDate.day;
    final String text = todayYear == year &&
            todayMonth == month &&
            todayDay == day
        ? "Today"
        : todayYear == year && todayMonth == month && day == todayDay - 1
            ? "Yesterday"
            : "${TimestampUtil.weekdays[dayOfWeek - 1]}, $day ${TimestampUtil.months[month - 1]}${year == todayYear ? "" : ", $year"}";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Card.filled(
          color: theme.colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text(
              text,
              style: theme.textTheme.labelLarge,
            ),
          ),
        ),
      ),
    );
  }
}
