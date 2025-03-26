import 'package:chat_app/pages/auth_page.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/create_post_page.dart';
import 'package:chat_app/pages/edit_profile.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/messages_page.dart';
import 'package:chat_app/pages/profile_page.dart';
import 'package:chat_app/pages/settings_page.dart';
import 'package:chat_app/pages/users_page.dart';
import 'package:chat_app/provider/posts_provider.dart';
import 'package:chat_app/provider/profile_provider.dart';
import 'package:chat_app/provider/users_provider.dart';
import 'package:chat_app/themes/theme.dart';
import 'package:chat_app/provider/theme_provider.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart'; // Add this line to import DefaultFirebaseOptions
import 'pages/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<bool>(Constants.hiveBox);
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final theme = Hive.box<bool>(Constants.hiveBox);

  if (theme.isEmpty) theme.put('theme', false);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(context: context)),
      ChangeNotifierProvider<PostsProvider>(create: (context) => PostsProvider()),
      ChangeNotifierProvider<UsersProvider>(
        create: (context) => UsersProvider(),
      ),
      ChangeNotifierProvider<ProfileProvider>(
        create: (context) => ProfileProvider(),
      )
    ],
    builder: (context, child) => const ChatApp(),
  ));
}

final navigatorkey = GlobalKey<NavigatorState>();

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final themeData =  themeProvider.isDarkTheme ? darkMode : lightMode;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: themeData.colorScheme.surface,
        systemNavigationBarColor: themeData.colorScheme.onSurface,
        statusBarIconBrightness:
            themeData == lightMode ? Brightness.dark : Brightness.light,
        statusBarBrightness:
            themeData == lightMode ? Brightness.dark : Brightness.light));
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeData,
        navigatorKey: navigatorkey,
        home: const AuthGate(),
        routes: {
          "/login": (context) => const AuthPage(),
          "/home": (context) => const HomePage(),
          "/create": (context) => const CreatePostPage(),
          "/messages": (context) => const MessagesPage(),
          "/chat": (context) => const ChatPage(),
          "/users": (context) => const UsersPage(),
          "/profile": (context) => const ProfilePage(),
          "/settings": (context) => const SettingsPage(),
          "/edit_profile": (context) => const EditProfile()
        },
      ),
    );
  }
}
