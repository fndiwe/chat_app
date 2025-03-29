import 'package:chat_app/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';

class UsersProvider extends ChangeNotifier {
  List<AppUser> users = [];
  String? error;
  bool loading = true;

  Future<void> getUsers(ChatService chatService) async {
      error = null;
      try {
        users = await chatService.getUsers();
      } on FirebaseException catch (e) {
        error = e.message;
      } finally {
        loading = false;
      }
      notifyListeners();
    }
}
