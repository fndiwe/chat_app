import 'package:chat_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  final BuildContext context;
  ThemeProvider({required this.context});
  late final Box<bool> box = Hive.box<bool>(Constants.hiveBox);
  late bool isDarkTheme = box.get(Constants.hiveBox)!;

  void changeTheme() {
    isDarkTheme = !isDarkTheme;
    box.put(Constants.hiveBox, isDarkTheme);
    notifyListeners();
  }
}
