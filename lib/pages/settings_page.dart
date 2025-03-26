import 'package:chat_app/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeProvider provider = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
              SwitchListTile.adaptive(
                value: provider.isDarkTheme,
                onChanged: (value) => provider.changeTheme(),
                title: const Text("Dark mode"),
              )
        ],
      ),
    );
  }
}
