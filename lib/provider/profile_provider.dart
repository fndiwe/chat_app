import 'package:chat_app/models/user.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  String? error;
  bool loading = true;
  AppUser? currentUser;

  Future<void> getCurrentUser(
      FirebaseAuth auth, AuthService authService) async {
      error = null;
      try {
        currentUser = await authService.getUser(auth.currentUser!.uid);
      } on FirebaseException catch (e) {
        error = e.message;
      } finally {
        loading = false;
      }

      notifyListeners();
    }
}
