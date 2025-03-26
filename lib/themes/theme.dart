import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ),
);
ThemeData darkMode = ThemeData(
    colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.blue,
  brightness: Brightness.dark,
));
