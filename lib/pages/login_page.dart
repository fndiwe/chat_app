import 'package:chat_app/components/reusable_login_page.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, required this.switchPage});

  final void Function() switchPage;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size(double.infinity, 50)));

    return ReusableLoginPage(
      buttonStyle: buttonStyle,
      isSignUp: false, switchPage: switchPage,
    );
  }
}
