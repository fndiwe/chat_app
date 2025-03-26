import 'package:chat_app/components/app_progress_indicator.dart';
import 'package:chat_app/components/login_text_field.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReusableLoginPage extends StatefulWidget {
  const ReusableLoginPage({
    super.key,
    required this.buttonStyle,
    required this.isSignUp,
    required this.switchPage,
  });

  final ButtonStyle buttonStyle;
  final bool isSignUp;
  final void Function() switchPage;

  @override
  State<ReusableLoginPage> createState() => _ReusableLoginPageState();
}

class _ReusableLoginPageState extends State<ReusableLoginPage> {
  final _firstNameTextFieldController = TextEditingController();

  final _lastNameTextFieldController = TextEditingController();

  final _emailTextFieldController = TextEditingController();

  final _passwordTextFieldController = TextEditingController();

  final _confirmPasswordTextFieldController = TextEditingController();
  bool _loading = false;
  String emptyTextFieldError = "This field is required";
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  void login(BuildContext context) async {
    setState(() {
      _loading = true;
    });
    final authService = AuthService();
    try {
      await authService.signInWithEmailAndPassword(
          _emailTextFieldController.text, _passwordTextFieldController.text);
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message.toString())));
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void signup(BuildContext context) async {
    setState(() {
      _loading = true;
    });

    final authService = AuthService();
    try {
      await authService.registerWithEmailAndPassword(
          _emailTextFieldController.text,
          _passwordTextFieldController.text,
          _firstNameTextFieldController.text,
          _lastNameTextFieldController.text);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 25,
                children: [
                  const Icon(Icons.person, size: 50),
                  const Text('Welcome to Social App',
                      style: TextStyle(fontSize: 16)),
                  //First and last name TextField
                  if (widget.isSignUp)
                    Row(
                      spacing: 15,
                      children: [
                        Expanded(
                          child: LoginTextField(
                            hintText: 'First name',
                            obscureText: false,
                            controller: _firstNameTextFieldController,
                            prefixIcon: Icon(Icons.person_outlined),
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                        Expanded(
                          child: LoginTextField(
                            hintText: 'Last name',
                            obscureText: false,
                            controller: _lastNameTextFieldController,
                            prefixIcon: Icon(Icons.person_outlined),
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                      ],
                    ),
                  //Email TextField
                  LoginTextField(
                    hintText: 'example@gmail.com',
                    obscureText: false,
                    controller: _emailTextFieldController,
                    prefixIcon: Icon(Icons.email_outlined),
                  ),

                  //Password Textfield
                  LoginTextField(
                    hintText: 'Enter your password',
                    obscureText: obscurePassword,
                    controller: _passwordTextFieldController,
                    otherValidators: (value) {
                      if (widget.isSignUp) {
                        if (_passwordTextFieldController.text.length < 6) {
                          return "Password must contain at least 6 characters.";
                        } else if (value !=
                            _confirmPasswordTextFieldController.text) {
                          return "Passwords does not match";
                        }
                      }
                      return null;
                    },
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                        onPressed: () => setState(() {
                              obscurePassword = !obscurePassword;
                            }),
                        icon: Icon(obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined)),
                  ),
                  // Confirm Pasword Textfield
                  if (widget.isSignUp)
                    LoginTextField(
                      hintText: 'Confirm your password',
                      obscureText: obscureConfirmPassword,
                      controller: _confirmPasswordTextFieldController,
                      otherValidators: (value) {
                        if (_passwordTextFieldController.text != value) {
                          return "Passwords does not match";
                        }
                        return null;
                      },
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                          onPressed: () => setState(() {
                                obscureConfirmPassword =
                                    !obscureConfirmPassword;
                              }),
                          icon: Icon(obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined)),
                    ),
                  if (!widget.isSignUp)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () {}, child: Text("Forgot password?"))
                      ],
                    ),

                  //Login Button
                  FilledButton(
                      onPressed: _loading
                          ? null
                          : () => _formKey.currentState!.validate()
                              ? widget.isSignUp
                                  ? signup(context)
                                  : login(context)
                              : setState(() {
                                  _loading = false;
                                }),
                      style: widget.buttonStyle,
                      child: _loading
                          ? const AppProgressIndicator()
                          : Text(widget.isSignUp ? 'Sign up' : 'Sign in')),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Expanded(child: Divider()),
                      Text(
                        "Or",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Expanded(child: Divider())
                    ],
                  ),

                  OutlinedButton.icon(
                      onPressed: () {},
                      label: Text(widget.isSignUp
                          ? 'Sign up with Google'
                          : 'Sign in with Google'),
                      icon: Image.asset(
                        'lib/assets/google_logo.png',
                        height: 25,
                      ),
                      style: widget.buttonStyle),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.isSignUp
                          ? "Have an account?"
                          : "Don't have an account?"),
                      TextButton(
                          onPressed: widget.switchPage,
                          child: Text(widget.isSignUp ? 'Sign in' : 'Sign up'))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
