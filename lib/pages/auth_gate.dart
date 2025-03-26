import 'package:chat_app/pages/auth_page.dart';
import 'package:chat_app/pages/navigation_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) =>
          snapshot.hasData ? NavigationPage() : const AuthPage(),
    );
  }
}
