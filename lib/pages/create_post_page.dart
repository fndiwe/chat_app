import 'package:chat_app/components/circular_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final FocusNode focusNode = FocusNode();

  final TextEditingController textEditingController = TextEditingController();

  final PostService postService = PostService();

  final FirebaseAuth auth = FirebaseAuth.instance;

  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create post"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            FutureBuilder(
                future: authService.getUser(auth.currentUser!.uid),
                builder: (context, snapshot) {
                  return GestureDetector(
                      onTap: () => navigatorkey.currentState?.pushNamed(
                          "/profile",
                          arguments: auth.currentUser!.uid),
                      child: CircularImage(
                        url: snapshot.data?.profilePhotoUrl,
                        size: 23,
                      ));
                }),
            Expanded(
              child: Column(
                spacing: 10,
                children: [
                  Expanded(
                    flex: 0,
                    child: TextField(
                      autofocus: true,
                      maxLength: 150,
                      controller: textEditingController,
                      focusNode: focusNode,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.unspecified,
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
                      decoration: InputDecoration(
                          hintText: "What's on your mind?...",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15))),
                    ),
                  ),
                  FilledButton(
                      style: ButtonStyle(
                          minimumSize: WidgetStatePropertyAll(
                              Size(double.infinity, 40))),
                      onPressed: () {
                        // TODO Don't run onPress if there's no internet connection.
                        if (textEditingController.text.isNotEmpty) {
                          postService.sendPost(textEditingController.text);
                          textEditingController.clear();
                          focusNode.dispose();
                          navigatorkey.currentState?.pop();
                        }
                      },
                      child: const Text("Post"))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
