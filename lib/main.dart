import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'package:fanctrlapp/pages/home.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightColorScheme, ColorScheme? darkColorScheme) {
        return MaterialApp(
          title: 'Fan Controller',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
          ),
          home: const HomePage(),
        );
      },
    );
  }
}
